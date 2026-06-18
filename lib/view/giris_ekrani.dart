import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _beniHatirla = false;

  @override
  void initState() {
    super.initState();
    _kayitliEmailiYukle();
  }

  Future<void> _kayitliEmailiYukle() async {
    final prefs = await SharedPreferences.getInstance();
    final kayitliEmail = prefs.getString('kayitli_email');
    final kayitliSifre = prefs.getString('kayitli_sifre');
    if (kayitliEmail != null) {
      setState(() {
        emailController.text = kayitliEmail;
        sifreController.text = kayitliSifre ?? '';
        _beniHatirla = true;
      });
    }
  }

  final roller = {
    'musteri': {'label': 'Müşteri', 'icon': Icons.person},
    'hekim': {'label': 'Hekim', 'icon': Icons.medical_services},
    'asistan': {'label': 'Asistan', 'icon': Icons.support_agent},
  };

  void _hataGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mesaj)));
  }

  Future<void> _sifremiUnuttum() async {
    final emailController2 = TextEditingController(text: emailController.text.trim());
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Şifremi Unuttum'),
        content: TextField(
          controller: emailController2,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'E-posta adresiniz',
            prefixIcon: const Icon(Icons.email_outlined),
            filled: true,
            fillColor: Color.fromARGB(255, 229, 226, 226),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFB71C1C)),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB71C1C),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final email = emailController2.text.trim();
              if (email.isEmpty) return;
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                _hataGoster('Şifre sıfırlama e-postası gönderildi.');
              } on FirebaseAuthException {
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                _hataGoster('Bu e-posta adresi kayıtlı değil.');
              }
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  Future<void> _girisYap() async {
    final email = emailController.text.trim();
    final sifre = sifreController.text;

    if (email.isEmpty || sifre.isEmpty) {
      _hataGoster('E-posta ve şifre boş bırakılamaz.');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      if (_beniHatirla) {
        await prefs.setString('kayitli_email', email);
        await prefs.setString('kayitli_sifre', sifre);
      } else {
        await prefs.remove('kayitli_email');
        await prefs.remove('kayitli_sifre');
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: sifre);

      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance.collection('Kullanicilar').doc(uid).get();
      final rol = doc.data()?['rol'] ?? 'musteri';

      if (rol == 'musteri' && !FirebaseAuth.instance.currentUser!.emailVerified) {
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        _hataGoster('Lütfen e-postanızı doğrulayın.');
        return;
      }

      if (rol != secilenRol) {
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        _hataGoster('Bu hesap ${roller[secilenRol]!['label']} hesabı değil.');
        return;
      }

      if (!mounted) return;

      if (rol == 'hekim') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HekimAnaSayfa()));
      } else if (rol == 'asistan') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AsistanAnaSayfa()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MusteriAnaSayfa()));
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      const hatalar = {
        'invalid-email': 'Geçersiz e-posta adresi.',
        'user-not-found': 'E-posta veya şifre hatalı.',
        'wrong-password': 'E-posta veya şifre hatalı.',
        'invalid-credential': 'E-posta veya şifre hatalı.',
        'user-disabled': 'Bu hesap devre dışı bırakılmış.',
        'too-many-requests': 'Çok fazla hatalı deneme. Lütfen bekleyin.',
        'network-request-failed': 'İnternet bağlantısı kontrol edin.',
      };
      _hataGoster(hatalar[e.code] ?? 'Giriş başarısız. Lütfen tekrar deneyin.');
    }
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFD32F2F),
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
                              color: secili ? const Color(0xFFB71C1C) : Colors.white70,
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              e.value['label'] as String,
                              style: TextStyle(
                                color: secili ? const Color(0xFFB71C1C) : Colors.white70,
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
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFB71C1C)),
                    ),
                    const SizedBox(height: 25),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email_outlined),
                        hintText: 'E-Posta',
                        filled: true,
                        fillColor:Color.fromARGB(255, 229, 226, 226),
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
                        fillColor: Color.fromARGB(255, 229, 226, 226),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(sifreGizli ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => sifreGizli = !sifreGizli),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _beniHatirla,
                              onChanged: (val) => setState(() => _beniHatirla = val!),
                              activeColor: const Color(0xFFB71C1C),
                            ),
                            const Text('Beni hatırla', style: TextStyle(fontSize: 13, color: Color(0xFFB71C1C))),
                          ],
                        ),
                        TextButton(
                          onPressed: _sifremiUnuttum,
                          child: const Text('Şifremi unuttum', style: TextStyle(color: Color(0xFFB71C1C), fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB71C1C),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _girisYap,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Giriş Yap', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Kayit())),
                        child: const Text('Hesabın yok mu? Kayıt Ol', style: TextStyle(color: Color(0xFFB71C1C))),
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
