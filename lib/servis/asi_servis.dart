import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:veteriner_app/model/asi_model.dart';
import 'package:veteriner_app/servis/oturum_servis.dart';


class AsiServis {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> asiEkle(Asi asi) async{
    // Klinik ve sahip bilgisi hayvan kaydindan miras alinir; boylece
    // asi kaydinin hangi klinige ve kime ait oldugu elle girilemez.
    final hayvan = await _firestore.collection('Hayvanlar').doc(asi.hayvanID).get();
    if (!hayvan.exists) {
      throw Exception('Asi eklenecek hayvan kaydi bulunamadi.');
    }
    final hayvanVerisi = hayvan.data()!;
    final veri = asi.toMap()
      ..['klinikID'] = hayvanVerisi['klinikID'] ?? Oturum.klinikID
      ..['sahipID'] = hayvanVerisi['sahipID'] ?? '';

    await _firestore
    .collection('Asilar')
    .doc(asi.id)
    .set(veri);
  }

  Stream <List<Asi>> hayvanAsilari (String hayvanID){
    Query<Map<String, dynamic>> sorgu = _firestore
    .collection('Asilar')
    .where('klinikID', isEqualTo: Oturum.klinikID)
    .where('hayvanID', isEqualTo: hayvanID);

    // Guvenlik kurallari sorguyu filtrelemez: sahiplik iddiasi sorgunun
    // kendisinde olmazsa musterinin okumasi tamamen reddedilir.
    if (!Oturum.personel) {
      sorgu = sorgu.where('sahipID', isEqualTo: Oturum.kullaniciID);
    }

    return sorgu
    .snapshots()
    .map((snapshot) {
      final liste = snapshot.docs.map((doc) => Asi.fromMap(doc.data(), doc.id)).toList();
      liste.sort((a, b) => b.yapilmaTarihi.compareTo(a.yapilmaTarihi));
      return liste;
    });
  }

Stream <List<Asi>> yaklasanAsilar (){
  final ucaysonra = DateTime.now().add(const Duration(days: 90));
  return _firestore
  .collection('Asilar')
  .where('klinikID', isEqualTo: Oturum.klinikID)
  .where('sonrakiAsiTarihi', isGreaterThanOrEqualTo: DateTime.now())
  .where('sonrakiAsiTarihi', isLessThanOrEqualTo: ucaysonra)
  .snapshots()
  .map((snapshot) {
    final liste = snapshot.docs.map((doc) => Asi.fromMap(doc.data(), doc.id)).toList();
    liste.sort((a, b) => a.sonrakiAsiTarihi.compareTo(b.sonrakiAsiTarihi));
    return liste;
  });
}


Stream <List<Asi>> hayvanYaklasanAsilar (String hayvanID){

  return _firestore
  .collection('Asilar')
  .where('klinikID', isEqualTo: Oturum.klinikID)
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
