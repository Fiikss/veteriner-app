import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7C2D12),
      body: Column(
        children: [
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF7C2D12),
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x6615163A),
                  blurRadius: 40,
                  spreadRadius: 6,
                ),
              ],
            ),
            child: const Icon(Icons.pets, color: Colors.white, size: 50),
          ),
          const SizedBox(height: 8),
          const Text(
            'Veteriner Kliniği',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const Text(
            'VetApp',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
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
                    const Text(
                      'Hesap Oluştur',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7C2D12),
                      ),
                    ),
                    const SizedBox(height: 25),
                    TextField(
                      controller: adSoyadController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline),
                        hintText: 'Ad Soyad',
                        filled: true,
                        fillColor: const Color(0xFFFFF4ED),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email_outlined),
                        hintText: 'E-Posta',
                        filled: true,
                        fillColor: const Color(0xFFFFF4ED),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: sifreController,
                      obscureText: sifreGizli,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline),
                        hintText: 'Şifre',
                        filled: true,
                        fillColor: const Color(0xFFFFF4ED),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            sifreGizli
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () =>
                              setState(() => sifreGizli = !sifreGizli),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C2D12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          try {
                            final sonuc = await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                              email: emailController.text,
                              password: sifreController.text,
                            );
                            await FirebaseFirestore.instance
                                .collection('Kullanicilar')
                                .doc(sonuc.user!.uid)
                                .set({
                              'email': emailController.text,
                              'adSoyad': adSoyadController.text,
                              'telefon': '',
                              'rol': 'musteri',
                            });
                            await sonuc.user!.sendEmailVerification();
                            await FirebaseAuth.instance.signOut();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Doğrulama maili gönderildi. E-postanızı onaylayıp giriş yapabilirsiniz.',
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Kayıt Ol',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                        child: const Text(
                          'Zaten hesabın var mı? Giriş Yap',
                          style: TextStyle(color: Color(0xFF7C2D12)),
                        ),
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
