
class Kullanici{
  final String id;
  final String adSoyad;
  final String email;
  final String telefon;
  final String rol;

  Kullanici({
    required this.id,
    required this.adSoyad,
    required this.email,
    required this.telefon,
    required this.rol,
  });


  factory Kullanici.fromMap(Map<String, dynamic> map, String dokumanId){
    return Kullanici(id: dokumanId, adSoyad: map['adSoyad' ] ?? '', 
    email: map['email' ]?? '', 
    telefon: map['telefon'] ?? '', 
    rol: map['rol'] ?? 'musteri');
  }

  Map <String, dynamic> toMap(){
    return{
      'adSoyad': adSoyad,
      'email': email,
      'telefon': telefon,
      'rol': rol,
    };
  }
}
