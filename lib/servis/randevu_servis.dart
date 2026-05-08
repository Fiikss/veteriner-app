import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:veteriner_app/model/randevu_model.dart';

class RandevuServis {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> randevuEkle(Randevu randevu) async {
    await _firestore
        .collection('Randevular')
        .doc(randevu.id)
        .set(randevu.toMap());
  }

Stream <List<Randevu>> hayvanRandevulari (String hayvanID){
  return _firestore
  .collection('Randevular')
  .where('hayvanID', isEqualTo: hayvanID)
  .snapshots()
  .map((snapshot) => snapshot.docs .map((doc) => Randevu.fromMap(doc.data(), doc.id))
  .toList());
}


Stream <List<Randevu>> tumRandevular(){
  return _firestore
  .collection('Randevular')
  .snapshots()
  .map((snapshot) => snapshot.docs .map((doc) => Randevu.fromMap(doc.data(), doc.id)) .toList());
}

Future<void> durumGuncelle(String randevuId, String yeniDurum) async {
  await _firestore
      .collection('Randevular')
      .doc(randevuId)
      .update({'durum': yeniDurum});
}

Stream<List<Randevu>> musteriRandevulari (String musteriID){
  return _firestore
  .collection('Randevular')
  .where('musteriID', isEqualTo: musteriID)
  .snapshots()
  .map((snapshot) => snapshot.docs .map((doc) => Randevu.fromMap(doc.data(),doc.id))
  .toList());
}

  Future<void> odemeGuncelle(String randevuId, double odeme, String odemeDurumu) async {
    await _firestore
        .collection('Randevular')
        .doc(randevuId)
        .update({'odeme': odeme, 'odemeDurumu': odemeDurumu});
  }

  Future<void> randevuSil(String randevuId) async {
    await _firestore.collection('Randevular').doc(randevuId).delete();
  }
} 