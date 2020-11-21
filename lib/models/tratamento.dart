import 'dart:convert';
import 'package:observe/models/item.dart';

class Tratamento extends Item {
  int id, mid, pid;
  String medico, paciente;
  double estado;
  DateTime inicio;
  DateTime retorno;

  bool get isEmpty => toMap().isEmpty;

  bool get isNotEmpty => !isEmpty;

  Tratamento({
    this.id,
    this.mid,
    this.pid,
    this.medico,
    this.paciente,
    this.estado,
    this.inicio,
    this.retorno,
  });

  factory Tratamento.fromMap(Map<String, dynamic> data) => Tratamento(
    id: data['id'],
    mid: data['mid'],
    pid: data['pid'],
    medico: data['medico'],
    paciente: data['paciente'],
    estado: data['estado'],
    inicio: DateTime.parse(data['retorno']),
    retorno: DateTime.parse(data['retorno']),
  );

  factory Tratamento.fromJson(String data) => Tratamento.fromMap(json.decode(data));

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {
      'id': id,
      'mid': mid,
      'pid': pid,
      'medico': medico,
      'paciente': paciente,
      'estado': estado,
      'inicio': inicio.toIso8601String(),
      'retorno': retorno.toIso8601String(),
    };

    data.removeWhere((key, value) => value == null);

    return data;
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() => toJson();
}