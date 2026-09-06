import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:veteriner_app/view/giris_ekrani.dart';
import 'firebase_options.dart';



void main() async { //iş tamamlanmadan uygulama başlatılmaz
  WidgetsFlutterBinding.ensureInitialized(); //motor erkenden calisir

await Firebase.initializeApp( //bekleme islemi yapar
options:  DefaultFirebaseOptions.currentPlatform,
);

// Firestore'un web SDK'sinda bilinen bir kusur var: WebChannel akisi
// "INTERNAL ASSERTION FAILED: Unexpected state" ile patlayinca butun
// dinleyiciler dusuyor ve her ekran sonsuz donmeye basliyor.
// Uzun yoklama (long polling) o yolu devre disi birakir.
if (kIsWeb) {
  FirebaseFirestore.instance.settings = const Settings(
    webExperimentalForceLongPolling: true,
  );
}

runApp(const KlinikApp()); 

}

class KlinikApp extends StatelessWidget{
  const KlinikApp({super.key});
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
theme: ThemeData(
  scaffoldBackgroundColor: Colors.white,
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Color(0xFFB71C1C),
  ),
),

      home: const Giris(),
      );
  }
}
