import 'dart:convert';
import 'package:observe/models/remedio.dart';

class Receita {
  int id, mid, pid;
  List<Remedio> remedios;

  bool get isEmpty => toMap().isEmpty;

  bool get isNotEmpty => !isEmpty;

  Receita({
    this.id,
    this.mid,
    this.pid,
    this.remedios,
  });

  factory Receita.fromMap(Map<String, dynamic> data) {
    final List<Remedio> _remedios = 
      List.from(data['remedios'])
      .map((remedio) => Remedio.fromMap(remedio))
      .toList();

    final Receita receita = Receita(
      id: data['id'],
      mid: data['mid'],
      pid: data['pid'],
      remedios: _remedios
    );

    return receita;
  }

  factory Receita.fromJson(String data) => Receita.fromMap(json.decode(data));

  Map<String, dynamic> toMap() {
    final _remedios = remedios.map((remedio) => remedio.toMap()).toList();

    final Map<String, dynamic> data = {
      'id': id,
      'mid': mid,
      'pid': pid,
      'remedios': _remedios,
    };

    data.removeWhere((key, value) => value == null);

    return data;
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() => toJson();
}

class ReceitaCollection {
  int id, mid, pid;
  String medico, paciente;
  double estado;

  bool get isEmpty => toMap().isEmpty;

  bool get isNotEmpty => !isEmpty;

  ReceitaCollection({
    this.id,
    this.mid,
    this.pid,
    this.medico,
    this.paciente,
    this.estado,
  });

  factory ReceitaCollection.fromMap(Map<String, dynamic> data) => ReceitaCollection(
    id: data['id'],
    mid: data['mid'],
    pid: data['pid'],
    medico: data['medico'],
    paciente: data['paciente'],
    estado: data['estado'],
  );

  factory ReceitaCollection.fromJson(String data) => ReceitaCollection.fromMap(json.decode(data));

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {
      'id': id,
      'mid': mid,
      'pid': pid,
      'medico': medico,
      'paciente': paciente,
      'estado': estado,
    };

    data.removeWhere((key, value) => value == null);

    return data;
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() => toJson();
}