import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:veteriner_app/model/randevu_model.dart';
import 'package:veteriner_app/model/slot_model.dart';
import 'package:veteriner_app/servis/randevu_servis.dart';
import 'package:veteriner_app/servis/slot_servis.dart';
import 'package:veteriner_app/view/randevu_detay_ekrani.dart';
import 'package:veteriner_app/view/slot_ekle_ekrani.dart';

class HekimRandevularEkrani extends StatefulWidget {
  const HekimRandevularEkrani({super.key});

  @override
  State<HekimRandevularEkrani> createState() => _HekimRandevularEkraniState();
}

class _HekimRandevularEkraniState extends State<HekimRandevularEkrani>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _durumRengi(String durum) {
    switch (durum) {
      case 'Onaylandı':
        return Colors.green;
      case 'Reddedildi':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hekimID = FirebaseAuth.instance.currentUser!.uid;
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB71C1C), Color(0xFFE53935)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: const [
              Tab(text: 'Randevular'),
              Tab(text: 'Saatlerim'),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              TabBarView(
                controller: _tabController,
                children: [
                  StreamBuilder<List<Randevu>>(
                    stream: RandevuServis().tumRandevular(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final randevular = snapshot.data!;
                      if (randevular.isEmpty) return const Center(child: Text('Randevu yok'));
                      return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: randevular.length,
                        itemBuilder: (context, index) {
                          final randevu = randevular[index];
                          final renk = _durumRengi(randevu.durum);
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
                                  color: const Color(0xFFB71C1C).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.calendar_month, color: Color(0xFFB71C1C)),
                              ),
                              title: Text(randevu.sikayet, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${randevu.randevu_tur} • ${randevu.saat}'),
                              trailing: Chip(
                                label: Text(randevu.durum),
                                backgroundColor: renk.withValues(alpha: 0.15),
                                labelStyle: TextStyle(color: renk, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => RandevuDetayEkrani(randevu: randevu)),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  StreamBuilder<List<Slot>>(
                    stream: SlotServis().hekimSlotlari(hekimID),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final slotlar = snapshot.data!;
                      if (slotlar.isEmpty) return const Center(child: Text('Saat eklenmemiş'));
                      return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: slotlar.length,
                        itemBuilder: (context, index) {
                          final slot = slotlar[index];
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
                                  color: slot.dolu
                                      ? Colors.red.withValues(alpha: 0.1)
                                      : Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.access_time, color: slot.dolu ? Colors.red : Colors.green),
                              ),
                              title: Text(
                                '${slot.tarih.day}.${slot.tarih.month}.${slot.tarih.year}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(slot.saat),
                              trailing: Chip(
                                label: Text(slot.dolu ? 'Dolu' : 'Boş'),
                                backgroundColor: slot.dolu
                                    ? Colors.red.withValues(alpha: 0.15)
                                    : Colors.green.withValues(alpha: 0.15),
                                labelStyle: TextStyle(
                                  color: slot.dolu ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  backgroundColor: const Color(0xFFB71C1C),
                  foregroundColor: Colors.white,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SlotEkleEkrani()),
                  ),
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
