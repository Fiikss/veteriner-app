
import 'package:flutter/material.dart';

/// Firestore akisi hata verdiginde sonsuz donen cark yerine bu ekran cikar.
class AkisHatasi extends StatelessWidget {
  final Object? hata;
  const AkisHatasi({super.key, this.hata});

  String get _mesaj {
    final metin = hata?.toString() ?? '';
    if (metin.contains('failed-precondition') || metin.contains('requires an index')) {
      return 'Bu liste için veritabanı dizini eksik.';
    }
    if (metin.contains('permission-denied') || metin.contains('insufficient permissions')) {
      return 'Bu kayıtları görme yetkiniz yok.';
    }
    if (metin.contains('unavailable') || metin.contains('network')) {
      return 'Bağlantı kurulamadı. İnternet bağlantınızı kontrol edin.';
    }
    return 'Liste yüklenemedi.';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFB71C1C), size: 32),
            const SizedBox(height: 8),
            Text(
              _mesaj,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB71C1C)),
            ),
            const SizedBox(height: 6),
            // Firebase'in dizin olusturma baglantisi burada cikar; kopyalanabilsin diye SelectableText.
            SelectableText(
              hata?.toString() ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
