import 'package:flutter/material.dart';
import 'package:veteriner_app/model/tibbikayit_model.dart';
import 'package:veteriner_app/servis/tibbikayit_servis.dart';

class MusteriTibbiKayitlarEkrani extends StatelessWidget {
  final String hayvanID;
  final String hayvanAdi;
  const MusteriTibbiKayitlarEkrani({super.key, required this.hayvanID, required this.hayvanAdi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: Text('$hayvanAdi - Tıbbi Kayıtlar'),
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
      body: StreamBuilder<List<TibbiKayit>>(
        stream: TibbikayitServis().hayvanTibbiKayit(hayvanID),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final kayitlar = snapshot.data!;
          if (kayitlar.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medical_services_outlined, size: 64, color: Color(0xFFE53935)),
                  SizedBox(height: 12),
                  Text('Tıbbi kayıt yok', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: kayitlar.length,
            itemBuilder: (context, index) {
              final kayit = kayitlar[index];
              return Card(
                color: const Color.fromARGB(255, 229, 226, 226),
                elevation: 3,
                shadowColor: const Color(0xFFC62828).withValues(alpha: 0.18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB71C1C).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.medical_services, color: Color(0xFFB71C1C), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              kayit.kategori,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          Text(
                            '${kayit.tarih.day}.${kayit.tarih.month}.${kayit.tarih.year}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      _satir('Teşhis', kayit.teshis),
                      const SizedBox(height: 6),
                      _satir('Tedavi', kayit.tedavi),
                      const SizedBox(height: 6),
                      _satir('İlaçlar', kayit.ilaclar),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _satir(String baslik, String deger) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$baslik: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Expanded(child: Text(deger.isEmpty ? '-' : deger, style: const TextStyle(fontSize: 13))),
      ],
    );
  }
}
