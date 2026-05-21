
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:veteriner_app/model/hayvan_model.dart';

class HayvanServis{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

   Future <void> hayvanEkle(Hayvan hayvan) async {
    await _firestore.collection('Hayvanlar')
    .doc(hayvan.id)
    .set(hayvan.toMap());
   }

//müşterinin hayvanını getirir
  Stream <List<Hayvan>> musteriHayvanlari (String sahipID){
    return _firestore
    .collection('Hayvanlar')
    .where('sahipID', isEqualTo: sahipID)
    .snapshots()
    .map((snapshot) => snapshot.docs
    .map((doc) => Hayvan.fromMap(doc.data(), doc.id))
    .toList());
  }

//uygulamadan girilen tüm hayvanların görüldüğü koleksiyon
  Stream <List<Hayvan>> tumHayvanlar(){
    return _firestore
    .collection('Hayvanlar')
    .snapshots()
    .map((snapshot) => snapshot.docs .map((doc) => Hayvan.fromMap(doc.data(), doc.id))
    .toList());
  }
  
  //hayvan düzenleme kısmından yapılan değişlikler için
  Future<void> hayvanGuncelle(Hayvan hayvan) async {
    await _firestore
        .collection('Hayvanlar')
        .doc(hayvan.id)
        .update(hayvan.toMap());
  }
//sçeilen hayvanı silmek için
  Future<void> hayvanSil(String hayvanID) async {
    await _firestore.collection('Hayvanlar').doc(hayvanID).delete();
  }
}