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