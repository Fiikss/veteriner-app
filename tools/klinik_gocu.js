/**
 * VET-01 veri gocu: mevcut kayitlara klinikID basar.
 *
 * Uygulamanin yeni surumu klinik kimligi olmayan kaydi GORMEZ. Bu betik,
 * bitirme projesi doneminden kalan tum kayitlari tek bir klinige baglar.
 *
 * Kullanim (proje kokunde):
 *   npm install firebase-admin
 *   set GOOGLE_APPLICATION_CREDENTIALS=C:\yol\serviceAccountKey.json
 *   node tools/klinik_gocu.js                 -> yalnizca rapor verir (deneme)
 *   node tools/klinik_gocu.js --uygula        -> gercekten yazar
 *   node tools/klinik_gocu.js --uygula --klinik-id=abc   -> var olan klinige bagla
 *   node tools/klinik_gocu.js --test-klinigi --uygula    -> sizinti testi verisi olustur
 *
 * Servis hesabi anahtarini Firebase Console > Proje ayarlari > Hizmet hesaplari
 * ekranindan indirebilirsin. Anahtar dosyasini depoya EKLEME.
 */

// firebase-admin 13+ modüler API kullanir; eski admin.firestore() kaldirildi.
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

// Kimlik GOOGLE_APPLICATION_CREDENTIALS ortam degiskeninden okunur.
initializeApp();
const db = getFirestore();

const argv = process.argv.slice(2);
const uygula = argv.includes("--uygula");
const klinikArg = argv.find((a) => a.startsWith("--klinik-id="));
const KLINIK_ADI = "Ana Klinik";
const testKlinigi = argv.includes("--test-klinigi");

// Klinik kimligi eklenecek koleksiyonlar.
const KOLEKSIYONLAR = [
  "Kullanicilar",
  "Hayvanlar",
  "Randevular",
  "Slotlar",
  "Asilar",
  "TibbiKayitlar",
];

async function klinigiHazirla() {
  if (klinikArg) {
    const id = klinikArg.split("=")[1];
    const doc = await db.collection("Klinikler").doc(id).get();
    if (!doc.exists) throw new Error(`Klinik bulunamadi: ${id}`);
    console.log(`Mevcut klinik kullanilacak: ${id} (${doc.data().ad})`);
    return id;
  }

  const mevcut = await db.collection("Klinikler").limit(1).get();
  if (!mevcut.empty) {
    console.log(`Zaten bir klinik var, o kullanilacak: ${mevcut.docs[0].id}`);
    return mevcut.docs[0].id;
  }

  const ref = db.collection("Klinikler").doc();
  console.log(`Yeni klinik olusturulacak: ${ref.id} (${KLINIK_ADI})`);
  if (uygula) {
    await ref.set({ ad: KLINIK_ADI, adres: "", telefon: "", aktif: true });
  }
  return ref.id;
}

/** Asi ve tibbi kayitlara hayvanin sahibini kopyalar (guvenlik kurallari icin). */
async function sahipBul(hayvanID, onbellek) {
  if (!hayvanID) return "";
  if (onbellek.has(hayvanID)) return onbellek.get(hayvanID);
  const doc = await db.collection("Hayvanlar").doc(hayvanID).get();
  const sahip = doc.exists ? doc.data().sahipID || "" : "";
  onbellek.set(hayvanID, sahip);
  return sahip;
}

async function koleksiyonuGoc(ad, klinikID, onbellek) {
  const snap = await db.collection(ad).get();
  let dokunulan = 0;
  let yigin = db.batch();
  let yiginBoyu = 0;

  for (const doc of snap.docs) {
    const veri = doc.data();
    const yama = {};

    if (!veri.klinikID) yama.klinikID = klinikID;

    if ((ad === "Asilar" || ad === "TibbiKayitlar") && !veri.sahipID) {
      yama.sahipID = await sahipBul(veri.hayvanID, onbellek);
    }
    // Eski alan adlarini duzelt (analyze uyarilari: HekimID, randevu_tur).
    if (ad === "Randevular" || ad === "TibbiKayitlar") {
      if (veri.HekimID !== undefined && veri.hekimID === undefined) {
        yama.hekimID = veri.HekimID;
        yama.HekimID = FieldValue.delete();
      }
    }
    if (ad === "Randevular") {
      if (veri.randevu_tur !== undefined && veri.randevuTur === undefined) {
        yama.randevuTur = veri.randevu_tur;
        yama.randevu_tur = FieldValue.delete();
      }
    }
    if (ad === "Asilar" && veri.hatirlatildi === undefined) {
      // Gecmis kayitlar icin hatirlatma gonderilmis sayilir; gocun
      // ertesi sabahi herkese toplu mesaj gitmesini onler.
      yama.hatirlatildi = true;
    }

    if (Object.keys(yama).length === 0) continue;

    dokunulan++;
    if (uygula) {
      yigin.update(doc.ref, yama);
      if (++yiginBoyu === 400) {
        await yigin.commit();
        yigin = db.batch();
        yiginBoyu = 0;
      }
    }
  }

  if (uygula && yiginBoyu > 0) await yigin.commit();
  console.log(`  ${ad}: ${snap.size} kayit, ${dokunulan} tanesi guncellenecek`);
  return dokunulan;
}

/**
 * Sizinti testi verisi: ikinci bir klinik ve ona ait bir hasta, asi ve
 * tibbi kayit olusturur. Bu kayitlarin BIRINCI klinigin hicbir ekraninda
 * gorunmemesi gerekir; gorunuyorsa klinik filtresi bir yerde eksiktir.
 */
async function testKlinigiOlustur() {
  const klinikRef = db.collection("Klinikler").doc();
  const sahipID = "test-sahip-" + klinikRef.id.slice(0, 6);
  const hayvanRef = db.collection("Hayvanlar").doc();
  const simdi = new Date();
  const gelecek = new Date(simdi.getTime() + 30 * 24 * 60 * 60 * 1000);

  console.log("\n-- Sizinti testi verisi --");
  console.log(`  Klinik : ${klinikRef.id} (Test Klinigi B)`);
  console.log(`  Hasta  : ${hayvanRef.id} (Sizinti Testi Kedisi)`);

  if (!uygula) {
    console.log("  (deneme modu - yazilmadi)");
    return;
  }

  await klinikRef.set({
    ad: "Test Klinigi B",
    adres: "Yalnizca sizinti testi icin",
    telefon: "",
    aktif: true,
  });

  await hayvanRef.set({
    klinikID: klinikRef.id,
    sahipID,
    ad: "Sizinti Testi Kedisi",
    tur: "Kedi",
    irk: "Tekir",
    yas: 3,
    kilo: 4.2,
    fotoUrl: "",
  });

  await db.collection("Asilar").doc().set({
    klinikID: klinikRef.id,
    hayvanID: hayvanRef.id,
    sahipID,
    hayvanAdi: "Sizinti Testi Kedisi",
    asiAdi: "SIZINTI TESTI ASISI",
    yapilmaTarihi: simdi,
    sonrakiAsiTarihi: gelecek,
    asiDurumu: "Bekliyor",
    hatirlatildi: false,
  });

  await db.collection("TibbiKayitlar").doc().set({
    klinikID: klinikRef.id,
    hayvanID: hayvanRef.id,
    sahipID,
    hekimID: "test-hekim",
    kategori: "Genel Muayene",
    teshis: "SIZINTI TESTI KAYDI",
    tedavi: "Bu kayit baska klinikte gorunuyorsa filtre eksik.",
    ilaclar: "",
    tarih: simdi,
  });

  console.log("  Olusturuldu.\n");
  console.log("  Simdi kendi klinigindeki hekim hesabinla gir ve sunlara bak:");
  console.log("    - Hasta listesinde 'Sizinti Testi Kedisi' GORUNMEMELI");
  console.log("    - Yaklasan asilarda 'SIZINTI TESTI ASISI' GORUNMEMELI");
  console.log("    - Tibbi kayitlarda 'SIZINTI TESTI KAYDI' GORUNMEMELI");
  console.log("    - Kayit ekranindaki klinik listesinde 'Test Klinigi B' GORUNMELI");
}

(async () => {
  console.log(uygula ? "== UYGULAMA MODU ==" : "== DENEME MODU (hicbir sey yazilmaz) ==");

  if (testKlinigi) {
    await testKlinigiOlustur();
    process.exit(0);
  }

  const klinikID = await klinigiHazirla();
  const onbellek = new Map();
  let toplam = 0;

  for (const ad of KOLEKSIYONLAR) {
    toplam += await koleksiyonuGoc(ad, klinikID, onbellek);
  }

  console.log(`\nToplam ${toplam} kayit ${uygula ? "guncellendi" : "guncellenecek"}.`);
  if (!uygula) console.log("Gercekten yazmak icin: node tools/klinik_gocu.js --uygula");
  process.exit(0);
})().catch((e) => {
  console.error("Goc basarisiz:", e);
  process.exit(1);
});
