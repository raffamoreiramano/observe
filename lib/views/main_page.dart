import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:observe/helpers/preferences.dart';
import 'package:observe/models/medico.dart';
import 'package:observe/models/paciente.dart';
import 'package:observe/models/usuario.dart';
import 'package:observe/repositories/medico_repository.dart';
import 'package:observe/repositories/paciente_repository.dart';
import 'package:observe/repositories/usuario_repository.dart';
import 'package:observe/services/auth.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _synced = false;

  Future storeUsuario(Preferences _preferences, String cid) async {
    final UsuarioRepository _repo = UsuarioRepository();

    await _repo.readUsuario(cid: cid)
      .then((usuario) {
        _preferences.setUsuario(usuario);
      }).catchError((erro) {
        _preferences.setUsuario(null);
      });
  }

  Future storeMedico(Preferences _preferences, String cid) async {
    final MedicoRepository _repo = MedicoRepository();

    await _repo.readMedico(cid: cid)
      .then((medico) {
        _preferences.setMedico(medico);
      }).catchError((erro) {
        _preferences.setMedico(null);
      });
  }

  Future storePaciente(Preferences _preferences, String cid) async {
    final PacienteRepository _repo = PacienteRepository();

    await _repo.readPaciente(cid: cid)
      .then((paciente) {
        _preferences.setPaciente(paciente);
      }).catchError((erro) {
        _preferences.setPaciente(null);
      });
  }

  Future syncData() async {
    Usuario _usuario;
    Medico _medico;
    Paciente _paciente;
    String _perfil;

    final _user = context.read<User>();
    final _preferences = context.read<Preferences>();

    _usuario = _preferences.getUsuario();

    if (_usuario.isEmpty) {
      await storeUsuario(_preferences, _user.uid);
    }

    if (_usuario.cid != _user.uid) {
      _preferences.clear();
      await storeUsuario(_preferences, _user.uid);
    }
    
    _perfil = _preferences.getPerfil();

    if (_perfil.isEmpty) {
      _medico = _preferences.getMedico();

      if (_medico.isEmpty) {
        await storeMedico(_preferences, _user.uid);
        _medico = _preferences.getMedico();
      }

      _paciente = _preferences.getPaciente();

      if (_paciente.isEmpty) {
        await storePaciente(_preferences, _user.uid);
        _paciente = _preferences.getPaciente();
      }

      if ((_medico.isEmpty || _paciente.isEmpty) && (_medico.isNotEmpty || _paciente.isNotEmpty)) {
        final _tipo = _medico.isNotEmpty ? 'medico' : 'paciente';
        await _preferences.setPerfil(_tipo);
      }

      print(_usuario.isEmpty);
      _synced = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_synced) {
      syncData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: IconButton(
                onPressed: () async {
                  // context.read<AuthMethods>().signOut();
                  // final _preferences = context.read<Preferences>();
                  // final _user = context.read<User>();

                  // Usuario _usuario;
                  // Medico _medico;
                  // Paciente _paciente;
                  // String _perfil;

                  // _usuario = _preferences.getUsuario();
                  // _medico = _preferences.getMedico();
                  // _paciente = _preferences.getPaciente();
                  // _perfil = _preferences.getPerfil();

                  // final _repo = UsuarioRepository();
                  // await _repo.readUsuario(cid: _user.uid).then((usuario) {
                  //   _preferences.setUsuario(usuario);                    
                  // });

                  // print(_preferences.getUsuario().toString());
                  // print(_medico.toString());
                  // print(_paciente.toString());
                  // print(_perfil.toString());

                  // print(_user.uid);

                  // await context.read<User>().delete();
                  context.read<AuthMethods>().signOut();

                  // print(_usuario);
                },
                icon: Icon(
                  Icons.exit_to_app
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}