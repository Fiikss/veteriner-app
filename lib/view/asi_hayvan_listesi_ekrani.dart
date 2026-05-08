import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:veteriner_app/servis/hayvan_servis.dart';
import 'package:veteriner_app/view/hayvan_asilari_ekrani.dart';

class AsiHayvanListesiEkrani extends StatefulWidget {
  const AsiHayvanListesiEkrani({super.key});

  @override
  State<AsiHayvanListesiEkrani> createState() => _AsiHayvanListesiEkraniState();
}

class _AsiHayvanListesiEkraniState extends State<AsiHayvanListesiEkrani> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
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
                elevation: 3,
                shadowColor: const Color(0xFFC2410C).withValues(alpha: 0.18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF7C2D12).withValues(alpha: 0.1),
                    backgroundImage: hayvan.fotoUrl.isNotEmpty
                        ? MemoryImage(base64Decode(hayvan.fotoUrl))
                        : null,
                    child: hayvan.fotoUrl.isEmpty
                        ? const Icon(Icons.pets, color: Color(0xFF7C2D12))
                        : null,
                  ),
                  title: Text(hayvan.ad, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${hayvan.tur} • ${hayvan.irk}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HayvanAsilariEkrani(
                        hayvanID: hayvan.id,
                        hayvanAdi: hayvan.ad,
                      ),
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
