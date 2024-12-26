import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluuter/connections/firestore.dart';
import 'package:fluuter/features/RuntimeFeatures.dart';
import 'package:fluuter/screens/GroupInfoPage.dart';
import 'package:fluuter/utils/MyUtils.dart';
import 'package:fluuter/widgets/MessageWidget.dart';
import 'dart:async';
import '../connections/firebase.dart';

// Aggiungi questa nuova pagina (esempio di InfoPage)
class InfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Informazioni"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text(
          'Questa è la pagina delle informazioni.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController _controllerInputMessage = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool loadedData = false;
  int _currentIndex = 0; // Indice per la Bottom Navigation Bar

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    if (!loadedData) {
      //aspettiamo il caricamento di tutti i parametri
      await FirestoreService().loadData();
      loadedData = !loadedData;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /**
   * permette lo switch con la bottom bar
   */
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.black,
        actions: [
          // Container per le icone con padding superiore
          Container(
            padding: const EdgeInsets.only(top: 10),
            child: IconButton(
              onPressed: () {
                MyToast.show(text: 'Coming soon, stay with us!');
              },
              icon: const Icon(
                Icons.call,
                color: Colors.deepOrange,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 10),
            child: IconButton(
              onPressed: () {
                _interfaceWithQueryPanel();
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.deepOrange,
              ),
            ),
          ),
        ],
        title: const Text(
          'Easy Code',
          textAlign: TextAlign.left,
          style: TextStyle(
              fontFamily: 'YsabeauSC',
              fontSize: 30,
              letterSpacing: 1.3,
              color: Colors.deepOrange),
        ),
      ),
      backgroundColor: Colors.white38,
      body: IndexedStack(
        index: _currentIndex,
        //in base a quest'indice viene caricata una pagina,cambia con la bottomBar
        children: [
          // Pagina della Chat (Homepage)
          Column(
            children: [
              Container(
                height: 5,
                color: Colors.deepOrange,
                width: double.infinity,
              ),
              Expanded(
                child: StreamBuilder<List<Map<String, String>>>(
                  stream: FirestoreService().getMessagesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Errore: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('Nessun messaggio disponibile'));
                    } else {
                      List<Map<String, String>> messages = snapshot.data!;
                      Future.delayed(Duration(milliseconds: 100), () {
                        if (_scrollController.hasClients) {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      });
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          String username = messages[index]['sender']!;
                          String message = messages[index]['value']!;
                          return MessageWidget(
                            header: username,
                            payload: message,
                            labelColor: RuntimeFeatures.username == username
                                ? Colors.deepPurple[300]
                                : Colors.deepPurpleAccent,
                            iconColor: Colors.deepOrange,
                            alignment: RuntimeFeatures.username == username
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                          );
                        },
                      );
                    }
                  },
                ),
              ),
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
                            color: Colors.white,
                          ),
                          hintText: "Scrivi un messaggio...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Colors.deepOrange, width: 3),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Colors.deepOrange, width: 3),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Colors.deepOrange, width: 3),
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 28,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                        ),
                        minLines: 1,  // La quantità minima di righe visibili
                        maxLines: 4,  // Limita la quantità massima di righe
                        onChanged: (text) {
                          // Aggiungi automaticamente \n ogni 30 caratteri
                          if(_controllerInputMessage.text.length%30==0){
                            _controllerInputMessage.text= _controllerInputMessage.text+"\n";
                          }
                        },
                      ),
                    )
,
                    IconButton(
                      iconSize: 38,
                      icon: const Icon(
                        Icons.send,
                        color: Colors.deepOrange,
                      ),
                      onPressed: () {
                        if (_controllerInputMessage.text.isNotEmpty) {
                          try {
                            FirestoreService()
                                .insertMessage(_controllerInputMessage.text);
                          } catch (e) {
                            MyToast.show(text: e.toString());
                          }

                          _controllerInputMessage.clear();
                        } else {
                          MyToast.show(text: 'Messaggio vuoto');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Pagina InfoPage
          GroupInfoPage(),
        ],
      ),
      /**
       * gestione della bottom bar tra le 2 pagine
       */
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.orange[200],
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Info',
          ),
        ],
      ),
    );
  }

  /**
   * logout
   */
  Future<void> _interfaceWithQueryPanel() async {
    await FirebaseService().signOut();
  }

}
