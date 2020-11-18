import 'dart:async';
import 'package:flutter/material.dart';
import 'package:observe/classes/enums.dart';
import 'package:observe/models/medico.dart';
import 'package:observe/models/paciente.dart';
import 'package:observe/models/receita.dart';
import 'package:observe/models/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences extends ChangeNotifier {
  final SharedPreferences _preferences;
  Usuario _usuario;
  Usuario get usuario => _usuario;
  Medico _medico;
  Medico get medico => _medico;
  Paciente _paciente;
  Paciente get paciente => _paciente;
  List<Receita> _receitas;
  List<Receita> get receitas => _receitas;
  Perfil _perfil;
  Perfil get perfil => _perfil;

  Preferences(this._preferences) {
    _usuario = getUsuario();
    _medico = getMedico();
    _paciente = getPaciente();
    _receitas = getReceitas();
    _perfil = getPerfil();
  }

  Future _setString({String key, dynamic value}) async {
    if (value is Perfil) {
      _perfil = value;
      return await _preferences.setString(key, value.toString()) ? notifyListeners() : false;
    }

    if (value == null || value.isEmpty) {
      return await _preferences.remove(key);
    }

    if (value is Usuario) {
      _usuario = value;
    }

    if (value is Medico) {
      _medico = value;
    }

    if (value is Paciente) {
      _paciente = value;
    }

    if (value is List<Receita>) {
      _receitas = value;
    }

    
    return await _preferences.setString(key, value.toString()) ? notifyListeners() : false;
  }

  Future setUsuario([Usuario usuario]) async {
    await _setString(key: 'usuario', value: usuario);
  }

  Usuario getUsuario() {
    String usuario = _preferences.getString('usuario') ?? '';
    if (usuario == 'null') {
      _preferences.remove('usuario');
      usuario = '';
    }
    return usuario.isEmpty ? Usuario() : Usuario.fromJson(usuario);
  }

  Future setMedico([Medico medico]) async {
    await _setString(key: 'medico', value: medico);
  }

  Medico getMedico() {
    String medico = _preferences.getString('medico') ?? '';
    if (medico == 'null') {
      _preferences.remove('medico');
      medico = '';
    }

    return medico.isEmpty ? Medico() : Medico.fromJson(medico);
  }

  Future setPaciente([Paciente paciente]) async {
    await _setString(key: 'paciente', value: paciente);
  }

  Paciente getPaciente() {
    String paciente = _preferences.getString('paciente') ?? '';
    if (paciente == 'null') {
      _preferences.remove('paciente');
      paciente = '';
    }
    
    return paciente.isEmpty ? Paciente() : Paciente.fromJson(paciente);
  }

  Future setReceitas([List<Receita> receitas]) async {
    List<String> _receitas = receitas?.map((receita) => receita.toString())?.toList() ?? List<String>.empty();

    if (_receitas.isEmpty) {
      return await _setString(key: 'receitas');
    }
    
    return await _preferences.setStringList('receitas', _receitas) ? notifyListeners() : false;
  }

  List<Receita> getReceitas() {
    List<String> _receitas = _preferences.getStringList('receitas') ?? List<String>.empty();
    if (_receitas.isNotEmpty) {
      List<Receita> receitas = _receitas?.map((receita) => Receita.fromJson(receita))?.toList();
      return receitas.isEmpty ? List<Receita>.empty() : receitas;
    }

    return List<Receita>();
  }

  Future setPerfil([Perfil tipo]) async {
    await _setString(key: 'perfil', value: tipo ?? Perfil.usuario);
  }

  Perfil getPerfil() {
    String tipo = _preferences.getString('perfil') ?? Perfil.usuario.toString();
    return Perfil.values.singleWhere((element) => element.toString() == tipo, orElse: () => Perfil.usuario);
  }

  Future clear() async {
    _usuario = Usuario();
    _medico = Medico();
    _paciente = Paciente();
    _receitas = List<Receita>.empty();
    _perfil = Perfil.usuario;
    return await _preferences.clear() ? notifyListeners() : false;
  }
}