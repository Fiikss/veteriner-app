import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:veteriner_app/view/asistan_ana_sayfa.dart';
import 'package:veteriner_app/view/hekim_ana_sayfa.dart';
import 'package:veteriner_app/view/kayit_ekrani.dart';
import 'package:veteriner_app/view/musteri_ana_sayfa.dart';

class Giris extends StatefulWidget {
  const Giris({super.key});

  @override
  State<Giris> createState() => _GirisState();
}

class _GirisState extends State<Giris> {
  final emailController = TextEditingController();
  final sifreController = TextEditingController();
  String secilenRol = 'musteri';
  bool sifreGizli = true;

  final Map<String, Map<String, dynamic>> 
  roller = {
    'musteri': {'label': 'Müşteri', 'icon': Icons.person},
    'hekim': {'label': 'Hekim', 'icon': Icons.medical_services},
    'asistan': {'label': 'Asistan', 'icon': Icons.support_agent},
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
backgroundColor: Color.,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF92400E),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: roller.entries.map((e) {
                  final secili = secilenRol == e.key;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => secilenRol = e.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: secili ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              e.value['icon'] as IconData,
                              color: secili
                                  ? const Color(0xFF7C2D12)
                                  : Colors.white70,
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              e.value['label'] as String,
                              style: TextStyle(
                                color: secili
                                    ? const Color(0xFF7C2D12)
                                    : Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
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
                    Text(
                      '${roller[secilenRol]!['label']} Girişi',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7C2D12),
                      ),
                    ),
                    const SizedBox(height: 25),
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
                            await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                              email: emailController.text,
                              password: sifreController.text,
                            );

                            final uid =
                                FirebaseAuth.instance.currentUser!.uid;
                            final doc = await FirebaseFirestore.instance
                                .collection('Kullanicilar')
                                .doc(uid)
                                .get();
                            final rol = doc.data()?['rol'] ?? 'musteri';

                            // Sadece müşteriler e-posta doğrulaması yapmak zorunda
                            if (rol == 'musteri' &&
                                !FirebaseAuth.instance.currentUser!.emailVerified) {
                              await FirebaseAuth.instance.signOut();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Lütfen e-postanızı doğrulayın.'),
                                ),
                              );
                              return;
                            }

                            if (rol != secilenRol) {
                              await FirebaseAuth.instance.signOut();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Bu hesap ${roller[secilenRol]!['label']} hesabı değil.',
                                  ),
                                ),
                              );
                              return;
                            }

                            if (!context.mounted) return;
                            if (rol == 'hekim') {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HekimAnaSayfa(),
                                ),
                              );
                            } else if (rol == 'asistan') {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AsistanAnaSayfa(),
                                ),
                              );
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MusteriAnaSayfa(),
                                ),
                              );
                            }
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
                              'Giriş Yap',
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
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => Kayit()),
                        ),
                        child: const Text(
                          'Hesabın yok mu? Kayıt Ol',
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
