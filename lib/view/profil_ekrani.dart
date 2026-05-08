import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class ProfilEkrani extends StatefulWidget {
  const ProfilEkrani({super.key});

  @override
  State<ProfilEkrani> createState() => _ProfilEkraniState();
}

class _ProfilEkraniState extends State<ProfilEkrani> {
  final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  final adSoyadController = TextEditingController();
  final telefonController = TextEditingController();
  XFile? _secilenFoto;
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
    final foto = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 15,
      maxWidth: 100,
      maxHeight: 100,
    );
    if (foto != null) {
      final bytes = await foto.readAsBytes();
      if (bytes.length > 900000) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fotoğraf çok büyük, lütfen daha küçük bir fotoğraf seçin.')),
          );
        }
        return;
      }
      setState(() {
        _secilenFoto = foto;
        _fotoBytes = bytes;
      });
    }
  }

  Future<void> _kaydet() async {
    if (uid.isEmpty) return;
    try {
      String fotoUrl = _mevcutFotoUrl;
      if (_secilenFoto != null) {
        fotoUrl = base64Encode(_fotoBytes!);
      }
      await FirebaseFirestore.instance.collection('Kullanicilar').doc(uid).update({
        'adSoyad': adSoyadController.text,
        'telefon': telefonController.text,
        'fotoUrl': fotoUrl,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil güncellendi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  InputDecoration _inputDecoration(String label, IconData ikon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(ikon, color: const Color(0xFF7C2D12)),
      filled: true,
      fillColor: const Color(0xFFFFF4ED),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F0),
      appBar: AppBar(
        title: const Text('Profilim'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7C2D12), Color(0xFFEA580C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
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
                    backgroundColor: const Color(0xFFFFEDD5),
                    backgroundImage: _fotoBytes != null
                        ? MemoryImage(_fotoBytes!)
                        : _mevcutFotoUrl.isNotEmpty
                            ? MemoryImage(base64Decode(_mevcutFotoUrl))
                            : null,
                    child: (_fotoBytes == null && _mevcutFotoUrl.isEmpty)
                        ? const Icon(Icons.person, size: 50, color: Color(0xFF7C2D12))
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF7C2D12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 3,
              shadowColor: const Color(0xFFC2410C).withValues(alpha: 0.18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.email, color: Color(0xFF7C2D12)),
                      title: const Text('E-posta', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(_email),
                    ),
                    ListTile(
                      leading: const Icon(Icons.work, color: Color(0xFF7C2D12)),
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
            TextField(controller: telefonController, decoration: _inputDecoration('Telefon', Icons.phone), keyboardType: TextInputType.phone),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C2D12),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  shadowColor: const Color(0xFFC2410C).withValues(alpha: 0.4),
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
