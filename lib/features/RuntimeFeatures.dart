class RuntimeFeatures {
  /**
   * tiene traccia staticamente per permettere l'accesso a tutti,
   * dei parametri correnti dell'utente,una volta caricati,non si esegue più la query,
   * anche i dati in generale
   */


  static String? _username;

  static String? _groupDescription;

  static String? get groupDescription => _groupDescription;

  static set groupDescription(String? value) {
    _groupDescription = value?.trim();
  }

  static String? get username => _username;

  static set username(String? value) {
    _username = value?.trim();
  }
}
