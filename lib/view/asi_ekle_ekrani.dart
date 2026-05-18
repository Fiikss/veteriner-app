import 'package:flutter/material.dart';
import 'package:veteriner_app/model/asi_model.dart';
import 'package:veteriner_app/servis/asi_servis.dart';

class AsiEkleEkrani extends StatefulWidget {
  final String hayvanID;
  final String hayvanAdi;
  const AsiEkleEkrani({super.key, required this.hayvanID, required this.hayvanAdi});

  @override
  State<AsiEkleEkrani> createState() => _AsiEkleEkraniState();
}

class _AsiEkleEkraniState extends State<AsiEkleEkrani> {
  DateTime? yapilmaTarihi;
  DateTime? sonrakiAsiTarihi;
  final asiAdiController = TextEditingController();
  String asiDurumu = 'Bekliyor';
  final AsiServis _servis = AsiServis();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aşı Kayıt'),
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: asiDurumu,
              decoration: InputDecoration(
                labelText: 'Aşı Durumu',
                floatingLabelBehavior: FloatingLabelBehavior.never,
                prefixIcon: const Icon(Icons.info_outline),
                filled: true,
                fillColor: const Color(0xFFFFEBEE),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: ['Bekliyor', 'Yapıldı', 'İptal']
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (value) => setState(() => asiDurumu = value!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: asiAdiController,
              decoration: InputDecoration(
                labelText: 'Aşı Adı',
                prefixIcon: const Icon(Icons.vaccines),
                filled: true,
                fillColor: const Color(0xFFFFEBEE),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (asiDurumu == 'Yapıldı') ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFB71C1C)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final tarih = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (tarih != null) setState(() => yapilmaTarihi = tarih);
                  },
                  icon: const Icon(Icons.calendar_today, color: Color(0xFFB71C1C)),
                  label: Text(
                    yapilmaTarihi == null
                        ? 'Yapılan Aşı Tarihi'
                        : '${yapilmaTarihi!.day}.${yapilmaTarihi!.month}.${yapilmaTarihi!.year}',
                    style: const TextStyle(color: Color(0xFFB71C1C), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFFB71C1C)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final tarih = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (tarih != null) setState(() => sonrakiAsiTarihi = tarih);
                },
                icon: const Icon(Icons.event, color: Color(0xFFB71C1C)),
                label: Text(
                  sonrakiAsiTarihi == null
                      ? 'Sonraki Aşı Tarihi'
                      : '${sonrakiAsiTarihi!.day}.${sonrakiAsiTarihi!.month}.${sonrakiAsiTarihi!.year}',
                  style: const TextStyle(color: Color(0xFFB71C1C), fontWeight: FontWeight.bold),
                ),
              ),
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
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final asi = Asi(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    hayvanID: widget.hayvanID,
                    hayvanAdi: widget.hayvanAdi,
                    asiAdi: asiAdiController.text,
                    asiDurumu: asiDurumu,
                    yapilmaTarihi: yapilmaTarihi ?? DateTime.now(),
                    sonrakiAsiTarihi: sonrakiAsiTarihi ?? DateTime.now(),
                  );
                  await _servis.asiEkle(asi);
                  navigator.pop();
                },
                child: const Text('Aşı Ekle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),),],),),);}}
