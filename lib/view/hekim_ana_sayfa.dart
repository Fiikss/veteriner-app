import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:veteriner_app/view/bildirim_paneli.dart';
import 'package:veteriner_app/view/giris_ekrani.dart';
import 'package:veteriner_app/view/hekim_randevular_ekrani.dart';
import 'package:veteriner_app/view/kullanici_yonetim_ekrani.dart';
import 'package:veteriner_app/view/profil_ekrani.dart';
import 'package:veteriner_app/view/tibbikayit_listesi_ekrani.dart';
import 'package:veteriner_app/view/asi_hayvan_listesi_ekrani.dart';
import 'package:veteriner_app/view/yaklasan_asilar_ekrani.dart';

class HekimAnaSayfa extends StatefulWidget {
  const HekimAnaSayfa({super.key});

  @override
  State<HekimAnaSayfa> createState() => _HekimAnaSayfaState();
}

class _HekimAnaSayfaState extends State<HekimAnaSayfa> {
  int _secilenIndex = 0;
  late final PageController _pageController;

  final List<Widget> _sayfalar = [
    HekimRandevularEkrani(),
    TibbikayitListesiEkrani(),
    AsiHayvanListesiEkrani(),
    YaklasanAsilarEkrani(),
  ];

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
    final simdi = DateTime.now();
    final bugun = DateTime(simdi.year, simdi.month, simdi.day);
    final yediGunSonra = bugun.add(const Duration(days: 7));

    return Scaffold(
      backgroundColor: const Color(0xFFFFEBEE),
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
                  Text('VeterinerApp',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
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
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Kullanıcı Yönetimi'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const KullaniciYonetimEkrani()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Çıkış Yap'),
              onTap: () async {
                // oturumu kapat ve giriş ekranına dön
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Giris()));
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
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Asilar')
                .where('sonrakiAsiTarihi',
                    isGreaterThanOrEqualTo: Timestamp.fromDate(bugun))
                .where('sonrakiAsiTarihi',
                    isLessThanOrEqualTo: Timestamp.fromDate(yediGunSonra))
                .snapshots(),
            builder: (context, snapshot) {
              final adet = snapshot.data?.docs
                      .where((d) =>
                          (d.data() as Map<String, dynamic>)['asiDurumu'] ==
                          'Bekliyor')
                      .length ??
                  0;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: Colors.white, size: 26),
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                  ),
                  if (adet > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            adet > 9 ? '9+' : '$adet',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),),),),),],);},),

                            const SizedBox(width: 4),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _secilenIndex = index),
        children: _sayfalar,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 226, 223, 223),
        currentIndex: _secilenIndex,
        onTap: (index) {
          setState(() => _secilenIndex = index);
          _pageController.animateToPage(index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut);
        },
        selectedItemColor: const Color(0xFFB71C1C),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Randevular'),
          BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: 'Tıbbi Kayıt'),
          BottomNavigationBarItem(icon: Icon(Icons.vaccines), label: 'Aşılar'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Yaklaşan'),
        ],
      ),
    );
  }
}
