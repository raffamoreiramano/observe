import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:observe/classes/api_response.dart';
import 'package:observe/classes/colors.dart';
import 'package:observe/classes/enums.dart';
import 'package:observe/helpers/database.dart';
import 'package:observe/helpers/preferences.dart';
import 'package:observe/models/paciente.dart';
import 'package:observe/models/usuario.dart';
import 'package:observe/repositories/paciente_repository.dart';
import 'package:observe/services/auth.dart';
import 'package:observe/views/paciente/alarmes_page.dart';
import 'package:observe/views/paciente/ficha_medica.dart';
import 'package:observe/views/paciente/formulario_paciente.dart';
import 'package:observe/views/paciente/remedios_page.dart';
import 'package:observe/widgets/loader.dart';
import 'package:provider/provider.dart';

class PacienteMainPage extends StatefulWidget {
  @override
  _PacienteMainPageState createState() => _PacienteMainPageState();
}

class _PacienteMainPageState extends State<PacienteMainPage> {
  final LocalDatabase localDatabase = LocalDatabase();

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
    await localDatabase.initializeDatabase();

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

  @override
  void initState() {
    super.initState();
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

    return RemediosPage(usuario: _usuario, paciente: _paciente);
  }
}