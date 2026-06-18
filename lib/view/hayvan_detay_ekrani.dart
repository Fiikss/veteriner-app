import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:veteriner_app/model/hayvan_model.dart';
import 'package:veteriner_app/servis/foto_servis.dart';
import 'package:veteriner_app/servis/hayvan_servis.dart';
import 'package:veteriner_app/view/hayvan_asilari_ekrani.dart';
import 'package:veteriner_app/view/musteri_tibbi_kayitlar_ekrani.dart';

class HayvanDetayEkrani extends StatefulWidget {
  final Hayvan hayvan;
  const HayvanDetayEkrani({super.key, required this.hayvan});

  @override
  State<HayvanDetayEkrani> createState() => _HayvanDetayEkraniState();
}

class _HayvanDetayEkraniState extends State<HayvanDetayEkrani> {
  late final TextEditingController adController;
  late final TextEditingController turController;
  late final TextEditingController irkController;
  late final TextEditingController kiloController;
  late final TextEditingController yasController;
  final HayvanServis _servis = HayvanServis();
  Uint8List? _fotoBytes;

  @override
  void initState() {
    super.initState();
    adController = TextEditingController(text: widget.hayvan.ad);
    turController = TextEditingController(text: widget.hayvan.tur);
    irkController = TextEditingController(text: widget.hayvan.irk);
    kiloController = TextEditingController(text: widget.hayvan.kilo.toString());
    yasController = TextEditingController(text: widget.hayvan.yas.toString());
  }

  // galeriden fotoğraf seç
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
      fillColor:const Color.fromARGB(255, 229, 226, 226),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: Text('${widget.hayvan.ad} - Düzenle'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final onay = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Hayvanı Sil'),
                  content: Text('${widget.hayvan.ad} silinsin mi?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Sil', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (onay == true) {
                await _servis.hayvanSil(widget.hayvan.id);
                navigator.pop();
              }
            },
          ),
        ],
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
                  color: const Color(0xFFFFFFFF),
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
            const SizedBox(height: 20),
            TextField(controller: adController, decoration: _inputDecoration('Adı', Icons.pets)),
            const SizedBox(height: 12),
            TextField(controller: turController, decoration: _inputDecoration('Türü', Icons.category_outlined)),
            const SizedBox(height: 12),
            TextField(controller: irkController, decoration: _inputDecoration('Irkı', Icons.blur_on)),
            const SizedBox(height: 12),
            TextField(controller: kiloController, decoration: _inputDecoration('Kilosu', Icons.monitor_weight_outlined), keyboardType: TextInputType.number),
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
                onPressed: () async {
                  String fotoUrl = widget.hayvan.fotoUrl;
                  if (_fotoBytes != null) {
                    fotoUrl = base64Encode(_fotoBytes!);
                  }
                  final guncellenmis = Hayvan(
                    id: widget.hayvan.id,
                    sahipID: widget.hayvan.sahipID,
                    ad: adController.text,
                    tur: turController.text,
                    irk: irkController.text,
                    kilo: double.tryParse(kiloController.text) ?? 0,
                    yas: double.tryParse(yasController.text) ?? 0,
                    fotoUrl: fotoUrl,
                  );
                  
                  // güncellemeyi kaydet ve geri dön
                  await _servis.hayvanGuncelle(guncellenmis);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
                child: const Text('Kaydet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFB71C1C)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HayvanAsilariEkrani(
                          hayvanID: widget.hayvan.id,
                          hayvanAdi: widget.hayvan.ad,
                          canAdd: false,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.vaccines, color: Color(0xFFB71C1C)),
                    label: const Text('Aşı Geçmişi', style: TextStyle(color: Color(0xFFB71C1C))),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFB71C1C)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MusteriTibbiKayitlarEkrani(
                          hayvanID: widget.hayvan.id,
                          hayvanAdi: widget.hayvan.ad,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.medical_services_outlined, color: Color(0xFFB71C1C)),
                    label: const Text('Tıbbi Kayıtlar', style: TextStyle(color: Color(0xFFB71C1C))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
