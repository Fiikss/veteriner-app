
class Hayvan{
  String id;
  String sahipID;
  String ad;
  String tur;
  String irk;
  double yas;
  double kilo;
  String fotoUrl;


  Hayvan({
    required this.id,
    required this.sahipID,
    required this.ad,
    required this.tur,
    required this.irk,
    required this.kilo,
    required this.yas,
    required this.fotoUrl,

  });

//firestoredan gelen ham veri, dokumanId firestore'daki belge ID

  static Hayvan fromMap(Map<String, dynamic> map, String dokumanId){
    return Hayvan(
    id: dokumanId,
    sahipID: map['sahipID']?? '',
    ad: map['ad'] ?? '',
    tur: map['tur'] ?? '',
    irk: map['irk'] ?? '',
    kilo: (map['kilo'] ?? 0.0).toDouble(),
    yas: map['yas'] ?.toDouble() ?? 0,
    fotoUrl: map['fotoUrl'] ?? '',
    );
  }

//nesneyi veriye çeviriyoruz firestore a yazarken kullanılır.

  Map <String, dynamic> toMap(){
    return {
      'sahipID': sahipID,
      'ad': ad,
      'tur': tur,
      'yas': yas,
      'irk': irk,
      'kilo': kilo,
      'fotoUrl': fotoUrl,
    };
  }
}
