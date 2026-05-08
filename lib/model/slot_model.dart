
import 'package:cloud_firestore/cloud_firestore.dart';

class Slot {
  final String id;
  final String hekimID;
  final DateTime tarih;
  final String saat;
  final bool dolu;


  Slot({
    required this.id,
    required this.hekimID,
    required this.tarih,
    required this.saat,
    required this.dolu,

      });

  factory Slot.fromMap(Map<String, dynamic> map, String dokumanId) {
    return Slot(
      id: dokumanId,
      hekimID: map['hekimID'] ?? '',
      tarih: (map['tarih'] as Timestamp).toDate(),
      saat: map['saat'] ?? '',
      dolu: map['dolu'] ?? false,
    );
  }


    Map<String, dynamic> toMap() {
      return {
        'hekimID': hekimID,
        'tarih': tarih,
        'saat':saat,
        'dolu': dolu,
    };
    }
}