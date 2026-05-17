import 'package:flutter/material.dart';
import 'package:veteriner_app/model/asi_model.dart';
import 'package:veteriner_app/servis/asi_servis.dart';
import 'package:veteriner_app/view/asi_ekle_ekrani.dart';

class HayvanAsilariEkrani extends StatefulWidget {
  final String hayvanID;
  final String hayvanAdi;
  final bool canAdd;
  const HayvanAsilariEkrani({super.key, required this.hayvanID, required this.hayvanAdi, this.canAdd = true});

  @override
  State<HayvanAsilariEkrani> createState() => _HayvanAsilariEkraniState();
}

class _HayvanAsilariEkraniState extends State<HayvanAsilariEkrani> {
  Color _durumRengi(String durum) {
    switch (durum) {
      case 'Yapıldı': return Colors.green;
      case 'İptal': return Colors.red;
      default: return Colors.orange;
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
      body: StreamBuilder<List<Asi>>(
        stream: AsiServis().hayvanAsilari(widget.hayvanID),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final asilar = snapshot.data!;
          if (asilar.isEmpty) return const Center(child: Text('Aşı kaydı yok'));
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: asilar.length,
            itemBuilder: (context, index) {
              final asi = asilar[index];
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
                          onSelected: (value) => AsiServis().asiGuncelle(asi.id, value),
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
            },
          );
        },
      ),
      floatingActionButton: widget.canAdd
          ? FloatingActionButton(
              backgroundColor: const Color(0xFFB71C1C),
              foregroundColor: Colors.white,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AsiEkleEkrani(hayvanID: widget.hayvanID, hayvanAdi: widget.hayvanAdi),
                ),
              ),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
