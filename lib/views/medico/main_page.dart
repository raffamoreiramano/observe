import 'package:flutter/material.dart';
import 'package:observe/helpers/preferences.dart';
import 'package:provider/provider.dart';

class MedicoMainPage extends StatefulWidget {
  @override
  _MedicoMainPageState createState() => _MedicoMainPageState();
}

enum Opcoes { config, trocar, sair }
class _MedicoMainPageState extends State<MedicoMainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Médico'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => <PopupMenuEntry<Opcoes>>[
              PopupMenuItem(
                value: Opcoes.config,
                child: Text('Configurações'),
              ),
              PopupMenuItem(
                value: Opcoes.trocar,
                child: Text('Trocar de perfil'),
              ),
              PopupMenuItem(
                value: Opcoes.sair,
                child: Text('Desconectar'),
              ),
            ],
            onSelected: (Opcoes opcoes) {
              switch (opcoes) {
                case Opcoes.config:
                  print('popup :: Configurações');
                  break;
                case Opcoes.trocar:
                  print('popup :: Trocar de perfil');
                  break;
                case Opcoes.sair:
                  context.read<Preferences>().setPerfil('nenhum');
                  break;
              }
            },
          )
        ],
      ),
    );
  }
}