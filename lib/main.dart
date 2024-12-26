import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background/flutter_background.dart'; // Importa il pacchetto per il background
import 'package:fluuter/connections/firebase.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluuter/features/RuntimeFeatures.dart';
import 'package:fluuter/screens/AuthPage.dart';
import 'package:fluuter/screens/HomePage.dart';
import 'package:fluuter/utils/MyUtils.dart';
import 'connections/abstract_firebase.dart';
import 'connections/firestore.dart';
import 'firebase_options.dart';

/**
 * inizializzazione notifiche fatte una sola volta qui
 * gestione flusso e notifiche background
 */
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
debugPaintSizeEnabled=false;  //disabilita i controlli del layout

  // Inizializza il supporto per l'esecuzione in background prima di attivare l'esecuzione
  await FlutterBackground.initialize();

  // Attiva l'esecuzione in background
  await FlutterBackground.enableBackgroundExecution();

  runApp(const MyHomePage());
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {

  /**
   * questo parametro statico è colui che tiene traccia dei plugin e delle funzioni
   * per il .show()  della notifica,viene chiamato staticamente
   * da qualunque classe ne abbia bisogno
   */
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isAppInBackground = false; // Variabile per tenere traccia dello stato dell'app


  /**
   * gestione inizializzazione notifiche ,
   * colore barra strumenti
   */
  @override
  void initState() {
    super.initState();
    _initializeNotifications();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
    ));

    // Aggiungi l'observer per monitorare lo stato dell'app
    WidgetsBinding.instance.addObserver(this);

    // Avvia l'ascolto dei cambiamenti di Firestore
    _startListeningToLastMessage();
  }

  /**
   * inizializzazione delle notifiche che viene fatta solo una volta qui nel main
   */
  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('notification_icon_resized');

    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Monitorare lo stato dell'app (background o primo piano)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      // L'app è in background
      setState(() {
        _isAppInBackground = true;
      });
    } else if (state == AppLifecycleState.resumed) {
      // L'app è in primo piano
      setState(() {
        _isAppInBackground = false;
      });
    }
  }

  /**
   * ascolta l'ultimo messaggio da firestore in modo da inviarlo
   * come notifica,escludendo però i messaggi che manda
   * l'utente stesso
   */
  void _startListeningToLastMessage() {
    FirestoreService().getLastMessageForNotification().listen((message) {
      if (message.isNotEmpty) {
        String sender = message[ArgMessages.sender]!;
        String value = message[ArgMessages.value]!;

        // Invia una notifica solo se l'app è in background
        if (sender != RuntimeFeatures.username && _isAppInBackground) {
          MyNotification.showNotification(
              'Nuovo messaggio da $sender', value, flutterLocalNotificationsPlugin);
        }
      }
    });
  }

  @override
  void dispose() {
    /**
     * gestione dell'observer che serve per capire quando l'app
     * è in background
     */
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home: StreamBuilder(
        stream: FirebaseService().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const Homepage(); // Carica la pagina dei messaggi
          }
          return const AuthPage(); // Carica quella di autenticazione
        },
      ),
    );
  }
}
