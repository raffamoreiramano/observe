import 'package:flutter/material.dart';
import 'package:observe/classes/colors.dart';
import 'package:observe/helpers/preferences.dart';
import 'package:observe/models/paciente.dart';
import 'package:observe/models/usuario.dart';
import 'package:provider/provider.dart';

class PacienteMainPage extends StatefulWidget {
  @override
  _PacienteMainPageState createState() => _PacienteMainPageState();
}

enum Opcoes { config, trocar, sair }
class _PacienteMainPageState extends State<PacienteMainPage> {
  @override
  Widget build(BuildContext context) {
    Paciente _paciente = context.select<Preferences, Paciente>((preferences) => preferences.paciente);
    Usuario _usuario = context.select<Preferences, Usuario>((preferences) => preferences.usuario);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: ObserveColors.dark,
            toolbarHeight: 80,
            leadingWidth: 70,
            leading: Container(
              margin: EdgeInsets.only(left: 15),
              child: CircleAvatar(
                backgroundColor: ObserveColors.aqua[30],
                foregroundColor: ObserveColors.aqua,
                child: Icon(
                  Icons.person_rounded,
                  size: 30,
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_usuario.nome} ${_usuario.sobrenome}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
                Text(
                  'ID: ${_paciente.id}',
                  style: TextStyle(
                    fontWeight: FontWeight.w100,
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
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
                      context.read<Preferences>().setPerfil(Perfil.usuario);
                      break;
                  }
                },
              )
            ],
          )
        ],
      ),
    );
  }
}