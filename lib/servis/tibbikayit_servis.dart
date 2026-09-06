import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:veteriner_app/model/tibbikayit_model.dart';
import 'package:veteriner_app/servis/oturum_servis.dart';

class TibbikayitServis {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<void> tibbikayitEkle(TibbiKayit tibbikayit) async{
   // Klinik ve sahip bilgisi hayvan kaydindan miras alinir.
   final hayvan = await _firestore.collection('Hayvanlar').doc(tibbikayit.hayvanID).get();
   if (!hayvan.exists) {
     throw Exception('Tibbi kayit eklenecek hayvan bulunamadi.');
   }
   final hayvanVerisi = hayvan.data()!;
   final veri = tibbikayit.toMap()
     ..['klinikID'] = hayvanVerisi['klinikID'] ?? Oturum.klinikID
     ..['sahipID'] = hayvanVerisi['sahipID'] ?? '';

   await _firestore
   .collection('TibbiKayitlar')
   .doc(tibbikayit.id)
   .set(veri);
}

Stream <List<TibbiKayit>> hayvanTibbiKayit (String hayvanID){
  Query<Map<String, dynamic>> sorgu = _firestore
  .collection('TibbiKayitlar')
  .where('klinikID', isEqualTo: Oturum.klinikID)
  .where('hayvanID', isEqualTo: hayvanID);

  // Musteri sadece kendi hayvanini gorur; sahiplik sorguda olmali.
  if (!Oturum.personel) {
    sorgu = sorgu.where('sahipID', isEqualTo: Oturum.kullaniciID);
  }

  return sorgu
  .snapshots()
  .map((snapshot) => snapshot.docs .map((doc) => TibbiKayit.fromMap(doc.data(), doc.id))
  .toList());
}


Stream <List<TibbiKayit>> tumTibbiKayit(){
  return _firestore
  .collection('TibbiKayitlar')
  .where('klinikID', isEqualTo: Oturum.klinikID)
  .snapshots()
  .map((snapshot) => snapshot.docs .map((doc) => TibbiKayit.fromMap(doc.data(), doc.id)) .toList());
}

}
