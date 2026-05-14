import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:veteriner_app/model/randevu_model.dart';
import 'package:veteriner_app/servis/hayvan_servis.dart';
import 'package:veteriner_app/servis/randevu_servis.dart';
import 'package:veteriner_app/view/bildirim_paneli.dart';
import 'package:veteriner_app/view/giris_ekrani.dart';
import 'package:veteriner_app/view/hayvan_ekleme_ekrani.dart';
import 'dart:convert';
import 'package:veteriner_app/view/hayvan_detay_ekrani.dart';
import 'package:veteriner_app/view/profil_ekrani.dart';
import 'package:veteriner_app/view/randevu_ekle_ekrani.dart';

class MusteriAnaSayfa extends StatefulWidget {
  const MusteriAnaSayfa({super.key});

  @override
  State<MusteriAnaSayfa> createState() => _MusteriAnaSayfaState();
}

class _MusteriAnaSayfaState extends State<MusteriAnaSayfa> {
  int _secilenIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F0),
      drawer: Drawer(
      child: ListView(
      padding: EdgeInsets.zero,
      children: [
      const DrawerHeader(
        decoration: BoxDecoration(color: Color(0xFF7C2D12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, color: Colors.white, size: 50),
            SizedBox(height: 8),
            Text('Veteriner Klinik', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
      ),
      ListTile(
        leading: const Icon(Icons.person),
        title: const Text('Profilim'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilEkrani()));
        },
      ),
      ListTile(
        leading: const Icon(Icons.logout),
        title: const Text('Çıkış Yap'),
        onTap: () async {
          await FirebaseAuth.instance.signOut();
          if (!context.mounted) return;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Giris()));
        },
      ),
    ],
  ),
),

      floatingActionButton: _secilenIndex == 1
    ? FloatingActionButton(
        backgroundColor: const Color(0xFF7C2D12),
        foregroundColor: Colors.white,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => StreamBuilder(
              stream: HayvanServis().musteriHayvanlari(FirebaseAuth.instance.currentUser!.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final hayvanlar = snapshot.data!;
                return ListView.builder(
                  itemCount: hayvanlar.length,
                  itemBuilder: (context, index) {
                    final hayvan = hayvanlar[index];
                    return ListTile(
                      title: Text(hayvan.ad),
                      subtitle: Text(hayvan.tur),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => RandevuEkleEkrani(hayvanID: hayvan.id),
                        ));
                      },
                    );
                  },
                );
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      )
    : null,

      endDrawer: BildirimPaneli(musteriID: FirebaseAuth.instance.currentUser!.uid),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7C2D12), Color(0xFFEA580C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Icon(Icons.pets, color: Colors.white, size: 35),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _secilenIndex = index),
        children:  [
          Column(
        children: [

        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C2D12),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                shadowColor: const Color(0xFFC2410C).withValues(alpha: 0.4),
              ),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HayvanEkleEkran())),
              icon: const Icon(Icons.add),
              label: const Text('Evcil Hayvan Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ),


      Expanded(
        child: StreamBuilder(
        stream: HayvanServis().musteriHayvanlari(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final hayvanlar = snapshot.data!;
        return ListView.builder(
        itemCount: hayvanlar.length,
        itemBuilder: (context, index) {
        final hayvan = hayvanlar[index];
        return ListTile(
           onTap: () {
           Navigator.push(context, MaterialPageRoute(
            builder: (context) => HayvanDetayEkrani(hayvan: hayvan),
            ));
           },
          leading: CircleAvatar(
            backgroundImage: hayvan.fotoUrl.isNotEmpty ?
            MemoryImage(base64Decode(hayvan.fotoUrl)): null,
            child: hayvan.fotoUrl.isEmpty ?
            const Icon(Icons.pets): null,
          ),
        title: Text(hayvan.ad),
        subtitle: Text('${hayvan.tur} - ${hayvan.irk}'),
            );
          },
        );
      },
    ),
  ),
],
),

          StreamBuilder<List<Randevu>>(
  stream: RandevuServis().musteriRandevulari(FirebaseAuth.instance.currentUser!.uid),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return const CircularProgressIndicator();
    final randevular = snapshot.data!;
    if (randevular.isEmpty) return const Center(child: Text('Randevu yok'));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: randevular.length,
      itemBuilder: (context, index) {
        final randevu = randevular[index];
        Color durumRenk = randevu.durum == 'Onaylandı'
            ? Colors.green
            : randevu.durum == 'Reddedildi'
                ? Colors.red
                : Colors.orange;
        return Card(
          elevation: 3,
          shadowColor: const Color(0xFFC2410C).withValues(alpha: 0.18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF7C2D12).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.calendar_month, color: Color(0xFF7C2D12)),
            ),
            title: Text(randevu.randevu_tur, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${randevu.tarih.day}.${randevu.tarih.month}.${randevu.tarih.year} • ${randevu.saat}'),
            trailing: randevu.durum == 'Bekliyor'
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Chip(
                        label: const Text('Bekliyor'),
                        backgroundColor: Colors.orange.withValues(alpha: 0.15),
                        labelStyle: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 11),
                        padding: EdgeInsets.zero,
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                        tooltip: 'İptal Et',
                        onPressed: () async {
                          final onay = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Randevu İptal'),
                              content: const Text('Bu randevuyu iptal etmek istiyor musunuz?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hayır')),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('İptal Et', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (onay == true) {
                            await RandevuServis().randevuSil(randevu.id);
                          }
                        },
                      ),
                    ],
                  )
                : Chip(
                    label: Text(randevu.durum),
                    backgroundColor: durumRenk.withValues(alpha: 0.15),
                    labelStyle: TextStyle(color: durumRenk, fontWeight: FontWeight.bold, fontSize: 11),
                    padding: EdgeInsets.zero,
                  ),
          ),
        );
      },
    );
  },
),

        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _secilenIndex,
        onTap: (index) {
          setState(() => _secilenIndex = index);
          _pageController.animateToPage(index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut);
        },
        selectedItemColor: const Color(0xFF7C2D12),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Hayvanlarım'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Randevularım'),
        ],
      ),
    );
  }
}
