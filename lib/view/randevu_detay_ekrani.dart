import 'package:flutter/material.dart';
import 'package:veteriner_app/model/randevu_model.dart';
import 'package:veteriner_app/servis/randevu_servis.dart';

class RandevuDetayEkrani extends StatelessWidget {
  final Randevu randevu;
  const RandevuDetayEkrani({super.key, required this.randevu});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Randevu Detayı'),
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _satirOlustur(Icons.report_problem_outlined, 'Şikayet', randevu.sikayet),
                    _satirOlustur(Icons.category_outlined, 'Tür', randevu.randevu_tur),
                    _satirOlustur(Icons.calendar_today, 'Tarih', '${randevu.tarih.day}.${randevu.tarih.month}.${randevu.tarih.year}'),
                    _satirOlustur(Icons.access_time, 'Saat', randevu.saat),
                    _satirOlustur(Icons.info_outline, 'Durum', randevu.durum),
                    _satirOlustur(Icons.payment, 'Ödeme', '₺${randevu.odeme}'),
                    _satirOlustur(Icons.check_circle_outline, 'Ödeme Durumu', randevu.odemeDurumu),
                  ],
                ),
              ),
            ),
            if (randevu.durum == 'Bekliyor') ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        await RandevuServis().durumGuncelle(randevu.id, 'Onaylandı');
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Onayla', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        await RandevuServis().durumGuncelle(randevu.id, 'Reddedildi');
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Reddet', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _satirOlustur(IconData ikon, String baslik, String deger) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(ikon, color: const Color(0xFFB71C1C), size: 20),
          const SizedBox(width: 12),
          Text('$baslik:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(child: Text(deger, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
