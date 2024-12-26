import 'package:flutter/material.dart';

class ButtoninfoWidget extends StatelessWidget {
  final String _text;
  final VoidCallback onPressedCallback;  // Funzione passata come parametro

  // Costruttore
  ButtoninfoWidget({super.key, required String text, required this.onPressedCallback})
      : _text = text.trim() {
    if (_text.isEmpty) {
      throw Exception("Invalid text");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressedCallback,  // Esegui la funzione passata
      child: Text(
        _text,
        style: TextStyle(fontSize: 20),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepOrange, // Colore del bottone
      ),
    );
  }
}
