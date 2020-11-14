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

  static StreamController<Preferences> _controller = StreamController<Preferences>.broadcast();

  Stream<Preferences> get stream => _controller.stream;

  Future setUsuario(Usuario usuario) async {
    final _usuario = usuario;
    if (_usuario == null) {
      return await _preferences.remove('usuario');
    }

    _controller.add(this);

    return _usuario.isNotEmpty ? await _preferences.setString('usuario', _usuario.toString()) : false;
  }

  Usuario getUsuario() {
    String usuario = _preferences.getString('usuario') ?? '';
    if (usuario == 'null') {
      _preferences.remove('usuario');
      usuario = '';
    }
    return usuario.isEmpty ? Usuario() : Usuario.fromJson(usuario);
  }

  Future setMedico(Medico medico) async {
    final _medico = medico;
    if (_medico == null) {
      return await _preferences.remove('medico');
    }

    _controller.add(this);

    return _medico.isNotEmpty ? await _preferences.setString('medico', _medico.toString()) : false;
  }

  Medico getMedico() {
    String medico = _preferences.getString('medico') ?? '';
    if (medico == 'null') {
      _preferences.remove('medico');
      medico = '';
    }

    return medico.isEmpty ? Medico() : Medico.fromJson(medico);
  }

  Future setPaciente(Paciente paciente) async {
    final _paciente = paciente;
    if (_paciente == null) {
      return await _preferences.remove('paciente');
    }

    _controller.add(this);

    return _paciente.isNotEmpty ? await _preferences.setString('paciente', _paciente.toString()) : false;
  }

  Paciente getPaciente() {
    String paciente = _preferences.getString('paciente') ?? '';
    if (paciente == 'null') {
      _preferences.remove('paciente');
      paciente = '';
    }
    
    return paciente.isEmpty ? Paciente() : Paciente.fromJson(paciente);
  }

  Future setReceitas(List<Receita> receitas) async {
    List<String> _receitas = receitas?.map((receita) => receita.toString())?.toList() ?? List<String>.empty();

    _controller.add(this);

    return _receitas.isNotEmpty ? await _preferences.setStringList('receitas', _receitas) : false;
  }

  List<Receita> getReceitas() {
    List<String> _receitas = _preferences.getStringList('receitas') ?? List<String>.empty();
    if (_receitas.isNotEmpty) {
      List<Receita> receitas = _receitas?.map((receita) => Receita.fromJson(receita))?.toList();
      return receitas.isEmpty ? List<Receita>.empty() : receitas;
    }

    return List<Receita>();
  }

  Future setPerfil(String tipo) async {
    if (tipo == null) {
      return await _preferences.remove('perfil');
    }

    _controller.add(this);

    return tipo.isNotEmpty ? await _preferences.setString('perfil', tipo) : false;
  }

  String getPerfil() {
    return _preferences.getString('perfil') ?? '';
  }

  Future clear() async {
    _controller.add(this);

    return await _preferences.clear();
  }

  void dispose() {
    _controller.close();
  }
}