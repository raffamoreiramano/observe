import 'package:observe/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class VerificationPage extends StatefulWidget {
  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: AlertDialog(
          title: Text('Verifique seu email'),
          actions: [
            TextButton(
              onPressed: () {
                context.read<AuthMethods>().signOut();
              },
              child: Text('Ok'),
            ),
          ],
        ),
      ),
    );
  }
}