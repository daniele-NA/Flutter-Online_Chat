import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/cupertino.dart";

abstract class DatabaseConnection {
  /**
   *
   * astrazione dei metodi ereditati d QueryPanel()
   */
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  UserCredential? userCredential;

  User? get currentUser =>
      this._firebaseAuth.currentUser; //prende l'utente corrente
  Stream<User?> get authStateChanges => this._firebaseAuth.authStateChanges();

  @protected
  Future<void> signInWithEmailAndPassword(
      {required String email, required String password});

  @protected
  Future<void> createUserWithEmailAndPassword(
      {required String email,
      required String password,
      required String username});

  @protected
  Future<void> signOut();

  @protected
  FirebaseAuth get firebaseAuth => _firebaseAuth;

}

/**
 * Parametri statici con valori che fanno riferimento ai Json della collezione  'messages'
 *
 * sender
    timestamp
    value
 */
final class ArgMessages {
  static final String sender = 'sender';
  static final String timestamp = 'timestamp';
  static final String value = 'value';

  static final String collectionNameForMessages =
      'messages'; //nome della collezione
}

/**
 *
 * Parametri statici con valori che fanno riferimento ai Json della collezione  'messages'
 * email
 * username
 */
final class ArgParameters {
  static final String email = 'email';
  static final String username = 'username';

  static final String collectionNameForParameters =
      'parameters'; //nome della collezione
}

/**
 * parametri statici per le caratteristiche
 */

final class ArgFeatures {
  static final groupDescription = 'group_description';

  static final String collectionNameForFeatures = 'features';
}

/**
 * parametri statici per le stelline inviate come rating dell'app
 */
final class ArgRating {
  static final rating = 'rating';

  static final String collectionNameForRatings = 'ratings';
}
