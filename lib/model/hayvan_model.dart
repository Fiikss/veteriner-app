
class Hayvan{
  final String id;
  final String sahipID;
  final String ad;
  final String tur;
  final String irk;
  final double yas;
  final double kilo;
  final String fotoUrl;


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

  factory Hayvan.fromMap(Map<String, dynamic> map, String dokumanId){
    return Hayvan(id: dokumanId,
    sahipID: map['sahipID']?? '',
    ad: map['ad'] ?? '',
    tur: map['tur'] ?? '',
    irk: map['irk'] ?? '',
    kilo: (map['kilo'] ?? 0.0).toDouble(),
    yas: map['yas'] ?.toDouble() ?? 0,
    fotoUrl: map['fotoUrl'] ?? '',
    );
  }

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
