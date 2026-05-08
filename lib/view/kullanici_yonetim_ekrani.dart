import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:veteriner_app/firebase_options.dart';

class KullaniciYonetimEkrani extends StatelessWidget {
  const KullaniciYonetimEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personel Yönetimi'),
        backgroundColor: const Color(0xFF7C2D12),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Kullanicilar')
            .where('rol', whereIn: ['asistan', 'hekim']).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final personeller = snapshot.data!.docs;
          if (personeller.isEmpty) {
            return const Center(child: Text('Henüz personel eklenmemiş'));
          }
          return ListView.builder(
            itemCount: personeller.length,
            itemBuilder: (context, index) {
              final data = personeller[index].data() as Map<String, dynamic>;
              final rol = data['rol'] ?? '';
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: rol == 'hekim'
                      ? const Color(0xFF7C2D12)
                      : Colors.orange,
                  child: Icon(
                    rol == 'hekim'
                        ? Icons.medical_services
                        : Icons.support_agent,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                title: Text(data['adSoyad']?.isNotEmpty == true
                    ? data['adSoyad']
                    : data['email'] ?? ''),
                subtitle: Text(data['email'] ?? ''),
                trailing: Chip(
                  label: Text(rol == 'hekim' ? 'Hekim' : 'Asistan'),
                  backgroundColor: rol == 'hekim'
                      ? const Color(0xFF7C2D12).withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    color: rol == 'hekim'
                        ? const Color(0xFF7C2D12)
                        : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF7C2D12),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Personel Ekle'),
        onPressed: () => _personelEkleDialog(context),
      ),
    );
  }

  void _personelEkleDialog(BuildContext context) {
    final emailController = TextEditingController();
    final sifreController = TextEditingController();
    final adSoyadController = TextEditingController();
    String secilenRol = 'asistan';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Yeni Personel Ekle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: adSoyadController,
                  decoration: const InputDecoration(
                    labelText: 'Ad Soyad',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-Posta',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: sifreController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Şifre',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: secilenRol,
                  decoration: const InputDecoration(labelText: 'Rol'),
                  items: const [
                    DropdownMenuItem(value: 'asistan', child: Text('Asistan')),
                    DropdownMenuItem(value: 'hekim', child: Text('Hekim')),
                  ],
                  onChanged: (val) => setState(() => secilenRol = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C2D12),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                try {
                  // İkinci Firebase bağlantısıyla mevcut oturumu kapatmadan hesap oluştur
                  final ikinciBaglanti = await Firebase.initializeApp(
                    name: 'personelKayit',
                    options: DefaultFirebaseOptions.currentPlatform,
                  );
                  final sonuc = await FirebaseAuth.instanceFor(app: ikinciBaglanti)
                      .createUserWithEmailAndPassword(
                    email: emailController.text.trim(),
                    password: sifreController.text.trim(),
                  );
                  await FirebaseFirestore.instance
                      .collection('Kullanicilar')
                      .doc(sonuc.user!.uid)
                      .set({
                    'email': emailController.text.trim(),
                    'adSoyad': adSoyadController.text.trim(),
                    'telefon': '',
                    'rol': secilenRol,
                  });
                  await ikinciBaglanti.delete();
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${adSoyadController.text} başarıyla eklendi.',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Hata: $e')),
                    );
                  }
                }
              },
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }
}
