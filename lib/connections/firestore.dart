import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluuter/connections/abstract_connection.dart';
import 'package:fluuter/connections/authentication.dart';

// Servizio per la gestione delle operazioni su Firestore
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;


  // Funzione per inserire un nuovo documento nella collezione "users"
  Future<void> insertMessage(String value) async {
      CollectionReference messages =
          _db.collection(ArgMessages.collectionNameForMessages);
      /*
      sender
      timestamp
      value
       */
      await messages.add({
        ArgMessages.sender: await loadData(),  //si carica l'username corrente
        ArgMessages.timestamp: FieldValue.serverTimestamp(),
        ArgMessages.value: value.trim()
      });
  }

  /**
   * ritorna una lista contente come chiave l'username e come valore il messaggio scritto da quest'ultimo
   */
  Stream<List<Map<String, String>>> getMessagesStream() {  //fornisce nome utente e valore senza fermarsi mai
    return _db
        .collection(ArgMessages.collectionNameForMessages)
        .orderBy(ArgMessages.timestamp) // Ordina per timestamp, se necessario
        .snapshots() // Ottieni gli aggiornamenti in tempo reale
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          ArgMessages.sender: doc[ArgMessages.sender] as String,
          // Assicurati che 'sender' sia una stringa
          ArgMessages.value: doc[ArgMessages.value] as String
          // Aggiungi 'value' come stringa
        };
      }).toList();
    });
  }

  Future<void> insertParameter(String username) async {
    //inserisce l'username all'interno della collection parameters
    //da effettuare SOLO alla registrazione

    CollectionReference messages =
        _db.collection(ArgParameters.collectionNameForParameters);


    if (await loadData() != null) {
      throw new Exception(
          "Utente già registrato!!"); //non deve essere già presente in lista
    }

    /*
      email
      username
       */
    await messages.add({
      ArgParameters.email: QueryPanel().currentUser?.email.toString(),
      ArgParameters.username: username.trim()
    });
  }

  /**
   * principalmente serve per ottenere ogi volta l'username corrente (dato che non sta in nessuna variabile)
   * si chiama con await per non incombere in eventuali problemi di tempistiche
   */
  Future<String?> loadData() async {
    var querySnapshot = await _db
        .collection(ArgParameters.collectionNameForParameters)
        .where(ArgParameters.email, isEqualTo: QueryPanel().currentUser?.email)
        .get(); // Ottieni i documenti che corrispondono alla query

    // Verifica se sono stati trovati documenti
    if (querySnapshot.docs.isNotEmpty) {
      // Prendi il primo documento (nel caso che ci sia solo un'email unica per l'utente)
      var doc = querySnapshot.docs.first;

      // Restituisci lo username dal documento
      return await doc[ArgParameters.username] as String?;
    } else {
      // Se non viene trovato alcun documento per l'email
      return null;
    }
  }

  /**
   * ritorna il numero di iscritti,che sarebbe semplicemente un conteggio dei documenti all'interno
   * della collection 'parameters'
   */
  Future<int> getSubscribed()async{
  var querySnapshot = await _db
      .collection(ArgParameters.collectionNameForParameters)
      .get(); // Ottieni i documenti che corrispondono alla query

  // Verifica se sono stati trovati documenti
  if (querySnapshot.docs.isNotEmpty) {

    return querySnapshot.docs.length;
  } else {
    // Se non viene trovato alcun documento per l'email
    return 0;
  }
}
}
