import 'package:flutter/material.dart';
import 'package:observe/models/medico.dart';
import 'package:observe/repositories/medico_repository.dart';

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
            var teste = MedicoRepository();
            Medico usuario = Medico(
              uid: 5,
              crm: "9876543210/RJ",
            );
            await teste.createMedico(usuario)
            .then((value) {
              print(value);
            })
            .catchError((error) {
              print(error.toString());
            });
            // await teste.readMedico(18).then((value) {
            //   print(value.toString());
            // });
          },
          icon: Icon(
            Icons.exit_to_app
          ),
        ),
      ),
    );
  }
}