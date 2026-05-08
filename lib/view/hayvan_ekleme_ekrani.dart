import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:veteriner_app/model/hayvan_model.dart';
import 'package:veteriner_app/servis/hayvan_servis.dart';
import 'dart:typed_data';
import 'dart:convert';

class HayvanEkleEkran extends StatefulWidget {
  const HayvanEkleEkran({super.key});

  @override
  State<HayvanEkleEkran> createState() => _HayvanEkleEkranState();
}

class _HayvanEkleEkranState extends State<HayvanEkleEkran> {
  final adController = TextEditingController();
  final turController = TextEditingController();
  final irkController = TextEditingController();
  final kiloController = TextEditingController();
  final yasController = TextEditingController();
  final HayvanServis _servis = HayvanServis();
  XFile? _secilenFoto;
  Uint8List? _fotoBytes;

  Future<void> _fotografSec() async {
    final foto = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 15,
      maxWidth: 200,
      maxHeight: 200,
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

  InputDecoration _inputDecoration(String label, IconData ikon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(ikon, color: const Color(0xFF7C2D12)),
      filled: true,
      fillColor: const Color(0xFFFFF4ED),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F0),
      appBar: AppBar(
        title: const Text('Hayvan Ekle'),
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
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDD5),
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(color: const Color(0xFFEA580C), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC2410C).withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  image: _fotoBytes != null
                      ? DecorationImage(
                          image: MemoryImage(_fotoBytes!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _fotoBytes == null
                    ? const Icon(Icons.add_a_photo, color: Color(0xFF7C2D12), size: 36)
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _secilenFoto == null ? 'Fotoğraf ekle' : 'Fotoğraf seçildi ✓',
              style: TextStyle(
                color: _secilenFoto == null ? Colors.grey : const Color(0xFF7C2D12),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            TextField(controller: adController, decoration: _inputDecoration('Adı', Icons.pets)),
            const SizedBox(height: 12),
            TextField(controller: turController, decoration: _inputDecoration('Türü', Icons.category_outlined)),
            const SizedBox(height: 12),
            TextField(controller: irkController, decoration: _inputDecoration('Irkı', Icons.blur_on)),
            const SizedBox(height: 12),
            TextField(controller: kiloController, decoration: _inputDecoration('Kilosu (kg)', Icons.monitor_weight_outlined), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: yasController, decoration: _inputDecoration('Yaşı', Icons.cake_outlined), keyboardType: TextInputType.number),
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
                onPressed: () async {
                  final uid = FirebaseAuth.instance.currentUser!.uid;
                  String fotoUrl = '';
                  if (_secilenFoto != null) {
                    final bytes = await _secilenFoto!.readAsBytes();
                    fotoUrl = base64Encode(bytes);
                  }
                  final hayvan = Hayvan(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    sahipID: uid,
                    ad: adController.text,
                    tur: turController.text,
                    irk: irkController.text,
                    kilo: double.tryParse(kiloController.text) ?? 0,
                    yas: double.tryParse(yasController.text) ?? 0,
                    fotoUrl: fotoUrl,
                  );
                  await _servis.hayvanEkle(hayvan);
                  Navigator.pop(context);
                },
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
