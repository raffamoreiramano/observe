import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:observe/classes/api_response.dart';
import 'package:observe/classes/colors.dart';
import 'package:observe/classes/enums.dart';
import 'package:observe/helpers/database.dart';
import 'package:observe/helpers/preferences.dart';
import 'package:observe/models/medico.dart';
import 'package:observe/models/usuario.dart';
import 'package:observe/repositories/medico_repository.dart';
import 'package:observe/services/auth.dart';
import 'package:observe/views/medico/formulario_medico.dart';
import 'package:observe/views/medico/tratamentos_page.dart';
import 'package:observe/widgets/loader.dart';
import 'package:provider/provider.dart';

class MedicoMainPage extends StatefulWidget {
  @override
  _MedicoMainPageState createState() => _MedicoMainPageState();
}

class _MedicoMainPageState extends State<MedicoMainPage> {
  final LocalDatabase localDatabase = LocalDatabase();

  bool _synced = false;

  editarPerfil() {
    Get.to(
      FormularioMedico(
        usuario: context.read<Preferences>().usuario,
        medico: context.read<Preferences>().medico,
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

    final MedicoRepository _repo = MedicoRepository();

    await _repo.readMedico(cid: context.read<User>().uid)
      .then((medico) {
        context.read<Preferences>().setMedico(medico);
      }).catchError((erro) {
        context.read<Preferences>().setMedico();
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
    Medico _medico = context.select<Preferences, Medico>((preferences) => preferences.medico);
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

    if (_medico.isEmpty) {
      return FormularioMedico(usuario: _usuario);
    }

    return TratamentosPage(usuario: _usuario, medico: _medico);
  }
}