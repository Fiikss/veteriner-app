import 'package:cloud_firestore/cloud_firestore.dart';


class TibbiKayit{
  String id;
  String klinikID;
  String hekimID;
  String hayvanID;
  String sahipID;
  String kategori;
  String teshis;
  String tedavi;
  String ilaclar;
  DateTime tarih;


TibbiKayit({
  required this.id,
  required this.hekimID,
  required this.hayvanID,
  required this.ilaclar,
  required this.kategori,
  required this.tedavi,
  required this.tarih,
  required this.teshis,
  this.klinikID = '',
  this.sahipID = '',
  });

  static TibbiKayit fromMap(Map<String, dynamic> map, String dokumanId){
    return TibbiKayit(
      id: dokumanId,
      klinikID: map['klinikID'] ?? '',
      hayvanID: map['hayvanID'] ?? '',
      sahipID: map['sahipID'] ?? '',
      // Eski alan adi (HekimID) goc oncesi kayitlar icin okunur.
      hekimID: map['hekimID'] ?? map['HekimID'] ?? '',
      kategori: map['kategori'] ?? 'Genel Muayene',
      teshis: map['teshis'] ?? '',
      ilaclar: map['ilaclar'] ?? '',
      tedavi: map['tedavi'] ?? '',
      tarih: (map['tarih'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic>toMap(){
    return {
      'klinikID': klinikID,
      'hayvanID': hayvanID,
      'sahipID': sahipID,
      'hekimID' : hekimID,
      'kategori': kategori,
      'teshis': teshis,
      'tedavi': tedavi,
      'ilaclar': ilaclar,
      'tarih': tarih,
    };
  }


}
