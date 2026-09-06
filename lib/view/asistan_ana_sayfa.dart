import 'package:flutter/material.dart';
import 'package:veteriner_app/view/akis_hatasi.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:veteriner_app/model/randevu_model.dart';
import 'package:veteriner_app/servis/randevu_servis.dart';
import 'package:veteriner_app/view/bildirim_paneli.dart';
import 'package:veteriner_app/servis/oturum_servis.dart';
import 'package:veteriner_app/view/giris_ekrani.dart';
import 'package:veteriner_app/view/profil_ekrani.dart';

class AsistanAnaSayfa extends StatefulWidget {
  const AsistanAnaSayfa({super.key});

  @override
  State<AsistanAnaSayfa> createState() => _AsistanAnaSayfaState();
}

class _AsistanAnaSayfaState extends State<AsistanAnaSayfa> {
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
      backgroundColor: const Color(0xFFFFFFFF),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFB71C1C)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, color: Colors.white, size: 50),
                  SizedBox(height: 8),
                  Text('VeterinerApp', style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profilim'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilEkrani()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Çıkış Yap'),
              onTap: () async {
                Oturum.temizle();
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Giris()));
              },
            ),
          ],
        ),
      ),
      endDrawer: const BildirimPaneli(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB71C1C), Color(0xFFE53935)],
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
        children: [
          StreamBuilder<List<Randevu>>(
            stream: RandevuServis().tumRandevular(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return AkisHatasi(hata: snapshot.error);
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final bugunA = DateTime.now();
              final randevular = snapshot.data!.where((r) {
                final gecti = r.tarih.isBefore(DateTime(bugunA.year, bugunA.month, bugunA.day));
                return !gecti || r.durum == 'Onaylandı';
              }).toList();
              if (randevular.isEmpty) return const Center(child: Text('Randevu yok'));
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: randevular.length,
                itemBuilder: (context, index) {
                  final randevu = randevular[index];
                  final durumRenk = randevu.durum == 'Onaylandı'
                      ? Colors.green
                      : randevu.durum == 'Reddedildi'
                          ? Colors.red
                          : Colors.orange;
                  return Card(
                    color: const Color.fromARGB(255, 229, 226, 226),
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
                      subtitle: Text('${randevu.randevuTur} • ${randevu.saat}'),
                      trailing: Chip(
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
          StreamBuilder<List<Randevu>>(
            stream: RandevuServis().tumRandevular(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return AkisHatasi(hata: snapshot.error);
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final randevular = snapshot.data!.where((r) => r.durum == 'Onaylandı').toList();
              if (randevular.isEmpty) return const Center(child: Text('Onaylanmış randevu yok'));
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: randevular.length,
                itemBuilder: (context, index) {
                  final randevu = randevular[index];
                  final odemeController = TextEditingController(text: randevu.odeme.toString());

                  Widget trailing;
                  if (randevu.odemeDurumu == 'Ödendi') {
                    trailing = Chip(
                      label: Text('₺${randevu.odeme}'),
                      backgroundColor: Colors.green.withValues(alpha: 0.15),
                      labelStyle: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      padding: EdgeInsets.zero,
                    );
                  } else {
                    trailing = SizedBox(
                      width: 130,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: odemeController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: '₺',
                                filled: true,
                                fillColor: const Color(0xFFFFEBEE),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            onPressed: () async {
                              await RandevuServis().odemeGuncelle(
                                randevu.id,
                                double.tryParse(odemeController.text) ?? 0,
                                'Ödendi',
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }

                  return Card(
                    color: const Color.fromARGB(255, 229, 226, 226),
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
                        child: const Icon(Icons.payment, color: Color(0xFFB71C1C)),
                      ),
                      title: Text(randevu.sikayet, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${randevu.randevuTur} • ${randevu.tarih.day}.${randevu.tarih.month}.${randevu.tarih.year}'),
                      trailing: trailing,
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
        backgroundColor: const Color.fromARGB(255, 229, 226, 226),
        selectedItemColor: const Color(0xFFB71C1C),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Randevular'),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Ödemeler'),
        ],
      ),
    );
  }
}
