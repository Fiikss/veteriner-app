import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:veteriner_app/model/tibbikayit_model.dart';
import 'package:veteriner_app/servis/tibbikayit_servis.dart';

class TibbiKayitEkleEkrani extends StatefulWidget {
  final String hayvanID;
  const TibbiKayitEkleEkrani({super.key, required this.hayvanID});

  @override
  State<TibbiKayitEkleEkrani> createState() => _TibbiKayitEkleEkraniState();
}

class _TibbiKayitEkleEkraniState extends State<TibbiKayitEkleEkrani> {
  DateTime? secilenTarih;
  String kategori = 'Muayene';
  final teshisController = TextEditingController();
  final tedaviController = TextEditingController();
  final ilacController = TextEditingController();
  final TibbikayitServis _servis = TibbikayitServis();

  InputDecoration _inputDecoration(String label, IconData ikon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(ikon),
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
      appBar: AppBar(
        title: const Text('Tıbbi Kayıt Girişi'),
        backgroundColor: const Color(0xFF7C2D12),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: kategori,
              decoration: InputDecoration(
                labelText: 'Kategori',
                prefixIcon: const Icon(Icons.category_outlined),
                filled: true,
                fillColor: const Color(0xFFFFF4ED),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: ['Muayene', 'Aşı', 'Operasyon', 'İlaç Tedavisi']
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: (value) => setState(() => kategori = value!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: teshisController,
              decoration: _inputDecoration('Teşhis', Icons.search),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tedaviController,
              decoration: _inputDecoration('Tedavi', Icons.healing),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ilacController,
              decoration: _inputDecoration('İlaçlar', Icons.medication_outlined),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFF7C2D12)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final tarih = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (tarih != null) setState(() => secilenTarih = tarih);
                },
                icon: const Icon(Icons.calendar_today, color: Color(0xFF7C2D12)),
                label: Text(
                  secilenTarih == null
                      ? 'Tarih Seç'
                      : '${secilenTarih!.day}.${secilenTarih!.month}.${secilenTarih!.year}',
                  style: const TextStyle(color: Color(0xFF7C2D12), fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C2D12),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final kayit = TibbiKayit(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    HekimID: FirebaseAuth.instance.currentUser!.uid,
                    hayvanID: widget.hayvanID,
                    ilaclar: ilacController.text,
                    kategori: kategori,
                    tedavi: tedaviController.text,
                    teshis: teshisController.text,
                    tarih: secilenTarih ?? DateTime.now(),
                  );
                  await _servis.tibbikayitEkle(kayit);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
                child: const Text('Kaydet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
