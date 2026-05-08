import 'package:cloud_firestore/cloud_firestore.dart';

class Asi {
  final String id;
  final String hayvanID;
  final String hayvanAdi;
  final String asiAdi;
  final DateTime yapilmaTarihi;
  final DateTime sonrakiAsiTarihi;
  final String asiDurumu; 

  Asi({
    required this.id,
    required this.hayvanID,
    required this.hayvanAdi,
    required this.asiAdi,
    required this.sonrakiAsiTarihi,
    required this.yapilmaTarihi,
    required this.asiDurumu,
      });



    factory Asi.fromMap(Map<String, dynamic>map, String dokumanId){
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