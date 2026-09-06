class Klinik {
  String id;
  String ad;
  String adres;
  String telefon;
  bool aktif;
  String klinikID;

  Klinik({
    required this.id,
    required this.ad,
    this.adres = '',
    this.telefon = '',
    this.aktif = true,
    required this.klinikID,
  });

  static Klinik fromMap(Map<String, dynamic> map, String dokumanId) {
    return Klinik(
      id: dokumanId,
      ad: map['ad'] ?? '',
      adres: map['adres'] ?? '',
      telefon: map['telefon'] ?? '',
      aktif: map['aktif'] ?? true,
      klinikID: map['klinikID'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ad': ad,
      'adres': adres,
      'telefon': telefon,
      'aktif': aktif,
      'klinikID': klinikID,
    };
  }
}
