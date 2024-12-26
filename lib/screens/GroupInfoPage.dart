import 'package:flutter/material.dart';
import 'package:fluuter/utils/MyUtils.dart';
import '../connections/firestore.dart';
import 'package:fluuter/widgets/ButtonInfoWidget.dart';

class GroupInfoPage extends StatefulWidget {
  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white38,
      body: ListView(
        children: <Widget>[
          Container(
            height: 5,
            color: Colors.deepOrange,
            width: double.infinity,
          ),
          Padding(padding: const EdgeInsets.symmetric(vertical: 14.0)),

          // Sezione immagine del gruppo
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/info_picture.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),

          SizedBox(height: 20),

          // Nome del gruppo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              textAlign: TextAlign.center,
              'Easy Code Group',
              style: TextStyle(
                fontSize: 28,
                fontStyle: FontStyle.italic,
                fontFamily: 'YsabeauSC',
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // FutureBuilder per il numero di membri
          FutureBuilder<int>(
            future: FirestoreService().getSubscribed(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Errore: ${snapshot.error}');
              } else if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Membri: 0',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10.0),
                  child: Text(
                    'Membri: ${snapshot.data}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                );
              }
            },
          ),

          /**
           * grazie al database firestore,si tiene aggiornato costantemente con un flusso
           */
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: StreamBuilder<String>(
              stream: FirestoreService().getGroupDescription(),
              // Ascolta il flusso restituito dalla funzione
              builder: (context, snapshot) {
                // Se il flusso è in attesa, mostra "Caricamento..."
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text(
                    'Caricamento...',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }

                // In tutti gli altri casi (errore o dati), mostra la descrizione
                return Text(
                  snapshot.hasData
                      ? snapshot.data!
                      : 'Descrizione non disponibile',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),

          // Bottone per cambiare la descrizione
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: ButtonInfoWidget(
              text: 'Cambia descrizione',
              onPressedCallback: () async {
                try {
                  String? newDescription = await MyDialog().showInputDialog(
                    context: context,
                    text: 'max 170 CH',
                    barrierDismissible: true,
                  );
                  if (newDescription.isNotEmpty) {
                    FirestoreService().setGroupDescription(txt: newDescription);
                  }
                } catch (e) {
                  MyToast.show(text: e.toString());
                }
              },
            ),
          ),

          // Bottone per svuotare la chat
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ButtonInfoWidget(
              text: 'Svuota la chat per tutti',
              onPressedCallback: () async {
                try {
                  String psw = await MyDialog().showInputDialog(
                      context: context,
                      text: 'inserisci password adm',
                      barrierDismissible: true);
                  FirestoreService().clearMessages(password: psw);
                } catch (e) {
                  MyToast.show(text: 'Qualcosa è andato storto');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
