import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:veteriner_app/view/giris_ekrani.dart';
import 'firebase_options.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

await Firebase.initializeApp(
options:  DefaultFirebaseOptions.currentPlatform,
);

runApp(const KlinikApp());

}

class KlinikApp extends StatelessWidget{
  const KlinikApp({super.key});
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Giris(),
      );
  }
}
