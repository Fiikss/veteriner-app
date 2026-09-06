import 'package:cloud_firestore/cloud_firestore.dart';

class Asi {
String id;
String klinikID;
String hayvanID;
// Hayvanin sahibi. Guvenlik kurallarinin ek sorgu atmadan
// "bu kaydi sahibi okuyabilir" diyebilmesi icin kopyalanir.
String sahipID;
String hayvanAdi;
String asiAdi;
DateTime yapilmaTarihi;
DateTime sonrakiAsiTarihi;
String asiDurumu;
// Sunucu tarafli hatirlatma iki kere mesaj atmasin diye (VET-07).
bool hatirlatildi;

Asi({
    required this.id,
    required this.hayvanID,
    required this.hayvanAdi,
    required this.asiAdi,
    required this.sonrakiAsiTarihi,
    required this.yapilmaTarihi,
    required this.asiDurumu,
    this.klinikID = '',
    this.sahipID = '',
    this.hatirlatildi = false,
      });



    static Asi fromMap(Map<String, dynamic>map, String dokumanId){
      return Asi(
        id: dokumanId,
        klinikID: map['klinikID'] ?? '',
        hayvanID: map['hayvanID'] ?? '',
        sahipID: map['sahipID'] ?? '',
        hayvanAdi: map['hayvanAdi'] ?? '',
        asiAdi: map['asiAdi']  ?? '',
        sonrakiAsiTarihi: (map['sonrakiAsiTarihi'] as Timestamp).toDate(),
        yapilmaTarihi: (map['yapilmaTarihi'] as Timestamp).toDate(),
        asiDurumu: map['asiDurumu'] ?? 'Bekliyor',
        hatirlatildi: map['hatirlatildi'] ?? false,
      );
    }


    Map<String, dynamic> toMap() {
      return {
        'klinikID': klinikID,
        'hayvanID': hayvanID,
        'sahipID': sahipID,
        'hayvanAdi': hayvanAdi,
        'asiAdi':asiAdi,
        'yapilmaTarihi':yapilmaTarihi,
        'sonrakiAsiTarihi': sonrakiAsiTarihi,
        'asiDurumu': asiDurumu,
        'hatirlatildi': hatirlatildi,
    };
    }
}
