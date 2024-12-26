import 'package:flutter/material.dart';

class CredentialFieldWidget extends StatelessWidget {

  late final TextEditingController controller;
  late final String hintText;
  late final IconData icon;
  CredentialFieldWidget(
      {super.key, required TextEditingController controller, required String hintText,required IconData icon}){
    this.controller=controller;
    this.hintText=hintText.trim();
    this.icon=icon;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
          hintText: this.hintText,
          icon:  Icon(icon,
              size: 70, color: Colors.deepOrange),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(
              color: Colors.deepOrange,
              width: 4.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(
              color: Colors.deepOrange,
              width: 4.0,
            ),
          )),
      textAlign: TextAlign.center,
      style: const TextStyle(
          fontStyle: FontStyle.italic,
          fontSize: 30,
          color: Colors.white),
    );

  }
}

