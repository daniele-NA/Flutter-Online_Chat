import 'package:fluuter/connections/abstract_firebase.dart';
import 'package:fluuter/connections/firestore.dart';
import '../features/RuntimeFeatures.dart';

final class FirebaseService extends DatabaseConnection {
  /**
   * login semplice
   */
  @override
  Future<void> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    await firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(), password: password.trim());
  }

  @override
  Future<void> createUserWithEmailAndPassword({required String email,
    required String password,
    required String username}) async {
    /**
     * si inserisce l'username,anche se verrà fatta la chiamata del loadData nella HomePage()
     */

    if(username.trim().isEmpty || username.trim().length>15){
      throw Exception('Username non valido');
    }

    await FirestoreService().duplicateDataCheck(username);

    RuntimeFeatures.username=username;
    /**
     * qui viene inserito un nuovo doc. che simboleggia un nuovo username,
     */

    await firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(), password: password.trim());

    /**
     * la chiamata per inserire l'utente può essere fatta anche alla fine,tanto
     * in caso di username già presente verrà comunque lanciata eccezione
     */
    await FirestoreService().insertParameter(username.trim());
  }

  /**
   * logout semplice,vale per tutti i provider
   */

  @override
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }


  /**
   * permette il log in via github
   *   URL :  https://simple-chat-b334b.firebaseapp.com/__/auth/handler
   *    ID : Ov23liSJyf8u5jXJlvel
   * SECRET:  44042c0ead48e269564f0dbba49715dbf05bed4c
   */

}
