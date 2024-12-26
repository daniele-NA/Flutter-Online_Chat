import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluuter/connections/abstract_firebase.dart';
import 'package:fluuter/connections/firebase.dart';
import 'package:fluuter/features/RuntimeFeatures.dart';

// Servizio per la gestione delle operazioni su Firestore
final class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String _ADM_PASSWORD = 'admin';

  /**
   *   Funzione per inserire un nuovo documento nella collezione "users"

   */
  Future<void> insertMessage(String value) async {
    CollectionReference messages =
        _db.collection(ArgMessages.collectionNameForMessages);
    /*
      sender
      timestamp
      value
       */

    if(RuntimeFeatures.username==null || value.trim().isEmpty){
      throw Exception('Username/Messaggio non valido');
    }
    await messages.add({
      ArgMessages.sender: RuntimeFeatures.username,
      //si carica l'username corrente
      ArgMessages.timestamp: FieldValue.serverTimestamp(),
      ArgMessages.value: value.trim()
    });
  }

  /**
   * ritorna una lista contente come chiave l'username e come valore il messaggio scritto da quest'ultimo
   */
  Stream<List<Map<String, String>>> getMessagesStream() {
    //fornisce nome utente e valore senza fermarsi mai
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

  /**
   * permette di ricevere sempre l'ultimo messaggio
   */
  Stream<Map<String, String>> getLastMessageForNotification() {
    return _db
        .collection(ArgMessages.collectionNameForMessages)
        .orderBy(ArgMessages.timestamp, descending: true) // Ordina per timestamp, più recente prima
        .limit(1) // Limita il risultato a solo 1 messaggio
        .snapshots() // Ottieni gli aggiornamenti in tempo reale
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var doc = snapshot.docs.first; // Prendi il primo documento (l'ultimo inserito)
        return {
          ArgMessages.sender: doc[ArgMessages.sender] as String,
          ArgMessages.value: doc[ArgMessages.value] as String,
        };
      }
      return {}; // In caso non ci siano messaggi, ritorna un oggetto vuoto
    });
  }


  /**
   * funzione ceh viene richiamata ogni qual volta si va ad effettuare una registrazione
   */
  Future<void> insertParameter(String username) async {
    //inserisce l'username all'interno della collection parameters
    //da effettuare SOLO alla registrazione

    CollectionReference parameters =
        _db.collection(ArgParameters.collectionNameForParameters);

    /*
      email
      username
       */

    await parameters.add({
      ArgParameters.email: FirebaseService().currentUser?.email.toString(),
      ArgParameters.username: username.trim()
    });
  }

  /**
   * carica i dati dell'utente,gruppo etc etc
   * si chiama con await per non incombere in eventuali problemi di tempistiche
   */
  Future<void> loadData() async {
    var querySnapshot;

    final String? usernameExtracted;

    final String? groupDescriptionExtracted;

    querySnapshot = await _db
        .collection(ArgParameters.collectionNameForParameters)
        .where(ArgParameters.email,
            isEqualTo: FirebaseService().currentUser?.email)
        .get();

    querySnapshot.docs.isNotEmpty
        ? usernameExtracted =
            querySnapshot.docs.first[ArgParameters.username] as String
        : usernameExtracted = null;

    RuntimeFeatures.username=usernameExtracted;

    print('Ecco l\'username ${RuntimeFeatures.username}');

    querySnapshot =
        await _db.collection(ArgFeatures.collectionNameForFeatures).get();

    querySnapshot.docs.isNotEmpty
        ? groupDescriptionExtracted =
            querySnapshot.docs.first[ArgFeatures.groupDescription] as String
        : groupDescriptionExtracted = null;

    RuntimeFeatures.groupDescription=groupDescriptionExtracted;
  }

  /**
   * si occupa di controllare se l'username è già in uso
   */
  Future<void> duplicateDataCheck(String usernameToCheck) async {
    try {
      var querySnapshot = await _db
          .collection(ArgParameters.collectionNameForParameters)
          .where(ArgParameters.username, isEqualTo: usernameToCheck.trim())
          .get(); // Ottieni i documenti che corrispondono alla query

      // Se ci sono documenti che corrispondono, significa che l'username è già preso
      if (querySnapshot.docs.isNotEmpty) {
        throw Exception('L\'username ${usernameToCheck} è già in uso.');
      }
    } catch (e) {
      rethrow; // Rilancia l'eccezione se vuoi gestirla altrove
    }
  }

  /**
   * ritorna il numero di iscritti,che sarebbe semplicemente un conteggio dei documenti all'interno
   * della collection 'parameters'
   */
  Future<int> getSubscribed() async {
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

  /**
   * funzione che aggiorna la descrizione
   */

  Future<void> newGroupDescription({required String txt}) async {

    if(txt.length>170){
      throw Exception('Testo troppo lungo');
    }
    // Recupera il documento (presumiamo che ci sia un solo documento)
    var querySnapshot =
        await _db.collection(ArgFeatures.collectionNameForFeatures).get();

    if (querySnapshot.docs.isNotEmpty && txt.isNotEmpty) {
      // Prendi il documento (assumiamo che ci sia solo un documento)
      var docRef = querySnapshot.docs.first.reference;

      // Aggiorna il campo 'groupDescription' con il nuovo testo
      await docRef.update({
        ArgFeatures.groupDescription: txt,
      });

      RuntimeFeatures.groupDescription = txt;
      return;
    }

    throw Exception("Qualcosa è andato storto");
  }

  /**
   * pulizia dei messaggi
   */
  Future<void> clearMessages({required String password}) async {
    if (password != _ADM_PASSWORD) {
      throw Exception('Non sei Amministratore');
    }

    var querySnapshot =
        await _db.collection(ArgMessages.collectionNameForMessages).get();

    // Cancella ogni documento nella collezione
    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }
}
