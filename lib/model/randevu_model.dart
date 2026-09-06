import 'package:cloud_firestore/cloud_firestore.dart';

class Randevu{
  String id;
  String klinikID;
  String musteriID;
  String hayvanID;
  String hekimID;
  String sikayet;
  String randevuTur;
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
    required this.hekimID,
    required this.sikayet,
    required this.randevuTur,
    required this.durum,
    required this.odeme,
    required this.odemeDurumu,
    required this.tarih,
    required this.slotID,
    required this.saat,
    this.klinikID = '',
  });

  static Randevu fromMap(Map<String, dynamic> map, String dokumanId){
    return Randevu(
    id: dokumanId,
    klinikID: map['klinikID'] ?? '',
    musteriID: map['musteriID'] ?? '',
    hayvanID: map['hayvanID'] ?? '',
    // Eski kayitlarda alan adlari farkliydi; ikisi de okunuyor.
    hekimID: map['hekimID'] ?? map['HekimID'] ?? '',
    sikayet: map['sikayet'] ?? '',
    randevuTur: map['randevuTur'] ?? map['randevu_tur'] ?? 'Muayene',
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
      'klinikID': klinikID,
      'musteriID':musteriID,
      'hayvanID': hayvanID,
      'hekimID': hekimID,
      'durum': durum,
      'sikayet': sikayet,
      'randevuTur': randevuTur,
      'odeme': odeme,
      'odemeDurumu': odemeDurumu,
      'tarih' :tarih,
      'slotID': slotID,
      'saat': saat,
    };
  }




}
