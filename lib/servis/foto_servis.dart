import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class FotoServis {

  Future<Uint8List?> fotografSec({double maxWidth = 200, double maxHeight = 200}) async {
    final foto = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );

    if (foto == null) return null;
    
    final bytes = await foto.readAsBytes();
    if (bytes.length > 900000) throw Exception('Fotoğraf çok büyük, lütfen daha küçük bir fotoğraf seçin.');
    return bytes;
  }
}
