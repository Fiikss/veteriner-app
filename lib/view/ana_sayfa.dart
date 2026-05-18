import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:veteriner_app/view/asistan_ana_sayfa.dart';
import 'package:veteriner_app/view/giris_ekrani.dart';
import 'package:veteriner_app/view/hekim_ana_sayfa.dart';
import 'package:veteriner_app/view/musteri_ana_sayfa.dart';

class AnaSayfa extends StatelessWidget {
  const AnaSayfa({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data == null) {
          return Giris();
        }
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('Kullanicilar')
              .doc(snapshot.data!.uid)
              .get(),
          builder: (context, rolSnapshot) {
            if (!rolSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final rol = (rolSnapshot.data!.data() as Map<String, dynamic>?)?['rol'] ?? 'musteri';
            if (rol == 'hekim') return const HekimAnaSayfa();
            if (rol == 'asistan') return const AsistanAnaSayfa();
            return const MusteriAnaSayfa();
            },);},);}}
