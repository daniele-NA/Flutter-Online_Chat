import 'package:flutter/material.dart';

class MessageWidget extends StatelessWidget {
  late final String _header; // mittente
  late final String _payload; // testo messaggio
  late final Color? _labelColor; // colore messaggio
  late final Color? _iconColor; // colore icona
  late final Alignment _alignment; // allineamento

  MessageWidget({
    super.key,
    required String header, // nome utente
    required String payload, // messaggio
    required Color? labelColor, // colore messaggio
    required Color? iconColor, // colore icona
    required Alignment alignment, // allineamento
  }) {
    // allineamento
    this._header = header.trim();
    this._payload = payload.trim();
    this._labelColor = labelColor;
    this._iconColor = iconColor;

    if (alignment != Alignment.centerRight && alignment != Alignment.centerLeft) {
      throw new Exception(
          "Invalid Alignment, must be [ centerRight / centerLeft ]");
    }

    this._alignment = alignment;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: _alignment,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: _alignment == Alignment.centerRight
                ? CrossAxisAlignment.end // Allinea a destra
                : CrossAxisAlignment.start, // Allinea a sinistra
            children: [
              // Etichetta sopra il messaggio
              Row(
                mainAxisAlignment: _alignment == Alignment.centerRight
                    ? MainAxisAlignment.end // Allinea a destra
                    : MainAxisAlignment.start, // Allinea a sinistra
                children: [
                  // Icona dell'account (Avatar)
                  CircleAvatar(
                    backgroundColor: Colors.black,
                    radius: 12, // Icona più piccola
                    child: Icon(
                      Icons.account_circle, // Icona dell'account
                      color: _iconColor, // Colore dell'icona
                      size: 16, // Dimensione dell'icona
                    ),
                  ),
                  const SizedBox(width: 8), // Spazio ridotto tra l'avatar e la label
                  // Etichetta sopra il messaggio
                  Text(
                    _header, // Nome utente
                    style: TextStyle(
                      color: Colors.deepOrange, // Colore dell'etichetta
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4), // Spazio tra etichetta e messaggio
              Row(
                mainAxisAlignment: _alignment == Alignment.centerRight
                    ? MainAxisAlignment.end // Allinea a destra
                    : MainAxisAlignment.start, // Allinea a sinistra
                children: [
                  // Messaggio
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _labelColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _payload,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
