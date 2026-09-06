
import 'package:flutter/material.dart';

/// Bir Firestore akisi hata verdiginde spinner yerine gosterilir.
///
/// Sonsuz donen bir cark ne kullaniciya ne gelistiriciye bir sey soyler;
/// klinikte "program acilmiyor" diye telefon actiran sey tam olarak budur.
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
            // Teknik ayrinti: dizin hatalarinda Firebase'in verdigi olusturma
            // baglantisi burada cikar, kopyalanabilir olmasi icin SelectableText.
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
