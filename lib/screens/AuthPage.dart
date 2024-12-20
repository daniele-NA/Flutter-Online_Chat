import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluuter/connections/authentication.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluuter/connections/firestore.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _controllerEmail =
      TextEditingController(); //controller primo field
  final TextEditingController _controllerPassword =
      TextEditingController(); //controller secondo field
  final TextEditingController _dialogController =
      TextEditingController(); //controller del Dialog per l'username

  /**
   * variabile che switcha la scritta del del bottone e decide l'azione
   * [iscriviti=FALSE / registrati=TRUE]
   */
  bool _isLogin = true;

  // Aggiungi il FlutterLocalNotificationsPlugin per le notifiche
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            'notification_icon_resized'); // Deve esserci un'icona in res/drawable

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 80,
        title: const Text(
          'Welcome Into Easy_Code',
          style: TextStyle(
              fontSize: 25, letterSpacing: 1.3, color: Colors.deepOrange),
        ),
        backgroundColor: Colors.black, //colore appbar
      ),
      backgroundColor: Colors.white12,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            TextField(
              controller: _controllerEmail,
              decoration: InputDecoration(
                  hintText: 'myemail@gmail.com',
                  icon: const Icon(Icons.account_circle_rounded,
                      size: 70, color: Colors.deepOrange),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                      color: Colors.deepOrange,
                      width: 4.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                      color: Colors.deepOrange,
                      width: 4.0,
                    ),
                  )),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 30,
                  color: Colors.white),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controllerPassword,
              obscureText: true,
              decoration: InputDecoration(
                  hintText: 'mysecretpassword',
                  icon: const Icon(Icons.abc_rounded,
                      size: 70, color: Colors.deepOrange),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                      color: Colors.deepOrange,
                      width: 4.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                      color: Colors.deepOrange,
                      width: 4.0,
                    ),
                  )),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 30,
                  color: Colors.white),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                interfaceWithQueryPanel(); //decic in questo metodo se registrare o loggare
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.deepOrange,
                backgroundColor: Colors.black,
                elevation: 10,
                // Colore del testo (arancione)
                textStyle: const TextStyle(
                  fontStyle: FontStyle.italic, // Stile del testo (corsivo)
                  fontSize: 36, // Aumenta la dimensione del testo
                ),
                side: const BorderSide(
                  color: Colors.purpleAccent, // Colore del bordo (arancione)
                  width: 4.5, // Spessore del bordo
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Angoli arrotondati
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 20, horizontal: 40), // Spaziatura interna
              ),
              child: Text(_isLogin ? "Accedi" : "Registrati"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin =
                      !_isLogin; //cambia lo stato delle azioni e del bottone
                });
              },
              style: ButtonStyle(
                textStyle: WidgetStateProperty.all<TextStyle>(
                  const TextStyle(
                    fontSize: 20, // Modifica qui la dimensione del testo
                    fontWeight: FontWeight
                        .bold, // Puoi aggiungere anche altre proprietà come il peso del font
                  ),
                ),
                foregroundColor: WidgetStateProperty.all<Color>(
                    Colors.deepOrange), // Colore del testo
              ),
              child: Text(
                _isLogin
                    ? "Non hai un account? Registrati"
                    : "Hai già un account? Accedi",
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Funzione per inviare una notifica
  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      '0', // ID del canale
      'Easy_Code', // Nome del canale
      channelDescription: 'Canale per le notifiche login',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // ID della notifica
    try {
      await flutterLocalNotificationsPlugin.show(
        0, // ID notifica
        title, // Titolo
        body, // Corpo
        platformChannelSpecifics,
        payload: 'Notifica ricevuta!', // Payload opzionale
      );
    } on Exception catch (e) {
      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.deepOrange,
          fontSize: 20);
    }
  }

  // Funzione per interagire con il pannello di query (Login/Registrazione)
  Future<void> interfaceWithQueryPanel() async {
    try {
      if (_isLogin) {
        //se si vuole loggare
        await QueryPanel().signInWithEmailAndPassword(
          email: _controllerEmail.text,
          password: _controllerPassword.text,
        );
        _controllerEmail.clear();
        _controllerPassword.clear();
        Fluttertoast.showToast(
            msg: 'Attendi qualche secondo',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.deepOrange,
            fontSize: 20);

        // Mostra una notifica di successo dopo il login
        _showNotification("Accesso effettuato correttamente",
            "Benvevuto ${await FirestoreService().loadData()} !!");
      } else {
        //altrimenti ci si registra
        String username = await showInputDialog(
            context); //si aspetta l'username per procedere

        if (username.isEmpty) {
          throw new Exception("invalid username");
        }

        /**
         * si crea l'utente attraverso
         * email/password -> vanno nel pannello di autenticazione firebase
         * username -> va in database firestore in un doc contenente :
         * {
         *    email:"xxxx",
         *    username:"yyyy"
         *    }
         */
        await QueryPanel().createUserWithEmailAndPassword(
            email: _controllerEmail.text,
            password: _controllerPassword.text,
            username: username);
        _controllerEmail.clear();
        _controllerPassword.clear();
        _dialogController.clear();
        Fluttertoast.showToast(
            msg: 'Attendi qualche secondo',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.deepOrange,
            fontSize: 20);

        // Mostra una notifica di successo dopo la registrazione
        _showNotification("Registrazione effettuata correttamente",
            "Benvevuto ${username} !!");
      }
    } on FirebaseAuthException catch (err) {
      Fluttertoast.showToast(
        msg: err.message.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.deepOrange,
        fontSize: 20,
      );
    } on Exception catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.deepOrange,
        fontSize: 20,
      );
    }
  }

  Future<String> showInputDialog(BuildContext context) async {        //per inserimento username
    TextEditingController _dialogController = TextEditingController();
    String input = ''; // Variabile per memorizzare l'input

    // Mostra il dialogo
    await showDialog<String>(
      context: context,
      barrierDismissible: false,    //non si può rimuovere dallo schermo
      // Impedisce la chiusura del dialogo cliccando fuori
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.deepPurple,
              title: Text('Inserisci username',
                  style: TextStyle(
                    fontSize: 30,
                    fontStyle: FontStyle.italic,
                    color: Colors.deepOrange,
                  )),
              content: TextField(
                style: TextStyle(
                  fontSize: 24,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                ),
                controller: _dialogController,
                decoration: InputDecoration(
                    hintText: 'Scrivi qui',
                    hintStyle: TextStyle(
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                    icon: Icon(
                      Icons.account_circle_rounded,
                      color: Colors.deepOrange,
                    )),
                onChanged: (value) {
                  setState(
                      () {}); // Rende abilitato/disabilitato il pulsante in base al contenuto
                },
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: _dialogController.text.isEmpty
                      ? null // Disabilita il pulsante se non c'è testo
                      : () {
                          input =
                              _dialogController.text.trim(); // Salva il valore
                          Navigator.of(context).pop(
                              input); // Chiudi il dialogo e restituisci l'input
                        },
                  child: Text('Conferma'),
                  style: ButtonStyle(
                    textStyle: MaterialStateProperty.all<TextStyle>(
                      const TextStyle(
                        fontSize: 20, // Modifica qui la dimensione del testo
                        fontWeight: FontWeight
                            .bold, // Puoi aggiungere anche altre proprietà come il peso del font
                      ),
                    ),
                    foregroundColor: WidgetStateProperty.all<Color>(
                        Colors.deepOrange), // Colore del testo
                    side: WidgetStateProperty.all<BorderSide>(BorderSide(
                      color: Colors.white, // Colore del bordo
                      width: 3.5, // Spessore del bordo
                    )),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            12), // Bordo arrotondato, modifica come vuoi
                      ),
                    ),
                  ),
                )
              ],
            );
          },
        );
      },
    );

    return input; // Ritorna l'input dell'utente
  }
}
