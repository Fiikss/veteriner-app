# VetApp — Veteriner Klinik Yönetim Uygulaması
## Tez Savunma Dokümanı

---

## 1. PROJE GENEL BAKIŞ

Bu proje, veteriner kliniklerinin dijital ortamda yönetilmesini sağlayan bir mobil uygulamadır. Müşteriler hayvanlarını kaydedip randevu alabilir, hekimler randevuları yönetip tıbbi kayıt girebilir, asistanlar ise ödeme işlemlerini takip edebilir.

**Kullanılan Teknolojiler:**
- Flutter (Dart) — mobil uygulama geliştirme
- Firebase Authentication — kullanıcı kimlik doğrulama
- Cloud Firestore — gerçek zamanlı NoSQL veritabanı
- SharedPreferences — cihaz üzeri yerel depolama
- image_picker — galeriden fotoğraf seçme

**Mimari:** MVC (Model — View — Controller/Servis)

---

## 2. MİMARİ YAPI (MVC)

Uygulama üç katmandan oluşmaktadır:

**Model Katmanı (`lib/model/`)**
Verilerin yapısını tanımlar. Firestore ile Dart nesneleri arasında dönüşüm sağlar.

**Servis Katmanı (`lib/servis/`)**
Firestore ile doğrudan iletişim kurar. View katmanı veri işlemlerini bu katman üzerinden yapar. Model ve View birbirini tanımaz; servis köprü görevi görür.

**View Katmanı (`lib/view/`)**
Kullanıcının gördüğü ekranlardır. Veri işleme yapmaz; servisi çağırır, sonucu gösterir.

---

## 3. FİRESTORE VERİ YAPISI

Firestore'da üç ana koleksiyon bulunmaktadır:

**Kullanicilar**
- email, adSoyad, telefon, rol (musteri / hekim / asistan)

**Hayvanlar**
- sahipID, ad, tur, irk, yas, kilo, fotoUrl

**Randevular**
- musteriID, hayvanID, HekimID, sikayet, randevu_tur, durum, odeme, odemeDurumu, tarih, slotID, saat

**Roller nasıl atanır?**
Müşteri rolü kayıt sırasında otomatik atanır. Hekim ve asistan rolleri güvenlik gerekçesiyle Firebase konsolundan yönetici tarafından manuel atanır.

---

## 4. DOSYALAR VE GÖREVLERİ

### main.dart
Uygulamanın giriş noktasıdır. Firebase başlatılır, ardından uygulama çalıştırılır.
- `WidgetsFlutterBinding.ensureInitialized()` — Flutter motoru `runApp()`'tan önce başlatılır; bu olmadan Firebase'in kullandığı platform kanalları çalışmaz.
- `async/await` — Firebase başlatma işlemi zaman aldığı için, tamamlanmadan `runApp()` çağrılmaz.

### lib/view/ana_sayfa.dart
Giriş yaptıktan sonra kullanıcıyı rolüne göre yönlendiren ekrandır.
- `StreamBuilder` — kullanıcının oturum durumunu sürekli dinler. Kullanıcı çıkış yaptığında uygulama otomatik olarak giriş ekranına döner.
- `FutureBuilder` — giriş yapıldıktan sonra Firestore'dan kullanıcı rolünü tek seferlik çeker.
- Role göre yönlendirme: hekim → HekimAnaSayfa, asistan → AsistanAnaSayfa, diğer → MusteriAnaSayfa

### lib/model/hayvan_model.dart
Hayvan verisinin yapısını tanımlar.
- `fromMap()` — Firestore'dan gelen Map verisini Dart nesnesine çevirir (okuma).
- `toMap()` — Dart nesnesini Firestore'un anlayacağı Map formatına çevirir (yazma).
- `?? ''` ve `?.toDouble()` — Firestore'dan gelen alanda değer eksik olursa null döner. Dart'ın null safety özelliği nedeniyle bu null değer doğrudan kullanılamaz; varsayılan değer atanır.

### lib/model/randevu_model.dart
Randevu verisinin yapısını tanımlar. Hayvan modeliyle aynı mantığı taşır.
- `tarih` alanı Firestore'da `Timestamp` olarak saklanır; `fromMap` içinde `.toDate()` ile Dart'ın `DateTime` tipine çevrilir.

### lib/servis/hayvan_servis.dart
Hayvan verisi üzerindeki tüm Firestore işlemlerini yürütür.
- `hayvanEkle()` — `Future<void>`: tek seferlik işlem, biter ve döner.
- `musteriHayvanlari()` — `Stream`: Firestore'daki değişiklikleri sürekli dinler, yeni hayvan eklenince liste otomatik güncellenir.
- `hayvanGuncelle()`, `hayvanSil()` — tek seferlik işlemler, `Future` kullanır.

### lib/servis/randevu_servis.dart
Randevu verisi üzerindeki tüm Firestore işlemlerini yürütür.
- `durumGuncelle()` — hekimin randevuyu onaylaması/reddetmesi için sadece `durum` alanını günceller.
- `odemeGuncelle()` — asistanın ödeme bilgisini girmesi için `odeme` ve `odemeDurumu` alanlarını günceller.
- `musteriRandevulari()` / `tumRandevular()` — Stream döner, ekran gerçek zamanlı güncellenir.

### lib/servis/foto_servis.dart
Galeriden fotoğraf seçme işlemini yönetir.
- `image_picker` paketi kullanılır.
- `imageQuality: 15` ile fotoğraf sıkıştırılır, boyut küçültülür.
- 900 KB üstü fotoğraflar reddedilir, hata fırlatılır.
- Fotoğraf base64 formatına çevrilip Firestore'a metin olarak kaydedilir.

### lib/view/giris_ekrani.dart
Kullanıcı giriş ekranıdır.
- Firebase Auth `signInWithEmailAndPassword` ile giriş yapılır.
- Müşteriler için email doğrulama zorunludur; hekim/asistan hesapları yönetici tarafından oluşturulduğu için bu zorunluluk uygulanmaz.
- Seçilen rol ile hesabın gerçek rolü uyuşmuyorsa giriş engellenir.
- `SharedPreferences` ile "Beni Hatırla" özelliği sağlanır — email ve şifre cihazın yerel hafızasına kaydedilir, internet bağlantısı gerekmez.
- `FirebaseAuthException` ile hata kodları Türkçe mesajlara dönüştürülür.

### lib/view/kayit_ekrani.dart
Yeni kullanıcı kayıt ekranıdır.
Kayıt akışı sırasıyla şöyledir:
1. Firebase Auth'ta hesap oluşturulur.
2. Firestore'daki Kullanicilar koleksiyonuna kullanıcı belgesi yazılır, rol 'musteri' atanır.
3. Doğrulama emaili gönderilir.
4. Firebase'in otomatik açtığı oturum hemen kapatılır — email doğrulanmadan giriş yapılamaması için.

### lib/view/hayvan_ekleme_ekrani.dart
Müşterinin hayvan eklediği ekrandır.
- `StatefulWidget` kullanılır çünkü fotoğraf seçilince `setState()` ile ekranın güncellenmesi gerekir.
- Hayvan ID'si `DateTime.now().millisecondsSinceEpoch.toString()` ile üretilir — her kayıt anı için pratik olarak benzersiz bir sayı üretir.
- Fotoğraf bytes olarak alınıp base64 string'e çevrilir ve `fotoUrl` alanına yazılır.

### lib/view/musteri_ana_sayfa.dart
Müşteri panelinin ana ekranıdır. İki sekme içerir: Hayvanlarım ve Randevularım.
- `PageController` ile sekmeler arasında geçiş animasyonlu yapılır.
- Randevu listesinde yalnızca 'Bekliyor' durumundaki randevularda iptal butonu gösterilir — hekim onayladıktan sonra müşteri tek taraflı iptal edemez.
- Bildirimler sağ üstteki zil ikonuna basılınca `endDrawer` olarak açılır.

### lib/view/hekim_randevular_ekrani.dart
Hekimin randevuları ve slotlarını yönettiği ekrandır.
- `TabController` ile iki sekme yönetilir: Randevular ve Saatlerim.
- `initState()` içinde TabController oluşturulur, `dispose()` içinde bellekten temizlenir — temizlenmezse bellek sızıntısı oluşur.
- Randevu listesi filtresi: geçmiş tarihli ve onaylanmamış randevular gizlenir. Geçmişte onaylanan randevular kayıt amaçlı görünmeye devam eder.

### lib/view/randevu_ekle_ekrani.dart
Müşterinin randevu aldığı ekrandır.
- Kaydet butonuna basılınca iki işlem yapılır:
  1. `randevuEkle()` — randevu Firestore'a yazılır.
  2. `slotDoldur()` — o saat dolu olarak işaretlenir.
  Her iki işlem zorunludur; slot doldurulmazsa başka kullanıcı aynı saate randevu alabilir (çift rezervasyon).

### lib/view/randevu_detay_ekrani.dart
Hekimin randevu detayını görüp onay/red verdiği ekrandır.
- Onayla ve Reddet butonları yalnızca `durum == 'Bekliyor'` iken gösterilir — karar verildikten sonra butonlar kaybolur, yanlışlıkla onaylanmış randevunun iptal edilmesi önlenir.

### lib/view/tibbi_kayit_ekle_ekrani.dart
Hekimin hayvan için tıbbi kayıt girdiği ekrandır.
- Aynı ekranda geçmiş kayıtlar da listelenir.
- Aşı kayıtları bu listeden filtrelenir (`kategori != 'Aşı'`) — aşı takibi ayrı bir ekranda yapıldığı için karışıklık önlenir.

---

## 5. VERİ AKIŞLARI

### Kayıt Olma Akışı
1. Kullanıcı email, şifre, ad-soyad girer.
2. Firebase Auth'ta hesap oluşturulur.
3. Firestore'a kullanıcı belgesi yazılır (rol: musteri).
4. Doğrulama emaili gönderilir.
5. Oturum kapatılır — kullanıcı emaili doğrulayıp giriş yapar.

### Giriş Yapma Akışı
1. Kullanıcı email, şifre ve rol seçer.
2. Firebase Auth ile doğrulama yapılır.
3. Firestore'dan kullanıcının rolü çekilir.
4. Müşteriyse email doğrulaması kontrol edilir.
5. Seçilen rol ile gerçek rol karşılaştırılır.
6. Uyuşuyorsa ilgili ana sayfaya yönlendirilir.

### Hayvan Ekleme Akışı
1. Müşteri formu doldurup fotoğraf seçer.
2. Fotoğraf base64'e çevrilir.
3. `Hayvan` nesnesi oluşturulur, ID milisaniye bazlı üretilir.
4. `toMap()` ile Map'e çevrilip Firestore'a yazılır.
5. Tüm müşterilerin hayvan listesi otomatik güncellenir (Stream sayesinde).

### Randevu Alma Akışı
1. Müşteri hayvanını seçer.
2. Boş slotlar Stream ile gerçek zamanlı listelenir.
3. Müşteri slot seçip şikayet yazar, kaydeder.
4. `randevuEkle()` ile randevu Firestore'a yazılır.
5. `slotDoldur()` ile o saat dolu işaretlenir.
6. Hekim randevuyu görür, onaylar veya reddeder.
7. Müşterinin randevu listesi otomatik güncellenir.

---

## 6. TEKNİK KARARLAR

### Neden Flutter?
Tek kod tabanıyla hem Android hem iOS'a uygulama geliştirilebilir. Dart dili öğrenmesi kolaydır ve Flutter'ın widget tabanlı yapısı hızlı UI geliştirme sağlar.

### Neden Firebase?
- Gerçek zamanlı veri senkronizasyonu (Stream desteği) sunar.
- Kimlik doğrulama altyapısı hazır gelir, sıfırdan yazmak gerekmez.
- Backend kurulum gerektirmez; doğrudan Flutter'dan erişilir.
- Email doğrulama, şifre sıfırlama gibi özellikler tek satırla eklenir.

### Neden MVC?
Kodun katmanlara ayrılması bakımı kolaylaştırır. Model değişirse servis güncellenir, view etkilenmez. View değişirse diğer katmanlar dokunulmaz. Test yazımı ve geliştirme ekibiyle çalışma kolaylaşır.

### Future vs Stream
- `Future` — tek seferlik işlemlerde kullanılır (ekleme, güncelleme, silme). Yapılır, beklenir, biter.
- `Stream` — sürekli dinleme gerektiren yerlerde kullanılır (listeleme). Firestore'da değişiklik olduğunda ekran otomatik güncellenir, kullanıcı sayfayı yenilemek zorunda kalmaz.

### toMap / fromMap
Firestore NoSQL bir veritabanıdır, Dart nesnelerini doğrudan işleyemez. `toMap()` nesneyi Firestore'un anlayacağı Map formatına çevirir. `fromMap()` ise Firestore'dan gelen ham veriyi tekrar kullanılabilir Dart nesnesine dönüştürür.

### Null Safety ve ?? operatörü
Firestore'dan gelen veride bir alan eksik olabilir; bu durumda `null` döner. Dart'ın null safety özelliği null değerlerin doğrudan kullanılmasına izin vermez. `??` operatörü "null gelirse bu varsayılan değeri kullan" anlamına gelir ve uygulamanın çökmesini önler.

### Fotoğraf Saklama (base64)
Fotoğraflar Firebase Storage yerine base64 string olarak Firestore'a kaydedilmiştir. Bu yöntem küçük fotoğraflar için uygundur; boyut kontrolü ve sıkıştırma yapılarak Firestore boyut sınırları içinde kalınmıştır.

### SharedPreferences
"Beni Hatırla" özelliği için kullanılır. Veri cihazın yerel hafızasına kaydedilir, Firebase'e veya internete gitmez. Uygulama yeniden açıldığında email ve şifre otomatik doldurulur.

---

## 7. JÜRİ SORU-CEVAPLARI

**S: Neden Flutter ve Firebase seçtiniz?**
C: Flutter tek kod tabanıyla Android ve iOS'a uygulama geliştirmeyi sağlar. Firebase ise backend kurulumu gerektirmeden gerçek zamanlı veri senkronizasyonu ve hazır kimlik doğrulama altyapısı sunar. İkisi birlikte hızlı ve etkili prototipleme imkânı tanıdı.

**S: MVC nedir, projenizde nasıl uyguladınız?**
C: MVC; Model, View ve Controller olmak üzere üç katmandan oluşur. Model veri yapısını tanımlar. View kullanıcı arayüzüdür. Controller (projemde Servis katmanı) ikisi arasında köprü kurar. Örneğin hayvan eklenince View, HayvanServis'i çağırır; servis Firestore'a yazar. View Firestore'u tanımaz, Firestore View'ı tanımaz.

**S: Firebase güvenliği nasıl sağlandı?**
C: Firebase Authentication ile her kullanıcı kimliği doğrulanmıştır. Rol yönetimi Firestore'daki kullanıcı belgesindeki 'rol' alanıyla yapılmaktadır. Hekim ve asistan rolleri yönetici tarafından manuel atanır, herkes bu rollere erişemez. Müşteriler için email doğrulama zorunludur.

**S: Gerçek zamanlı güncelleme nasıl çalışıyor?**
C: Firestore'un Stream özelliği kullanılıyor. Flutter'daki StreamBuilder bu Stream'i dinler. Firestore'da herhangi bir değişiklik olduğunda — başka bir kullanıcı randevu eklese, hekim durumu güncellese — ekran otomatik olarak yenilenir. Kullanıcı sayfayı yenilemek zorunda kalmaz.

**S: Çift randevu sorunu nasıl önlendi?**
C: Slot sistemi kullanıldı. Hekim müsait saatlerini slot olarak tanımlar. Müşteri randevu aldığında hem randevu kaydedilir hem de o slot 'dolu' olarak işaretlenir. Dolu slotlar müşteriye gösterilmez.

**S: toMap ve fromMap neden gerekli?**
C: Firestore NoSQL bir veritabanı olduğu için Dart nesnelerini doğrudan işleyemez. toMap() ile nesneyi Firestore'un anlayacağı Map formatına çeviriyorum. Okurken fromMap() ile gelen ham Map verisini tekrar Dart nesnesine dönüştürüyorum.

**S: StatefulWidget ne zaman, StatelessWidget ne zaman kullanıldı?**
C: Ekranda bir şeyin değişmesi gerekiyorsa StatefulWidget kullandım. Örneğin hayvan ekleme ekranında fotoğraf seçilince dairenin içinde fotoğrafın görünmesi gerekiyor — bu setState() gerektirir. Yalnızca veri gösteren ve değişmeyen ekranlar StatelessWidget olarak bırakıldı.

**S: Uygulamanın ölçeklenebilirliği nasıl?**
C: Firestore doküman tabanlı ve yatay ölçeklenen bir yapıya sahip. MVC mimarisi sayesinde yeni özellikler mevcut kodu bozmadan eklenebilir. Ancak fotoğrafların base64 olarak Firestore'a kaydedilmesi büyük ölçekte sorun yaratabilir; production ortamında Firebase Storage'a geçmek daha uygun olurdu.

**S: Hata yönetimi nasıl yapıldı?**
C: Firebase işlemlerinde try-catch kullanıldı. FirebaseAuthException ile gelen hata kodları Türkçe kullanıcı mesajlarına dönüştürüldü. Null safety için ?? operatörü kullanıldı. Büyük fotoğraflar için boyut kontrolü yapılıp kullanıcıya bilgi verildi.
