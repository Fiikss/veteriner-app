import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:veteriner_app/servis/foto_servis.dart';

class ProfilEkrani extends StatefulWidget {
  const ProfilEkrani({super.key});

  @override
  State<ProfilEkrani> createState() => _ProfilEkraniState();
}

class _ProfilEkraniState extends State<ProfilEkrani> {
  final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  final adSoyadController = TextEditingController();
  final telefonController = TextEditingController();
  Uint8List? _fotoBytes;
  String _mevcutFotoUrl = '';
  String _email = '';
  String _rol = '';

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  Future<void> _verileriYukle() async {
    if (uid.isEmpty) return;
    final doc = await FirebaseFirestore.instance.collection('Kullanicilar').doc(uid).get();
    final data = doc.data();
    setState(() {
      adSoyadController.text = data?['adSoyad'] ?? '';
      telefonController.text = data?['telefon'] ?? '';
      _email = data?['email'] ?? '';
      _rol = data?['rol'] ?? '';
      _mevcutFotoUrl = data?['fotoUrl'] ?? '';
    });
  }

  Future<void> _fotografSec() async {
    try {
      final bytes = await FotoServis().fotografSec(maxWidth: 100, maxHeight: 100);
      if (bytes != null) {
        setState(() => _fotoBytes = bytes);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _kaydet() async {
    if (uid.isEmpty) return;
    try {
      String fotoUrl = _mevcutFotoUrl;
      if (_fotoBytes != null) fotoUrl = base64Encode(_fotoBytes!);

      await FirebaseFirestore.instance.collection('Kullanicilar').doc(uid).update({
        'adSoyad': adSoyadController.text,
        'telefon': telefonController.text,
        'fotoUrl': fotoUrl,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil güncellendi')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  InputDecoration _inputDecoration(String label, IconData ikon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(ikon, color: const Color(0xFFB71C1C)),
      filled: true,
      fillColor: const Color.fromARGB(255, 229, 226, 226),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text('Profilim'),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFFB71C1C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _fotografSec,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFFFFFFFF),
                    backgroundImage: _fotoBytes != null
                        ? MemoryImage(_fotoBytes!)
                        : _mevcutFotoUrl.isNotEmpty
                            ? MemoryImage(base64Decode(_mevcutFotoUrl))
                            : null,
                    child: (_fotoBytes == null && _mevcutFotoUrl.isEmpty)
                        ? const Icon(Icons.person, size: 50, color: Color(0xFFB71C1C))
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Color(0xFFB71C1C), shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color:  Color(0xFFFFFFFF), size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              color: const Color.fromARGB(255, 229, 226, 226),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.email, color: Color(0xFFB71C1C)),
                      title: const Text('E-posta', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(_email),
                    ),
                    ListTile(
                      leading: const Icon(Icons.work, color: Color(0xFFB71C1C)),
                      title: const Text('Rol', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(_rol),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(controller: adSoyadController, decoration: _inputDecoration('Ad Soyad', Icons.person)),
            const SizedBox(height: 12),
            TextField(
              controller: telefonController,
              decoration: _inputDecoration('Telefon', Icons.phone),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB71C1C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _kaydet,
                child: const Text('Kaydet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}