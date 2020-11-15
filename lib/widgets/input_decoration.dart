import 'package:flutter/material.dart';
import 'package:observe/classes/colors.dart';

InputDecoration roundedFormInput(String hintText) {
  return InputDecoration(
    contentPadding: EdgeInsets.symmetric(
      horizontal: 25,
      vertical: 20,
    ),
    errorMaxLines: 4,
    hintText: hintText,
    hintStyle: TextStyle(
      color: Colors.grey,
    ),
    filled: true,
    fillColor: Colors.white12,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: BorderSide.none,
    ),
    errorStyle: TextStyle(
      color: ObserveColors.orange,
    ),    
  );
}

InputDecoration standardFormInput({String label, String hintText, String helperText}) {
  return InputDecoration(
    floatingLabelBehavior: FloatingLabelBehavior.always,
    labelText: label,
    hintText: hintText ?? '. . .',
    helperText: helperText,
    filled: true,
    fillColor: ObserveColors.dark[5],
    labelStyle: TextStyle(
      color: ObserveColors.dark[50],
      fontSize: 18,
    ),
    border: UnderlineInputBorder(
      borderSide: BorderSide(
        width: 2,
      ),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        color: ObserveColors.aqua[50]
      ),
    ),
    disabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        color: ObserveColors.dark[25],
      ),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        width: 2,
        color: Colors.lightBlue,
      ),
    ),
    errorBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        width: 2,
        color: ObserveColors.red,
      ),
    ),
  );
}