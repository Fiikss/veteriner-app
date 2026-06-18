import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:veteriner_app/model/asi_model.dart';
import 'package:veteriner_app/model/randevu_model.dart';

class BildirimPaneli extends StatelessWidget {
  final String? musteriID;
  const BildirimPaneli({super.key, this.musteriID});

  @override
  Widget build(BuildContext context) {
    final simdi = DateTime.now();
    final bugun = DateTime(simdi.year, simdi.month, simdi.day);
    final ucaysonra = bugun.add(const Duration(days: 90));

    return Drawer(
      width: 320,
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB71C1C), Color(0xFFE53935)],
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
                  ),),],),),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _baslik('Yaklaşan Aşılar (3 Ay Sonra)', Icons.vaccines),
                const SizedBox(height: 8),
                _yaklasanAsilarWidget(bugun, ucaysonra),
                const SizedBox(height: 16),
                _baslik('Yaklaşan Randevular (2 Hafta)', Icons.calendar_today),
                const SizedBox(height: 8),
                _bugunRandevularWidget(bugun),
                
              ],),),],),);}

  Widget _yaklasanAsilarWidget(DateTime bugun, DateTime ucaysonra) {
    if (musteriID == null) {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Asilar')
            .where('sonrakiAsiTarihi', isGreaterThanOrEqualTo: Timestamp.fromDate(bugun))
            .where('sonrakiAsiTarihi', isLessThanOrEqualTo: Timestamp.fromDate(ucaysonra))
            .snapshots(),
        builder: (context, snapshot) => _asilarIcerik(snapshot, bugun, ucaysonra),
      );
    }

    return FutureBuilder<List<String>>(
      future: FirebaseFirestore.instance
          .collection('Hayvanlar')
          .where('sahipID', isEqualTo: musteriID)
          .get()
          .then((snap) => snap.docs.map((d) => d.id).toList()),
      builder: (context, hayvanSnapshot) {
        if (!hayvanSnapshot.hasData) return const Center(child: CircularProgressIndicator());
        final hayvanIDs = hayvanSnapshot.data!;
        if (hayvanIDs.isEmpty) return _bosKart('Kayıtlı hayvan yok');
        // tarih filtresi client tarafında yapılıyor (composite index gerektirmemek için)
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Asilar')
              .where('hayvanID', whereIn: hayvanIDs)
              .snapshots(),
          builder: (context, snapshot) => _asilarIcerik(snapshot, bugun, ucaysonra),
        );
      },
    );
  }

  Widget _asilarIcerik(AsyncSnapshot<QuerySnapshot> snapshot, DateTime bugun, DateTime ucaysonra) {
    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
    final docs = snapshot.data!.docs.where((d) {
      final data = d.data() as Map<String, dynamic>;
      final tarih = (data['sonrakiAsiTarihi'] as Timestamp).toDate();
      return !tarih.isBefore(bugun) && !tarih.isAfter(ucaysonra);
    }).toList();
    if (docs.isEmpty) return _bosKart('3 ay içinde yaklaşan aşı yok');
    return Column(
      children: docs.map((doc) {
        final asi = Asi.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        final kacGun = asi.sonrakiAsiTarihi.difference(bugun).inDays;
        return _bildirimKarti(
          ikon: Icons.vaccines,
          renk: kacGun <= 2 ? Colors.red : Colors.orange,
          baslik: asi.asiAdi,
          altBaslik: asi.hayvanAdi,
          sag: kacGun == 0 ? 'Bugün' : '${asi.sonrakiAsiTarihi.day}.${asi.sonrakiAsiTarihi.month}.${asi.sonrakiAsiTarihi.year}',
        );
      }).toList(),
    );
  }

  Widget _bugunRandevularWidget(DateTime bugun) {
    final ikiHaftaSonra = bugun.add(const Duration(days: 14));

    final stream = musteriID != null
        ? FirebaseFirestore.instance
            .collection('Randevular')
            .where('musteriID', isEqualTo: musteriID)
            .snapshots()
        : FirebaseFirestore.instance
            .collection('Randevular')
            .where('tarih', isGreaterThanOrEqualTo: Timestamp.fromDate(bugun))
            .where('tarih', isLessThan: Timestamp.fromDate(ikiHaftaSonra))
            .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs.where((d) {
          final data = d.data() as Map<String, dynamic>;
          final tarih = (data['tarih'] as Timestamp).toDate();
          final durum = data['durum'] as String? ?? '';
          return durum == 'Onaylandı' && !tarih.isBefore(bugun) && tarih.isBefore(ikiHaftaSonra);
        }).toList();
        if (docs.isEmpty) return _bosKart('2 hafta içinde randevu yok');
        return Column(
          children: docs.map((doc) {
            final r = Randevu.fromMap(doc.data() as Map<String, dynamic>, doc.id);
            final kacGun = DateTime(r.tarih.year, r.tarih.month, r.tarih.day).difference(bugun).inDays;
            final sagYazi = kacGun == 0 ? 'Bugün ${r.saat}' : '${r.tarih.day}.${r.tarih.month}.${r.tarih.year}';
            return _bildirimKarti(
              ikon: Icons.calendar_month,
              renk: const Color(0xFFB71C1C),
              baslik: r.sikayet,
              altBaslik: r.randevu_tur,
              sag: sagYazi,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _baslik(String metin, IconData ikon) {
    return Row(
      children: [
        Icon(ikon, size: 16, color: const Color(0xFFB71C1C)),
        const SizedBox(width: 6),
        Text(
          metin,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Color(0xFFB71C1C),
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
                Text(baslik, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(altBaslik, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
          Text(sag, style: TextStyle(color: renk, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
