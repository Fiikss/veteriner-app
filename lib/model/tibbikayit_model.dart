import 'package:cloud_firestore/cloud_firestore.dart';


class TibbiKayit{
  String id;
  String HekimID;
  String hayvanID;
  String kategori;
  String teshis;
  String tedavi;
  String ilaclar;
  DateTime tarih;


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

  static TibbiKayit fromMap(Map<String, dynamic> map, String dokumanId){
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