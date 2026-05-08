import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:veteriner_app/model/asi_model.dart';
import 'package:veteriner_app/model/randevu_model.dart';

class BildirimPaneli extends StatelessWidget {
  const BildirimPaneli({super.key});

  @override
  Widget build(BuildContext context) {
    final simdi = DateTime.now();
    final bugun = DateTime(simdi.year, simdi.month, simdi.day);
    final yediGunSonra = bugun.add(const Duration(days: 7));

    return Drawer(
      width: 320,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7C2D12), Color(0xFFEA580C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.notifications, color: Colors.white, size: 24),
                SizedBox(width: 10),
                Text(
                  'Bildirimler',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _baslik('Yaklaşan Aşılar (7 gün)', Icons.vaccines),
                const SizedBox(height: 8),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Asilar')
                      .where('sonrakiAsiTarihi',
                          isGreaterThanOrEqualTo: Timestamp.fromDate(bugun))
                      .where('sonrakiAsiTarihi',
                          isLessThanOrEqualTo: Timestamp.fromDate(yediGunSonra))
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data!.docs
                        .where((d) =>
                            (d.data() as Map<String, dynamic>)['asiDurumu'] ==
                            'Bekliyor')
                        .toList();
                    if (docs.isEmpty) {
                      return _bosKart('7 gün içinde yaklaşan aşı yok');
                    }
                    return Column(
                      children: docs.map((doc) {
                        final asi = Asi.fromMap(
                          doc.data() as Map<String, dynamic>,
                          doc.id,
                        );
                        final kacGun = asi.sonrakiAsiTarihi
                            .difference(bugun)
                            .inDays;
                        return _bildirimKarti(
                          ikon: Icons.vaccines,
                          renk: kacGun <= 2 ? Colors.red : Colors.orange,
                          baslik: asi.asiAdi,
                          altBaslik: asi.hayvanAdi,
                          sag: kacGun == 0
                              ? 'Bugün'
                              : '$kacGun gün sonra',
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _baslik('Bugünkü Randevular', Icons.calendar_today),
                const SizedBox(height: 8),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Randevular')
                      .where('tarih',
                          isGreaterThanOrEqualTo: Timestamp.fromDate(bugun))
                      .where('tarih',
                          isLessThan: Timestamp.fromDate(
                              bugun.add(const Duration(days: 1))))
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) {
                      return _bosKart('Bugün randevu yok');
                    }
                    return Column(
                      children: docs.map((doc) {
                        final r = Randevu.fromMap(
                          doc.data() as Map<String, dynamic>,
                          doc.id,
                        );
                        return _bildirimKarti(
                          ikon: Icons.calendar_month,
                          renk: const Color(0xFF7C2D12),
                          baslik: r.sikayet,
                          altBaslik: r.randevu_tur,
                          sag: r.saat,
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _baslik(String metin, IconData ikon) {
    return Row(
      children: [
        Icon(ikon, size: 16, color: const Color(0xFF7C2D12)),
        const SizedBox(width: 6),
        Text(
          metin,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Color(0xFF7C2D12),
          ),
        ),
      ],
    );
  }

  Widget _bosKart(String metin) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        metin,
        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
      ),
    );
  }

  Widget _bildirimKarti({
    required IconData ikon,
    required Color renk,
    required String baslik,
    required String altBaslik,
    required String sag,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: renk.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: renk.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: renk.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(ikon, color: renk, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(baslik,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                Text(altBaslik,
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
          Text(
            sag,
            style: TextStyle(
                color: renk, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
