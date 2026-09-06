import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:veteriner_app/model/klinik_model.dart';

class KlinikServis {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Kayit ekranindaki klinik secimi icin.
  Future<List<Klinik>> aktifKlinikler() async {
    final snapshot = await _firestore
        .collection('Klinikler')
        .where('aktif', isEqualTo: true)
        .get();
    final liste = snapshot.docs
        .map((doc) => Klinik.fromMap(doc.data(), doc.id))
        .toList();
    liste.sort((a, b) => a.ad.compareTo(b.ad));
    return liste;
  }

  Future<Klinik?> klinikGetir(String klinikID) async {
    final doc = await _firestore.collection('Klinikler').doc(klinikID).get();
    if (!doc.exists) return null;
    return Klinik.fromMap(doc.data()!, doc.id);
  }
}
