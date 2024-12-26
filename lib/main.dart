import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluuter/connections/firebase.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluuter/screens/AuthPage.dart';
import 'package:fluuter/screens/HomePage.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyHomePage());
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    // Impostare il colore della barra di navigazione e icone su nero e bianco
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
      // Colore barra di navigazione
      systemNavigationBarIconBrightness: Brightness.light,
      // Colore icone tasti (bianco)
      statusBarColor: Colors.black,
      // Colore della barra di stato (top)
      statusBarIconBrightness:
          Brightness.light, // Colore icone barra di stato (bianco)
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home: StreamBuilder(
          stream: FirebaseService().authStateChanges,
          // Flusso che rimane in attesa di notizie in Background
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return const Homepage(); //carica la pagina dei messaggi
            }
            return const AuthPage(); //carica quella di autenticazione
          }),
    );
  }
}
