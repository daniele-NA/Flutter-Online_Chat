import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyDialog {
  MyDialog() {}

  Future<String> showInputDialog(
      {required BuildContext context,
      required String text,
      required bool barrierDismissible}) async {
    //per inserimento username
    TextEditingController _dialogController = TextEditingController();
    String input = ''; // Variabile per memorizzare l'input

    // Mostra il dialogo
    await showDialog<String>(
      context: context,
      barrierDismissible: barrierDismissible,
      //non si può rimuovere dallo schermo
      // Impedisce la chiusura del dialogo cliccando fuori
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.deepPurple,
              title: Text(text.trim(),
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
                    textStyle: WidgetStateProperty.all<TextStyle>(
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

class MyToast {
  static void show({required String text}) {
    Fluttertoast.showToast(
      msg: text.toString(),
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.deepOrange,
      fontSize: 20,
    );
  }
}

class MyNotification {
  static Future<void> showNotification(String title, String body,
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      '0',
      'Easy_Code',
      channelDescription: 'Canale per le notifiche messaggi',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'Notifica ricevuta!',
    );
  }
}
