import 'package:cloud_firestore/cloud_firestore.dart';


class TibbiKayit{
  final String id;
  final String HekimID;
  final String hayvanID;
  final String kategori;
  final String teshis;
  final String tedavi;
  final String ilaclar;
  final DateTime tarih;


  TibbiKayit({
     required this.id,
     required this.HekimID,
     required this.hayvanID,
     required this.ilaclar,
     required this.kategori,
     required this.tedavi,
     required this.tarih,
     required this.teshis,
  });

  factory TibbiKayit.fromMap(Map<String, dynamic> map, String dokumanId){
    return TibbiKayit(
      id: dokumanId,
      hayvanID: map['hayvanID'] ?? '',
      HekimID: map['HekimID'] ?? '',
      kategori: map['kategori'] ?? 'Genel Muayene',
      teshis: map['teshis'] ?? '',
      ilaclar: map['ilaclar'] ?? '',  
      tedavi: map['tedavi'] ?? '',
      tarih: (map['tarih'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic>toMap(){
    return {
      'hayvanID': hayvanID,
      'HekimID' : HekimID,
      'kategori': kategori,
      'teshis': teshis,
      'tedavi': tedavi,
      'ilaclar': ilaclar,
      'tarih': tarih,
    };
  }


}