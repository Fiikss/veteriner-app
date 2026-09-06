class Kullanici{
String id;
String klinikID;
String adSoyad;
String email;
String telefon;
String rol;

Kullanici({
  required this.id,
  required this.adSoyad,
  required this.email,
  required this.telefon,
  required this.rol,
  this.klinikID = '',
});


static Kullanici fromMap(Map<String, dynamic> map, String dokumanId){
    return Kullanici(
    id: dokumanId,
    klinikID: map['klinikID'] ?? '',
    adSoyad: map['adSoyad' ] ?? '',
    email: map['email' ]?? '',
    telefon: map['telefon'] ?? '',
    rol: map['rol'] ?? 'musteri');
}

Map <String, dynamic> toMap(){
    return{
      'klinikID': klinikID,
      'adSoyad': adSoyad,
      'email': email,
      'telefon': telefon,
      'rol': rol,
    };
  }
}
