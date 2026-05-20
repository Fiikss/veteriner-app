import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:veteriner_app/model/slot_model.dart';
import 'package:veteriner_app/servis/slot_servis.dart';

class SlotEkleEkrani extends StatefulWidget {
  const SlotEkleEkrani({super.key});

  @override
  State<SlotEkleEkrani> createState() => _SlotEkleEkraniState();
}

class _SlotEkleEkraniState extends State<SlotEkleEkrani> {
  DateTime? secilenTarih;
  String secilenSaat = '09:00';
  final SlotServis _servis = SlotServis();

  final List<String> saatler = [
    '09:00', '10:00', '11:00', '12:00',
    '13:00', '14:00', '15:00', '16:00', '17:00',
  ];

  Future<void> _tarihSec() async {
    final tarih = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (tarih != null) setState(() => secilenTarih = tarih);
  }

  Future<void> _slotKaydet() async {
    if (secilenTarih == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tarih seçin')),
      );
      return;
    }
    final slot = Slot(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      hekimID: FirebaseAuth.instance.currentUser!.uid,
      tarih: secilenTarih!,
      saat: secilenSaat,
      dolu: false,
    );
    await _servis.slotEkle(slot);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saat Ekle'),
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFFB71C1C)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _tarihSec,
                icon: const Icon(Icons.calendar_today, color: Color(0xFFB71C1C)),
                label: Text(
                  secilenTarih == null
                      ? 'Tarih Seç'
                      : '${secilenTarih!.day}.${secilenTarih!.month}.${secilenTarih!.year}',
                  style: const TextStyle(color: Color(0xFFB71C1C), fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: secilenSaat,
              decoration: InputDecoration(
                labelText: 'Saat',
                prefixIcon: const Icon(Icons.access_time),
                filled: true,
                fillColor: const Color(0xFFFFEBEE),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: saatler.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (value) => setState(() => secilenSaat = value!),
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
                onPressed: _slotKaydet,
                child: const Text('Saat Oluştur', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
