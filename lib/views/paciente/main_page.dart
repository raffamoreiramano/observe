import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:observe/classes/api_response.dart';
import 'package:observe/classes/colors.dart';
import 'package:observe/classes/enums.dart';
import 'package:observe/helpers/preferences.dart';
import 'package:observe/models/estado_do_paciente.dart';
import 'package:observe/models/paciente.dart';
import 'package:observe/models/remedio.dart';
import 'package:observe/models/usuario.dart';
import 'package:observe/repositories/paciente_repository.dart';
import 'package:observe/services/auth.dart';
import 'package:observe/views/paciente/alarmes.dart';
import 'package:observe/views/paciente/ficha_medica.dart';
import 'package:observe/views/paciente/formulario_paciente.dart';
import 'package:observe/widgets/card_remedio.dart';
import 'package:observe/widgets/loader.dart';
import 'package:observe/widgets/retorno_paciente.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class PacienteMainPage extends StatefulWidget {
  @override
  _PacienteMainPageState createState() => _PacienteMainPageState();
}

class _PacienteMainPageState extends State<PacienteMainPage> {
  bool _synced = false;

  fichaMedica() {
    Get.to(FichaMedica());
  }

  alarmes() {
    Get.to(AlarmsPage());
  }

  editarPerfil() {
    Get.to(
      FormularioPaciente(
        usuario: context.read<Preferences>().usuario,
        paciente: context.read<Preferences>().paciente,
      )
    ).then((retorno) {
      if (retorno is! APIResponse) {
        Get.showSnackbar(GetBar(
          backgroundColor: ObserveColors.dark,
          title: 'Ok',
          message: 'Fingiremos que nada aconteceu...',
          duration: Duration(seconds: 2),
        ));
      }
    });
  }

  trocarPerfil() {
    context.read<Preferences>().setPerfil(Perfil.usuario);
  }

  desconectar() {
    Get.dialog(
      AlertDialog(
        title: Text('Desconectar...'),
        content: Text(
          'Tem certeza que deseja desconectar da sua conta?'
        ),        
        actions: [
          TextButton(
            onPressed: () {
              context.read<Preferences>().clear();
              context.read<AuthMethods>().signOut();
            },
            child: Text(
              'SIM',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text(
              'NÃO',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      )
    );
  }

  Future verificarPerfil() async {
    final PacienteRepository _repo = PacienteRepository();

    await _repo.readPaciente(cid: context.read<User>().uid)
      .then((paciente) {
        context.read<Preferences>().setPaciente(paciente);
      }).catchError((erro) {
        context.read<Preferences>().setPaciente();
      });

    setState(() {
      _synced = true;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_synced) {
      verificarPerfil();
    }
  }

  List<Remedio> _listaTeste = List<Remedio>.generate(10, (index) {
    var rng = Random();
    return Remedio(
      nome: 'Remédio nº ${rng.nextInt(100).toString()}',
      horario: TimeOfDay(hour: rng.nextInt(24), minute: rng.nextInt(24)),
      medida: rng.nextBool() ? 'unidade' : 'ml',
      quantia: (rng.nextDouble() * 10),
    );
  });

  @override
  void initState() {
    super.initState();
    _listaTeste.sort((r1, r2) {
      final int h1 = r1.horario.hour;
      final int h2 = r2.horario.hour;
      final int m1 = r1.horario.minute;
      final int m2 = r2.horario.minute;

      return DateTime(0, 0, 0, h1, m1).compareTo(DateTime(0, 0, 0, h2, m2)) * -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    Paciente _paciente = context.select<Preferences, Paciente>((preferences) => preferences.paciente);
    Usuario _usuario = context.select<Preferences, Usuario>((preferences) => preferences.usuario);

    if (!_synced) {
      return Scaffold(
        backgroundColor: ObserveColors.dark,
        body: Container(
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          child: Loader(),            
        ),
      );
    }

    if (_paciente.isEmpty) {
      return FormularioPaciente(usuario: _usuario);
    }

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: BottomAppBar(
        clipBehavior: Clip.hardEdge,
        notchMargin: 5,
        shape: CircularNotchedRectangle(),
        child: Container(
          height: 70,
          width: MediaQuery.of(context).size.width,
          child: Row(            
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Container(
                  height: 70,
                  child: RawMaterialButton(
                    onPressed: () {
                      fichaMedica();
                    },
                    padding: EdgeInsets.only(right: 40),                    
                    child: Icon(
                      Icons.assignment_outlined,
                      color: Colors.blueGrey,
                      size: 30,
                    ),
                    highlightColor: ObserveColors.aqua[30],
                    splashColor: ObserveColors.aqua[30],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 70,
                  child: RawMaterialButton(
                    onPressed: () {
                      alarmes();
                    },
                    padding: EdgeInsets.only(left: 40),
                    child: Icon(
                      Icons.alarm,
                      color: Colors.blueGrey,
                      size: 30,
                    ),
                    highlightColor: ObserveColors.aqua[30],
                    splashColor: ObserveColors.aqua[30],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: ChangeNotifierProvider<EstadoNotifier>(
        create: (context) => EstadoNotifier(),
        child: BotaoRetorno(),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
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
                      editarPerfil();
                      break;
                    case Opcoes.trocar:
                      trocarPerfil();
                      break;
                    case Opcoes.sair:
                      desconectar();
                      break;
                  }
                },
              )
            ],
          ),
          SliverToBoxAdapter(
            child: ListView.builder(
              padding: EdgeInsets.only(
                top: 10,
                right: 10,
                bottom: 130,
                left: 10,
              ),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _listaTeste.length,
              itemBuilder: (context, index) {
                final remedio = _listaTeste.elementAt(index);
                return CardRemedio(
                  remedio,
                  callback: (bool value) {
                    remedio.tomado = value;
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}