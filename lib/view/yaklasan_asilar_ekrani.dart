import 'package:flutter/material.dart';
import 'package:veteriner_app/model/asi_model.dart';
import 'package:veteriner_app/servis/asi_servis.dart';

class YaklasanAsilarEkrani extends StatefulWidget {
  const YaklasanAsilarEkrani({super.key});

  @override
  State<YaklasanAsilarEkrani> createState() => _YaklasanAsilarEkraniState();
}

class _YaklasanAsilarEkraniState extends State<YaklasanAsilarEkrani> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Asi>>(
        stream: AsiServis().yaklasanAsilar(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final asilar = snapshot.data!.where((a) => a.asiDurumu == 'Bekliyor').toList();
          if (asilar.isEmpty) return const Center(child: Text('Yaklaşan aşı yok'));
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: asilar.length,
            itemBuilder: (context, index) {
              final asi = asilar[index];
              final kacGun = asi.sonrakiAsiTarihi.difference(DateTime.now()).inDays;
              final renk = kacGun <= 2 ? Colors.red : Colors.orange;
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
                  subtitle: Text('${asi.hayvanAdi} • ${asi.sonrakiAsiTarihi.day}.${asi.sonrakiAsiTarihi.month}.${asi.sonrakiAsiTarihi.year}'),
                  trailing: Chip(
                    label: Text(kacGun == 0 ? 'Bugün' : '$kacGun gün'),
                    backgroundColor: renk.withValues(alpha: 0.15),
                    labelStyle: TextStyle(color: renk, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
