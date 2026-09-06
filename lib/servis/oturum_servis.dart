import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:veteriner_app/model/kullanici_model.dart';

/// Aktif oturumun kullanici, rol ve klinik bilgisini tutar.
/// Giriste [baslat], cikista [temizle] cagrilir.
/// Servisler klinik kimligini hep buradan okur.
class Oturum {
  Oturum._();

  static Kullanici? _kullanici;

  /// Oturum yuklendi mi ve hesap bir klinige bagli mi.
  static bool get hazir =>
      _kullanici != null && _kullanici!.klinikID.isNotEmpty;

  static Kullanici get kullanici {
    final k = _kullanici;
    if (k == null) {
      throw StateError('Oturum baslatilmadi. Once Oturum.baslat() cagrilmali.');
    }
    return k;
  }

  static String get kullaniciID => kullanici.id;

  static String get rol => kullanici.rol;

  static bool get personel => rol == 'hekim' || rol == 'asistan';

  /// Aktif klinigin kimligi. Servislerdeki her sorgu bunu kullanir.
  static String get klinikID {
    final id = kullanici.klinikID;
    if (id.isEmpty) {
      throw StateError('Bu hesap bir klinige bagli degil.');
    }
    return id;
  }

  /// Kullanici kaydini okuyup oturumu doldurur.
  static Future<Kullanici> baslat() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError('Giris yapilmamis.');
    }
    final doc = await FirebaseFirestore.instance
        .collection('Kullanicilar')
        .doc(uid)
        .get();
    if (!doc.exists) {
      throw StateError('Kullanici kaydi bulunamadi.');
    }
    _kullanici = Kullanici.fromMap(doc.data()!, doc.id);
    return _kullanici!;
  }

  static void temizle() {
    _kullanici = null;
  }
}
