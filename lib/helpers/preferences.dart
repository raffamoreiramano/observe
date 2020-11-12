import 'dart:async';
import 'package:observe/models/medico.dart';
import 'package:observe/models/paciente.dart';
import 'package:observe/models/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  final SharedPreferences _preferences;

  Preferences(this._preferences);

  Stream<Preferences> get stream => StreamController<Preferences>.broadcast().stream;

  Future setUsuario(Usuario usuario) async {
    await _preferences.setString('usuario', usuario.toString());
  }

  Usuario getUsuario() {
    String usuario = _preferences.getString('usuario');
    return Usuario.fromJson(usuario);
  }

  Future setMedico(Medico medico) async {
    await _preferences.setString('medico', medico.toString());
  }

  Medico getMedico() {
    String medico = _preferences.getString('medico');
    return Medico.fromJson(medico);
  }

  Future setPaciente(Paciente paciente) async {
    await _preferences.setString('paciente', paciente.toString());
  }

  Paciente getPaciente() {
    String paciente = _preferences.getString('paciente');
    return Paciente.fromJson(paciente);
  }

  Future clear() async {
    return await _preferences.clear();
  }
}