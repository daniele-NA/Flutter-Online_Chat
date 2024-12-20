import 'package:flutter/material.dart';
import 'package:fluuter/connections/authentication.dart';
import 'package:fluuter/connections/firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController _controllerInputMessage = TextEditingController();
  bool isDataLoaded = false; // Variabile per tracciare se i dati sono stati caricati
  bool isUserCountUpdated = false; // Variabile per tracciare se il conteggio degli utenti è stato aggiornato
  String? myUsername;  //variabile che verrà utilizzata all'interno del listBuilder per evitare di richiamare in await ogni volta il proprio username

  /**
   * tiene conto del numero di iscritti che viene aggiornato in base al numero di documenti
   * nella collezione 'PARAMETERS'
   */
  final StreamController<int> _userCountController = StreamController<int>();

  /*
  si occupa della gestione dello scroll ogni qual volta che viene notificato
   */
  final ScrollController _scrollController=new ScrollController();


  Future<void> _loadData() async {
    // Esegui il caricamento dei dati
    myUsername = await FirestoreService().loadData();
    _updateUserCount(); // Ottieni e aggiorna il numero di iscritti
    setState(() {
      isDataLoaded = true; // Quando i dati sono caricati, cambia lo stato
    });
  }

  @override
  void didChangeDependencies() {    //per il numero di iscritti
    super.didChangeDependencies();
    if (!isDataLoaded) {
      _loadData(); // Carica i dati solo se non sono già stati caricati
    }
  }


  // Metodo per aggiornare il numero di iscritti nel flusso
  void _updateUserCount() async {
    try {
      int userCount = await FirestoreService()
          .getSubscribed(); // Ottieni il numero degli utenti
      _userCountController.add(userCount); // Emetti il numero nel flusso
      setState(() {
        isUserCountUpdated =
        true; // Quando il conteggio degli utenti è aggiornato, cambia lo stato
      });
      // Puoi aggiornare periodicamente il numero, se necessario
      Future.delayed(Duration(seconds: 160),
          _updateUserCount); // Esegui l'aggiornamento ogni 160 secondi
    }on Exception catch(e){
      Fluttertoast.showToast(
          msg: 'Impossibile aggiornare numero iscritti ',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.deepOrange,
          fontSize: 20);
    }
  }

  @override
  void dispose() {
    _userCountController.close(); // Chiudi il flusso quando la pagina viene distrutta
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 45,
        actions: [
          IconButton(
            onPressed: () {
              _interfaceWithQueryPanel();  //uscita dalla pagina e LOGOUT
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.deepOrange,
            ),
          )
        ],
        title: const Text(
          'Chat principale',
          style: TextStyle(
              fontSize: 22, letterSpacing: 1.3, color: Colors.deepOrange),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.white38,
      body: Column(
        children: [
          Stack(
            children: [
              Positioned(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          // StreamBuilder che ascolta il flusso di utenti iscritti
                          StreamBuilder<int>(
                            stream: _userCountController.stream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting || !isUserCountUpdated) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Errore: ${snapshot.error}');   //errore in caso di iscritti non trovati
                              } else if (!snapshot.hasData) {
                                return const Text('Numero iscritti: 0');
                              } else {
                                return TextField(
                                  readOnly: true,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    hintText: 'Numero iscritti: ${snapshot.data}',
                                    hintStyle: TextStyle(color: Colors.white), // Colore del testo del hint
                                  ),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    letterSpacing: 2,
                                    color: Colors.white,
                                    backgroundColor: Colors.deepOrange,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 30,
                                  ),
                                );
                              }
                            },
                          ),
                          // Linea orizzontale sotto il TextField
                          Container(
                            height: 5, // Altezza della linea
                            color: Colors.deepOrange, // Colore della linea
                            width: double.infinity, // Va da sinistra a destra
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Lista dei messaggi in tempo reale tramite StreamBuilder
          Expanded(
            child: StreamBuilder<List<Map<String, String>>>(
              stream: FirestoreService().getMessagesStream(),    //questo Stream permette di vedere quanti messaggi ci sono e quelli nuovi
              builder: (context, snapshot) {
                if (!isDataLoaded) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Errore: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nessun messaggio disponibile'));
                } else {
                  List<Map<String, String>> messages = snapshot.data!;
                  if (_scrollController.hasClients) {     //si occupa dello scroll ad ogni messaggio
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      String username = messages[index]['sender']!;
                      String message =
                          username.toUpperCase() + ' : ' + messages[index]['value']!;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: username == myUsername
                              ? Alignment.centerRight   //se è uguale al mio username va a destra
                              : Alignment.centerLeft,   // se è diverso va a sinistra
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: username == myUsername
                                  ? Colors.deepPurple[300]
                                  : Colors.deepPurpleAccent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              message,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          // Barra di input per inviare messaggi
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controllerInputMessage,
                    decoration: InputDecoration(
                      hintStyle: const TextStyle(
                          fontSize: 28,
                          fontStyle: FontStyle.italic,
                          color: Colors.white),
                      hintText: "Scrivi un messaggio...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Colors.deepOrange, // Colore del bordo
                          width: 3, // Spessore del bordo
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 3, // Spessore del bordo
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Colors.deepOrange,
                          width: 3, // Spessore del bordo
                        ),
                      ),
                    ),
                    style: const TextStyle(
                        fontSize: 28,
                        fontStyle: FontStyle.italic,
                        color: Colors.white),
                  ),
                ),
                IconButton(   //icona per l'invio del messaggio
                  iconSize: 38,
                  icon: const Icon(
                    Icons.send,
                    color: Colors.deepOrange,
                  ),
                  onPressed: () {
                    if (_controllerInputMessage.text.isNotEmpty) {   //inserisce il messaggio solo se non è vuoto
                      FirestoreService()
                          .insertMessage(_controllerInputMessage.text);
                      _controllerInputMessage.clear(); // Pulisci il campo dopo l'invio
                    } else {
                      Fluttertoast.showToast(
                          msg: 'Messaggio vuoto',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          backgroundColor: Colors.deepOrange,
                          fontSize: 20);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _interfaceWithQueryPanel() async {
    await QueryPanel().signOut();
  }
}
