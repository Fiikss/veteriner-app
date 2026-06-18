import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:veteriner_app/model/slot_model.dart';


class SlotServis {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


Future<void> slotEkle(Slot slot) async{
  await _firestore 
  .collection('Slotlar')
  .doc(slot.id)
  .set(slot.toMap());

}

  Stream <List<Slot>> bosSlotlar (){
    return _firestore
    .collection('Slotlar')
    .where('dolu', isEqualTo:  false)
    .snapshots()
    .map((snapshot) => snapshot.docs .map((doc) => Slot.fromMap(doc.data(), doc.id))
    .toList()
    );

  }
  
  Future<void> slotDoldur(String slotID) async{
    await _firestore
    .collection('Slotlar')
    .doc(slotID)
    .update({'dolu': true});
  }

  Future<void> slotBosalt(String slotID) async {
    await _firestore
    .collection('Slotlar')
    .doc(slotID)
    .update({'dolu': false});
  }

Stream<List<Slot>> hekimSlotlari(String hekimID) {
  return _firestore
      .collection('Slotlar')
      .where('hekimID', isEqualTo: hekimID)
      .where('dolu', isEqualTo: false)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Slot.fromMap(doc.data(), doc.id))
          .toList());
}


}