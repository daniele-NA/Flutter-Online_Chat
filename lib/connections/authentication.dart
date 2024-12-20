import 'package:fluuter/connections/abstract_connection.dart';
import 'package:fluuter/connections/firestore.dart';

final class QueryPanel extends DatabaseConnection {


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
  Future<void> createUserWithEmailAndPassword(
      {required String email,
      required String password,
      required String username}) async {
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
   * logout semplice
   */

  @override
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }
}
