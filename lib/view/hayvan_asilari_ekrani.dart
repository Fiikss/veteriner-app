import 'package:flutter/material.dart';
import 'package:veteriner_app/model/asi_model.dart';
import 'package:veteriner_app/servis/asi_servis.dart';

class HayvanAsilariEkrani extends StatefulWidget {
  final String hayvanID;
  final String hayvanAdi;
  final bool canAdd;
  const HayvanAsilariEkrani({super.key, required this.hayvanID, required this.hayvanAdi, this.canAdd = true});

  @override
  State<HayvanAsilariEkrani> createState() => _HayvanAsilariEkraniState();
}

class _HayvanAsilariEkraniState extends State<HayvanAsilariEkrani> {
  DateTime? yapilmaTarihi;
  DateTime? sonrakiAsiTarihi;
  final asiAdiController = TextEditingController();
  String asiDurumu = 'Bekliyor';
  final AsiServis _servis = AsiServis();

  Color _durumRengi(String durum) {
    switch (durum) {
      case 'Yapıldı':
        return Colors.green;
      case 'İptal':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.hayvanAdi} - Aşı Geçmişi'),
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.canAdd)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: asiDurumu,
                    decoration: InputDecoration(
                      labelText: 'Aşı Durumu',
                      prefixIcon: const Icon(Icons.info_outline),
                      filled: true,
                      fillColor: const Color(0xFFFFEBEE),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 16),
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
                        asiAdiController.clear();
                        setState(() {
                          asiDurumu = 'Bekliyor';
                          yapilmaTarihi = null;
                          sonrakiAsiTarihi = null;
                        });
                      },
                      child: const Text('Aşı Ekle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Aşı Geçmişi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFFB71C1C))),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<List<Asi>>(
              stream: _servis.hayvanAsilari(widget.hayvanID),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final asilar = snapshot.data!;
                if (asilar.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.vaccines, size: 64, color: Color(0xFFE53935)),
                        SizedBox(height: 12),
                        Text('Aşı kaydı yok', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: asilar.map((asi) {
                    final renk = _durumRengi(asi.asiDurumu);
                    return Card(
                      elevation: 3,
                      shadowColor: const Color(0xFFC62828).withValues(alpha: 0.18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: renk.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.vaccines, color: renk),
                        ),
                        title: Text(asi.asiAdi, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          'Sonraki: ${asi.sonrakiAsiTarihi.day}.${asi.sonrakiAsiTarihi.month}.${asi.sonrakiAsiTarihi.year}',
                        ),
                        trailing: asi.asiDurumu == 'Bekliyor'
                            ? PopupMenuButton<String>(
                                onSelected: (value) => _servis.asiGuncelle(asi.id, value),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'Yapıldı', child: Text('Yapıldı')),
                                  const PopupMenuItem(value: 'İptal', child: Text('İptal')),
                                ],
                                child: Chip(
                                  label: const Text('Bekliyor'),
                                  backgroundColor: Colors.orange.withValues(alpha: 0.15),
                                  labelStyle: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                                ),
                              )
                            : Chip(
                                label: Text(asi.asiDurumu),
                                backgroundColor: renk.withValues(alpha: 0.15),
                                labelStyle: TextStyle(color: renk, fontWeight: FontWeight.bold),
                              ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
