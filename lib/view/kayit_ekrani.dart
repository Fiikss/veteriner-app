import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:veteriner_app/model/klinik_model.dart';
import 'package:veteriner_app/servis/klinik_servis.dart';
//kullanıcı kaydı ekranı
class Kayit extends StatefulWidget {
  const Kayit({super.key});

  @override
  State<Kayit> createState() => _KayitState();
}

class _KayitState extends State<Kayit> {
  final emailController = TextEditingController();
  final sifreController = TextEditingController();
  final adSoyadController = TextEditingController();
  bool sifreGizli = true;

  // Hesap bir klinige bagli olmak zorunda: klinik kimligi olmayan
  // kullanici hicbir kaydi goremez.
  final KlinikServis _klinikServis = KlinikServis();
  List<Klinik> _klinikler = [];
  Klinik? _secilenKlinik;
  bool _kliniklerYukleniyor = true;

  @override
  void initState() {
    super.initState();
    _klinikleriYukle();
  }

  Future<void> _klinikleriYukle() async {
    try {
      final liste = await _klinikServis.aktifKlinikler();
      if (!mounted) return;
      setState(() {
        _klinikler = liste;
        _kliniklerYukleniyor = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _kliniklerYukleniyor = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Klinik listesi yüklenemedi.')),
      );
    }
  }

  Future<void> _kayitOl() async {
    if (_secilenKlinik == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen kayıt olacağınız kliniği seçin.')),
      );
      return;
    }
    try {
      final sonuc = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: sifreController.text,
      );
      await FirebaseFirestore.instance.collection('Kullanicilar').doc(sonuc.user!.uid).set({
        'klinikID': _secilenKlinik!.id,
        'email': emailController.text,
        'adSoyad': adSoyadController.text,
        'telefon': '',
        'rol': 'musteri',
      });
      await sonuc.user!.sendEmailVerification(); 
      await FirebaseAuth.instance.signOut(); 
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doğrulama maili gönderildi. E-postanızı onaylayıp giriş yapabilirsiniz.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  InputDecoration _inputDecoration(String hint, IconData ikon) {
    return InputDecoration(
      prefixIcon: Icon(ikon),
      hintText: hint,
      filled: true,
      fillColor: Color.fromARGB(255, 229, 226, 226),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB71C1C),
      body: Column(
        children: [
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFB71C1C),
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(color: Color(0x6615163A), blurRadius: 40, spreadRadius: 6),
              ],
            ),
            child: const Icon(Icons.pets, color: Colors.white, size: 50),
          ),
          const SizedBox(height: 8),
          const Text('Veteriner Kliniği', style: TextStyle(color: Colors.white70, fontSize: 15)),
          const Text('VetApp', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(30, 30, 30, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hesap Oluştur',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFB71C1C))),
                    const SizedBox(height: 25),
                    TextField(controller: adSoyadController, decoration: _inputDecoration('Ad Soyad', Icons.person_outline)),

                    const SizedBox(height: 16),
                    if (_kliniklerYukleniyor)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_klinikler.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 229, 226, 226),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          'Kayıtlı klinik bulunamadı. Kliniğinizle iletişime geçin.',
                          style: TextStyle(fontSize: 13),
                        ),
                      )
                    else
                      DropdownButtonFormField<Klinik>(
                        isExpanded: true,
                        decoration: _inputDecoration('Klinik Seçin', Icons.local_hospital_outlined),
                        dropdownColor: const Color.fromARGB(255, 229, 226, 226),
                        items: _klinikler
                            .map((klinik) => DropdownMenuItem(
                                  value: klinik,
                                  child: Text(klinik.ad, overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (deger) => setState(() => _secilenKlinik = deger),
                      ),

                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration('E-Posta', Icons.email_outlined),
                    ),
                    
                    const SizedBox(height: 16),
                    TextField(
                      controller: sifreController,
                      obscureText: sifreGizli,
                      decoration: _inputDecoration('Şifre', Icons.lock_outline).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(sifreGizli ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => sifreGizli = !sifreGizli),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB71C1C),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _kayitOl,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Kayıt Ol', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Zaten hesabın var mı? Giriş Yap',
                            style: TextStyle(color: Color(0xFFB71C1C))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
