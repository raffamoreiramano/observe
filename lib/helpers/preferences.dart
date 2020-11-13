import 'dart:async';
import 'package:observe/models/medico.dart';
import 'package:observe/models/paciente.dart';
import 'package:observe/models/receita.dart';
import 'package:observe/models/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  final SharedPreferences _preferences;
  // Usuario usuario;
  // Medico medico;
  // Paciente paciente;
  // List<Receita> receitas;

  Preferences(this._preferences);

  Stream<Preferences> get stream => StreamController<Preferences>.broadcast().stream;

  Future setUsuario(Usuario usuario) async {
    await _preferences.setString('usuario', usuario.toString());
  }

  Usuario getUsuario() {
    String usuario = _preferences.getString('usuario');
    return usuario.isEmpty ? Usuario() : Usuario.fromJson(usuario);
  }

  Future setMedico(Medico medico) async {
    await _preferences.setString('medico', medico.toString());
  }

  Medico getMedico() {
    String medico = _preferences.getString('medico');
    return medico.isEmpty ? Medico() : Medico.fromJson(medico);
  }

  Future setPaciente(Paciente paciente) async {
    await _preferences.setString('paciente', paciente.toString());
  }

  Paciente getPaciente() {
    String paciente = _preferences.getString('paciente');
    return paciente.isEmpty ? Paciente() : Paciente.fromJson(paciente);
  }

  Future setReceitas(List<Receita> receitas) async {
    List<String> _receitas = receitas.map((receita) => receita.toString()).toList();
    await _preferences.setStringList('receitas', _receitas);
  }

  List<Receita> getReceitas() {
    List<String> _receitas = _preferences.getStringList('receitas');
    List<Receita> receitas = _receitas.map((receita) => Receita.fromJson(receita)).toList();
    return receitas;
  }

  Future setPerfil(String tipo) async {
    await _preferences.setString('perfil', tipo);
  }

  String getPerfil() {
    return _preferences.getString('perfil');
  }

  Future clear() async {
    return await _preferences.clear();
  }
}