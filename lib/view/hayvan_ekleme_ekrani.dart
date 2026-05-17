import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:veteriner_app/model/hayvan_model.dart';
import 'package:veteriner_app/servis/hayvan_servis.dart';
import 'package:veteriner_app/servis/foto_servis.dart';

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
  Uint8List? _fotoBytes;

  // fotoğraf seçme işlemi FotoServis üzerinden yapılıyor
  Future<void> _fotografSec() async {
    try {
      final bytes = await FotoServis().fotografSec();
      if (bytes != null) {
        setState(() => _fotoBytes = bytes);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  InputDecoration _inputDecoration(String label, IconData ikon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(ikon, color: const Color(0xFFB71C1C)),
      filled: true,
      fillColor: const Color(0xFFFFEBEE),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  // hayvanı firestore'a kaydet
  Future<void> _kaydet() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    String fotoUrl = '';
    if (_fotoBytes != null) {
      fotoUrl = base64Encode(_fotoBytes!);
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
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEBEE),
      appBar: AppBar(

        title: const Text('Hayvan Ekle'),

        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB71C1C), Color(0xFFE53935)],
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
                  color: const Color(0xFFFFCDD2),
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(color: const Color(0xFFE53935), width: 2),
                  boxShadow: [


                    BoxShadow(
                      color: const Color(0xFFC62828).withValues(alpha: 0.2),
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
                    ? const Icon(Icons.add_a_photo, color: Color(0xFFB71C1C), size: 36)
                    : null,
              ),
            ),
            const SizedBox(height: 8),


            Text(
              _fotoBytes == null ? 'Fotoğraf ekle' : 'Fotoğraf seçildi ✓',
              style: TextStyle(
                color: _fotoBytes == null ? Colors.grey : const Color(0xFFB71C1C),
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
                  backgroundColor: const Color(0xFFB71C1C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  shadowColor: const Color(0xFFC62828).withValues(alpha: 0.4),
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
