import 'dart:async';
import 'package:flutter/material.dart';
import 'package:observe/classes/enums.dart';
import 'package:observe/models/medico.dart';
import 'package:observe/models/paciente.dart';
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
  Perfil _perfil;
  Perfil get perfil => _perfil;
  bool _tomado = false;
  bool get tomado => _tomado;
  double _estado = 3;
  double get estado => _estado;

  Preferences(this._preferences) {
    _usuario = getUsuario();
    _medico = getMedico();
    _paciente = getPaciente();
    _perfil = getPerfil();
    _tomado = getTomado();
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

  Future setPerfil([Perfil tipo]) async {
    await _setString(key: 'perfil', value: tipo ?? Perfil.usuario);
  }

  Perfil getPerfil() {
    String tipo = _preferences.getString('perfil') ?? Perfil.usuario.toString();
    return Perfil.values.singleWhere((element) => element.toString() == tipo, orElse: () => Perfil.usuario);
  }

  Future setTomado([bool value]) async {
    _tomado = value ?? !_tomado;

    return await _preferences.setBool('tomado', _tomado) ? notifyListeners() : false;
  }

  bool getTomado() {
    bool tomado = _preferences.getBool('tomado');

    if (tomado == null) {
      _preferences.remove('tomado');
      tomado = false;
    }

    return tomado;
  }

  Future setEstado([double value]) async {
    if (value == null) {
      
      return await _preferences.remove('estado');
    }

    final bool response = await _preferences.setDouble('estado', value);

    if (response) {
      _estado = value;
      notifyListeners();
    }

    return response;
  }

  double getEstado() {
    double estado = _preferences.getDouble('estado');

    if (estado == null) {
      _preferences.remove('estado');
      estado = 0;
    }

    return estado;
  }

  Future clear() async {
    _usuario = Usuario();
    _medico = Medico();
    _paciente = Paciente();
    _perfil = Perfil.usuario;
    _tomado = false;
    return await _preferences.clear() ? notifyListeners() : false;
  }
}