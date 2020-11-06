import 'package:observe/views/sign_in_page.dart';
import 'package:observe/views/sign_up_page.dart';
import 'package:flutter/material.dart';

class Authentication extends StatefulWidget {
  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  bool signed = true;

  void toggle() {
    setState(() {
      signed = !signed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return signed ? SignIn(toggle) : SignUp(toggle);
  }
}