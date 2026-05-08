import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:veteriner_app/model/tibbikayit_model.dart';

class TibbikayitServis {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<void> tibbikayitEkle(TibbiKayit tibbikayit) async{
   await _firestore 
   .collection('TibbiKayitlar')
   .doc(tibbikayit.id)
   .set(tibbikayit.toMap());
}

Stream <List<TibbiKayit>> hayvanTibbiKayit (String hayvanID){
  return _firestore 
  .collection('TibbiKayitlar')
  .where('hayvanID', isEqualTo: hayvanID)
  .snapshots()
  .map((snapshot) => snapshot.docs .map((doc) => TibbiKayit.fromMap(doc.data(), doc.id))
  .toList());
}


Stream <List<TibbiKayit>> tumTibbiKayit(){
  return _firestore
  .collection('TibbiKayitlar')
  .snapshots()
  .map((snapshot) => snapshot.docs .map((doc) => TibbiKayit.fromMap(doc.data(), doc.id)) .toList());
}

}
