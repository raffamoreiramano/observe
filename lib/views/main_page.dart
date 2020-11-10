import 'package:flutter/material.dart';
import 'package:observe/repositories/receita_repository.dart';
import 'package:observe/services/auth.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IconButton(
          onPressed: () async {
            // context.read<AuthMethods>().signOut();

            ReceitaRepository repositorio = ReceitaRepository();

            await repositorio.readReceita(1).then((value) => print(value.toString()));
          },
          icon: Icon(
            Icons.exit_to_app
          ),
        ),
      ),
    );
  }
}