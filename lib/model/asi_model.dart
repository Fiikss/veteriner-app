import 'package:cloud_firestore/cloud_firestore.dart';

class Asi {
String id;
String hayvanID;
String hayvanAdi;
String asiAdi;
DateTime yapilmaTarihi;
DateTime sonrakiAsiTarihi;
String asiDurumu; 

Asi({
    required this.id,
    required this.hayvanID,
    required this.hayvanAdi,
    required this.asiAdi,
    required this.sonrakiAsiTarihi,
    required this.yapilmaTarihi,
    required this.asiDurumu,
      });



    static Asi fromMap(Map<String, dynamic>map, String dokumanId){
      return Asi(
        id: dokumanId,
        hayvanID: map['hayvanID'] ?? '',
        hayvanAdi: map['hayvanAdi'] ?? '',
        asiAdi: map['asiAdi']  ?? '',
        sonrakiAsiTarihi: (map['sonrakiAsiTarihi'] as Timestamp).toDate(),
        yapilmaTarihi: (map['yapilmaTarihi'] as Timestamp).toDate(),
        asiDurumu: map['asiDurumu'] ?? 'Bekliyor', 
      );
    }  


    Map<String, dynamic> toMap() {
      return {
        'hayvanID': hayvanID,
        'hayvanAdi': hayvanAdi,
        'asiAdi':asiAdi,
        'yapilmaTarihi':yapilmaTarihi,
        'sonrakiAsiTarihi': sonrakiAsiTarihi,
        'asiDurumu': asiDurumu,
    };
    }
}