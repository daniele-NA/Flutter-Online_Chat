import 'package:flutter/material.dart';
import 'package:fluuter/connections/authentication.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluuter/connections/firestore.dart';
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
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home: StreamBuilder(stream: QueryPanel().authStateChanges,   // Flusso che rimane in attesa di notizie in Background
          builder: (context,snapshot){
          if(snapshot.hasData){
            return const Homepage(); //carica la pagina dei messaggi
          }
          return const AuthPage();  //carica quella di autenticazione
          }
      ),
    );
  }

}

