import 'package:cloud_firestore/cloud_firestore.dart';

class Randevu{
  String id;
  String musteriID;
  String hayvanID;
  String HekimID;
  String sikayet;
  String randevu_tur;
  String durum;
  double odeme;
  String odemeDurumu;
  DateTime tarih;
  String slotID;
  String saat;

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

  static Randevu fromMap(Map<String, dynamic> map, String dokumanId){
    return Randevu(
    id: dokumanId, 
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

