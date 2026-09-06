import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:veteriner_app/model/hayvan_model.dart';
import 'package:veteriner_app/servis/oturum_servis.dart';

class HayvanServis{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

   Future <void> hayvanEkle(Hayvan hayvan) async {
    // Klinik kimligi tek yerde ekleniyor.
    final veri = hayvan.toMap()..['klinikID'] = Oturum.klinikID;
    await _firestore.collection('Hayvanlar')
    .doc(hayvan.id)
    .set(veri);
   }

  Stream <List<Hayvan>> musteriHayvanlari (String sahipID){
    return _firestore
    .collection('Hayvanlar')
    .where('klinikID', isEqualTo: Oturum.klinikID)
    .where('sahipID', isEqualTo: sahipID)
    .snapshots()
    .map((snapshot) => snapshot.docs
    .map((doc) => Hayvan.fromMap(doc.data(), doc.id))
    .toList());
  }

  Stream <List<Hayvan>> tumHayvanlar(){
    return _firestore
    .collection('Hayvanlar')
    .where('klinikID', isEqualTo: Oturum.klinikID)
    .snapshots()
    .map((snapshot) => snapshot.docs .map((doc) => Hayvan.fromMap(doc.data(), doc.id))
    .toList());
  }

  Future<void> hayvanGuncelle(Hayvan hayvan) async {
    // Klinik kimligi guncellemede tasinmaz: kayit bir kez ait oldugu klinikte kalir.
    final veri = hayvan.toMap()..remove('klinikID');
    await _firestore
        .collection('Hayvanlar')
        .doc(hayvan.id)
        .update(veri);
  }
  Future<void> hayvanSil(String hayvanID) async {
    await _firestore.collection('Hayvanlar').doc(hayvanID).delete();
  }
}
