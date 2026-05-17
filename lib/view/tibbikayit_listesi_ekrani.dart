import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:veteriner_app/model/hayvan_model.dart';
import 'package:veteriner_app/servis/hayvan_servis.dart';
import 'package:veteriner_app/view/tibbi_kayit_ekle_ekrani.dart';

class TibbikayitListesiEkrani extends StatefulWidget {
  const TibbikayitListesiEkrani({super.key});

  @override
  State<TibbikayitListesiEkrani> createState() => _TibbikayitListesiEkraniState();
}

class _TibbikayitListesiEkraniState extends State<TibbikayitListesiEkrani> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Hayvan>>(
        stream: HayvanServis().tumHayvanlar(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final hayvanlar = snapshot.data!;
          if (hayvanlar.isEmpty) return const Center(child: Text('Kayıtlı hayvan yok'));
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: hayvanlar.length,
            itemBuilder: (context, index) {
              final hayvan = hayvanlar[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFB71C1C).withValues(alpha: 0.1),
                    backgroundImage: hayvan.fotoUrl.isNotEmpty
                        ? MemoryImage(base64Decode(hayvan.fotoUrl))
                        : null,
                    child: hayvan.fotoUrl.isEmpty
                        ? const Icon(Icons.pets, color: Color(0xFFB71C1C))
                        : null,
                  ),
                  title: Text(hayvan.ad, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${hayvan.tur} • ${hayvan.irk}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TibbiKayitEkleEkrani(hayvanID: hayvan.id),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
