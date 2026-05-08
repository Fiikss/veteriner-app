import 'package:cloud_firestore/cloud_firestore.dart';

class Randevu{
  final String id;
  final String musteriID;
  final String hayvanID;
  final String HekimID;
  final String sikayet;
  final String randevu_tur;
  final String durum;
  final double odeme;
  final String odemeDurumu;
  final DateTime tarih;
  final String slotID;
  final String saat;

 Randevu({
    required this.id,
    required this.musteriID,
    required this.hayvanID,
    required this.HekimID,
    required this.sikayet,
    required this.randevu_tur,
    required this.durum,
    required this.odeme,
    required this.odemeDurumu,
    required this.tarih,
    required this.slotID,
    required this.saat,
  });

  factory Randevu.fromMap(Map<String, dynamic> map, String dokumanId){
    return Randevu(id: dokumanId, 
    musteriID: map['musteriID'] ?? '', 
    hayvanID: map['hayvanID'] ?? '', 
    HekimID: map['HekimID'] ?? '',  
    sikayet: map['sikayet'] ?? '', 
    randevu_tur: map['randevu_tur'] ?? 'Muayene', 
    durum: map['durum'] ?? 'Bekliyor', 
    odeme: (map['odeme'] ?? 0.0).toDouble(), 
    odemeDurumu: map['odemeDurumu'] ?? 'Bekliyor', 
    tarih: (map['tarih'] as Timestamp).toDate(),
    slotID: map['slotID'] ?? '',
    saat: map['saat'] ?? '',
    );
  }


  Map<String, dynamic> toMap(){
    return {
      'musteriID':musteriID,
      'hayvanID': hayvanID,
      'HekimID': HekimID,
      'durum': durum,
      'sikayet': sikayet,
      'randevu_tur': randevu_tur,
      'odeme': odeme,
      'odemeDurumu': odemeDurumu,
      'tarih' :tarih,
      'slotID': slotID,
      'saat': saat,
    };
  }




}

