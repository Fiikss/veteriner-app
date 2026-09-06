import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:veteriner_app/model/kullanici_model.dart';
import 'package:veteriner_app/servis/oturum_servis.dart';
import 'package:veteriner_app/view/asistan_ana_sayfa.dart';
import 'package:veteriner_app/view/giris_ekrani.dart';
import 'package:veteriner_app/view/hekim_ana_sayfa.dart';
import 'package:veteriner_app/view/musteri_ana_sayfa.dart';


/// Acilista oturumu kontrol edip kullaniciyi rolune gore yonlendirir.
/// Yonlendirmeden once [Oturum] doldurulur; aksi halde servisler klinik
/// kimligini bulamaz ve sorgular filtresiz kalir.
class AnaSayfa extends StatelessWidget {
  const AnaSayfa({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.data == null) {
          Oturum.temizle();
          return const Giris();
        }

        return FutureBuilder<Kullanici>(
          future: Oturum.baslat(),
          builder: (context, oturumSnapshot) {
            if (oturumSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            // Kullanici kaydi okunamadi ya da hesap bir klinige bagli degil:
            // ic ekranlara birakmak yerine girise dondur.
            if (oturumSnapshot.hasError || !Oturum.hazir) {
              Oturum.temizle();
              return const Giris();
            }

            final rol = oturumSnapshot.data!.rol;
            if (rol == 'hekim') return const HekimAnaSayfa();
            if (rol == 'asistan') return const AsistanAnaSayfa();
            return const MusteriAnaSayfa();
          },
        );
      },
    );
  }
}
