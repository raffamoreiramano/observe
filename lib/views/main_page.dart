import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:observe/classes/colors.dart';
import 'package:observe/helpers/preferences.dart';
import 'package:observe/models/medico.dart';
import 'package:observe/models/paciente.dart';
import 'package:observe/models/usuario.dart';
import 'package:observe/repositories/medico_repository.dart';
import 'package:observe/repositories/paciente_repository.dart';
import 'package:observe/repositories/usuario_repository.dart';
import 'package:observe/services/auth.dart';
import 'package:observe/views/medico/main_page.dart';
import 'package:observe/widgets/loader.dart';
import 'package:provider/provider.dart';

import 'paciente/main_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _visible = false;
  bool _synced = false;
  Usuario _usuario = Usuario();
  Medico _medico = Medico();
  Paciente _paciente = Paciente();
  String _perfil = '';
  Preferences _preferences;
  User _user;

  Future storeUsuario(Preferences _preferences, String cid) async {
    final UsuarioRepository _repo = UsuarioRepository();

    await _repo.readUsuario(cid: cid)
      .then((usuario) async {
        await _preferences.setUsuario(usuario);
      }).catchError((erro) {
        _preferences.setUsuario(null);
      });
  }

  Future storeMedico(Preferences _preferences, String cid) async {
    final MedicoRepository _repo = MedicoRepository();

    await _repo.readMedico(cid: cid)
      .then((medico) async {
        await _preferences.setMedico(medico);
      }).catchError((erro) {
        _preferences.setMedico(null);
      });
  }

  Future storePaciente(Preferences _preferences, String cid) async {
    final PacienteRepository _repo = PacienteRepository();

    await _repo.readPaciente(cid: cid)
      .then((paciente) async {
        await _preferences.setPaciente(paciente);
      }).catchError((erro) {
        _preferences.setPaciente(null);
      });
  }

  Future syncData() async {
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
        _perfil = _preferences.getPerfil();
        if (_perfil != 'nenhum') {
          final _tipo = _medico.isNotEmpty ? 'medico' : 'paciente';
          await _preferences.setPerfil(_tipo);
        }
      }

      setState(() {
        _synced = true;
        _visible = true;
      });
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
  void initState() {
    super.initState();
    _preferences = context.read<Preferences>();
    _user = context.read<User>();

    _usuario = _preferences.getUsuario();
    _perfil = _preferences.getPerfil();
    _visible = true;
  }

  @override
  Widget build(BuildContext context) {
    _preferences = context.watch<Preferences>();
    _user = context.watch<User>();
    _usuario = _preferences.getUsuario();
    _perfil = _preferences.getPerfil();

    switch (_perfil) {
      case 'medico':
        return MedicoMainPage();
        break;
      case 'paciente':
        return PacienteMainPage();
        break;
      default:
        return Scaffold(
          backgroundColor: ObserveColors.dark,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Visibility(
                  visible: _visible,
                  replacement:  Container(
                    height: MediaQuery.of(context).size.height,
                    alignment: Alignment.center,
                    child: Loader(),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          'Deseja entrar como?',
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Container(
                        height: 80,
                        width: MediaQuery.of(context).size.width - 80,
                        margin: EdgeInsets.symmetric(vertical: 30),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(80),
                          color: ObserveColors.orange[15],
                        ),
                        child: RawMaterialButton(
                          onPressed: () {
                            _preferences.setPerfil('medico');
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(80)
                          ),
                          splashColor: ObserveColors.orange[15],
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                child: CircleAvatar(
                                  radius: 35,
                                  child: Icon(Icons.healing_outlined, size: 40,),
                                  backgroundColor: ObserveColors.orange[15],
                                  foregroundColor: ObserveColors.orange,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.only(right: 70),
                                  child: Text(
                                    'Médico',
                                    style: TextStyle(
                                      color: Colors.deepOrange[200],
                                      fontSize: 20,
                                    ),
                                  ),
                                )
                              )
                            ],
                          ),
                        ),
                      ),
                      Text(
                        'ou',
                        style: TextStyle(
                          color: Colors.blueGrey,
                        ),
                      ),
                      Container(
                        height: 80,
                        width: MediaQuery.of(context).size.width - 80,
                        margin: EdgeInsets.symmetric(vertical: 30),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(80),
                          color: ObserveColors.aqua[15],
                        ),
                        child: RawMaterialButton(
                          onPressed: () {
                            _preferences.setPerfil('paciente');                            
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(80)
                          ),
                          splashColor: ObserveColors.aqua[15],
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                child: CircleAvatar(
                                  radius: 35,
                                  child: Icon(Icons.person_rounded, size: 40,),
                                  backgroundColor: ObserveColors.aqua[15],
                                  foregroundColor: ObserveColors.aqua,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.only(right: 70),
                                  child: Text(
                                    'Paciente',
                                    style: TextStyle(
                                      color: Colors.lightBlue[200],
                                      fontSize: 20,
                                    ),
                                  ),
                                )
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 30),
                        child: FloatingActionButton(
                          onPressed: () {
                            context.read<AuthMethods>().signOut();
                          },
                          elevation: 0,
                          hoverElevation: 0,
                          focusElevation: 0,
                          highlightElevation: 0,
                          disabledElevation: 0,
                          tooltip:'Sair',
                          splashColor: ObserveColors.rose,
                          hoverColor: ObserveColors.rose,
                          focusColor: ObserveColors.rose,
                          backgroundColor: ObserveColors.red[15],
                          child: CircleAvatar(
                            backgroundColor: ObserveColors.red[75],
                            foregroundColor: Colors.white70,
                            child: Icon(Icons.clear),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
    }    
  }
}