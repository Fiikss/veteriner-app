import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:veteriner_app/model/asi_model.dart';


class AsiServis {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> asiEkle(Asi asi) async{
    await _firestore
    .collection('Asilar')
    .doc(asi.id)
    .set(asi.toMap());
  }

  Stream <List<Asi>> hayvanAsilari (String hayvanID){
    return _firestore
    .collection('Asilar')
    .where('hayvanID', isEqualTo: hayvanID)
    .snapshots()
    .map((snapshot) => snapshot.docs .map((doc) => Asi.fromMap(doc.data(), doc.id))
    .toList());
  }

 //hekimin/asistanın tüm hayvanların yaklasan aşılarını görmek icin
Stream <List<Asi>> yaklasanAsilar (){
  final ucaysonra = DateTime.now().add(const Duration(days: 90));
  return _firestore
  .collection('Asilar')
  .where('sonrakiAsiTarihi', isGreaterThanOrEqualTo: DateTime.now())
  .where('sonrakiAsiTarihi', isLessThanOrEqualTo: ucaysonra)
  .snapshots()
  .map((snapshot) => snapshot.docs .map((doc) => Asi.fromMap(doc.data(), doc.id))
  .toList());
}


//kullanıcının kendi hayvanlarının yaklasan asilarini görmek için
Stream <List<Asi>> hayvanYaklasanAsilar (String hayvanID){

  return _firestore
  .collection('Asilar')
  .where('hayvanID', isEqualTo: hayvanID)
  .where('sonrakiAsiTarihi', isGreaterThanOrEqualTo: DateTime.now())
  .snapshots()
  .map((snapshot) => snapshot.docs .map((doc) => Asi.fromMap(doc.data(), doc.id))
  .toList());
}


Future <void> asiGuncelle(String asiID, String yeniDurum) async {
  await _firestore.collection('Asilar')
  .doc(asiID)
  .update({'asiDurumu': yeniDurum});

}

}