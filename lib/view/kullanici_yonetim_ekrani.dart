import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:veteriner_app/view/akis_hatasi.dart';
import 'package:veteriner_app/firebase_options.dart';
import 'package:veteriner_app/servis/oturum_servis.dart';

class KullaniciYonetimEkrani extends StatelessWidget {
  const KullaniciYonetimEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personel Yönetimi'),
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Kullanicilar')
            .where('klinikID', isEqualTo: Oturum.klinikID)
            .where('rol', whereIn: ['asistan', 'hekim']).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return AkisHatasi(hata: snapshot.error);
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
                      ? const Color(0xFFB71C1C)
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: Text(rol == 'hekim' ? 'Hekim' : 'Asistan'),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: rol == 'hekim'
                            ? const Color(0xFFB71C1C)
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _personelSilDialog(context, personeller[index].id, data['adSoyad'] ?? data['email'] ?? ''),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFB71C1C),
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
        builder: (context, setState) => 
        AlertDialog(
          backgroundColor: Colors.white,
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
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFB71C1C)),
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB71C1C),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                try {
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
                    'klinikID': Oturum.klinikID,
                    'email': emailController.text.trim(),
                    'adSoyad': adSoyadController.text.trim(),
                    'telefon': '',
                    'rol': secilenRol,
                  });
                  await ikinciBaglanti.delete();
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${adSoyadController.text} başarıyla eklendi.',
                      ),
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata: $e')),
                  );
                }
              },
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  void _personelSilDialog(BuildContext context, String personelId, String adSoyad) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Personeli Sil'),
        content: Text('$adSoyad adlı personeli silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('Kullanicilar')
                    .doc(personelId)
                    .delete();
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$adSoyad silindi.')),
                );
              } catch (e) {
                if (!ctx.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Hata: $e')),
                );
              }
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}