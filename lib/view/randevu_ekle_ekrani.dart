import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:veteriner_app/model/randevu_model.dart';
import 'package:veteriner_app/model/slot_model.dart';
import 'package:veteriner_app/servis/randevu_servis.dart';
import 'package:veteriner_app/servis/slot_servis.dart';

class RandevuEkleEkrani extends StatefulWidget {
  final String hayvanID;
  const RandevuEkleEkrani({super.key, required this.hayvanID});

  @override
  State<RandevuEkleEkrani> createState() => _RandevuEkleEkraniState();
}

class _RandevuEkleEkraniState extends State<RandevuEkleEkrani> {
  final sikayetController = TextEditingController();
  String secilenTur = 'Muayene';
  Slot? secilenSlot;
  final RandevuServis _randevuServis = RandevuServis();
  final SlotServis _slotServis = SlotServis();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Randevu Al'),
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: sikayetController,
              decoration: InputDecoration(
                labelText: 'Şikayet',
                prefixIcon: const Icon(Icons.report_problem_outlined),
                filled: true,
                fillColor: const Color(0xFFFFEBEE),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: secilenTur,
              decoration: InputDecoration(
                labelText: 'Randevu Türü',
                floatingLabelBehavior: FloatingLabelBehavior.never,
                prefixIcon: const Icon(Icons.category_outlined),
                filled: true,
                fillColor: const Color(0xFFFFEBEE),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: ['Muayene', 'Aşı', 'Tırnak Kesimi', 'Tüy Bakımı']
                  .map((tur) => DropdownMenuItem(value: tur, child: Text(tur)))
                  .toList(),
              onChanged: (value) => setState(() => secilenTur = value!),
            ),
            const SizedBox(height: 16),
            const Text(
              'Uygun Saatler',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFFB71C1C)),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<Slot>>(
                stream: _slotServis.bosSlotlar(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final slotlar = snapshot.data!;
                  if (slotlar.isEmpty) {
                    return const Center(child: Text('Uygun saat yok'));
                  }
                  return ListView.builder(
                    itemCount: slotlar.length,
                    itemBuilder: (context, index) {
                      final slot = slotlar[index];
                      final secili = secilenSlot?.id == slot.id;
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.only(bottom: 8),
                        color: secili ? const Color(0xFFB71C1C) : Colors.white,
                        child: ListTile(
                          leading: Icon(
                            Icons.access_time,
                            color: secili ? Colors.white : const Color(0xFFB71C1C),
                          ),
                          title: Text(
                            '${slot.tarih.day}.${slot.tarih.month}.${slot.tarih.year}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: secili ? Colors.white : Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            slot.saat,
                            style: TextStyle(color: secili ? Colors.white70 : Colors.grey),
                          ),
                          trailing: secili
                              ? const Icon(Icons.check_circle, color: Colors.white)
                              : null,
                          onTap: () => setState(() => secilenSlot = slot),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB71C1C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                onPressed: secilenSlot == null
                    ? null
                    : () async {
                        final randevu = Randevu(
                          id: DateTime.now().microsecondsSinceEpoch.toString(),
                          musteriID: FirebaseAuth.instance.currentUser!.uid,
                          hayvanID: widget.hayvanID,
                          HekimID: secilenSlot!.hekimID,
                          sikayet: sikayetController.text,
                          randevu_tur: secilenTur,
                          durum: 'Bekliyor',
                          odeme: 0.0,
                          odemeDurumu: 'Bekliyor',
                          tarih: secilenSlot!.tarih,
                          slotID: secilenSlot!.id,
                          saat: secilenSlot!.saat,
                        );
                        // randevuyu kaydet ve slotu dolu olarak işaretle
                        await _randevuServis.randevuEkle(randevu);
                        await _slotServis.slotDoldur(secilenSlot!.id);
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      },
                child: const Text('Randevu Kaydet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
