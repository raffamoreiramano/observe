import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class Remedio {
  int id;
  String nome, medida, _horario;
  double quantia;
  TimeOfDay horario;
  DateFormat _format = DateFormat('HH:mm');
  bool tomado = false;


  bool get isEmpty {
    return toMap().isEmpty;
  }

  bool get isNotEmpty {
    return toMap().isNotEmpty;
  }
  
  Remedio({
    this.nome,
    this.medida,
    this.quantia,
    this.horario,
  }) {
    _horario = _format.format(DateTime(0, 0, 0, horario.hour, horario.minute));
  }

  Remedio.fromMap(Map<String, dynamic> data) {
    final DateTime _dateTime = _format.parse(data['horario'].toString());

    this.nome = data['nome'];
    this.medida = data['medida'];
    this.quantia = data['quantia'];
    this._horario = data['horario'];
    this.horario = TimeOfDay.fromDateTime(_dateTime);
  }

  Remedio.fromJson(String data) {
    final _data = json.decode(data);
    final DateTime _dateTime = _format.parse(_data['horario']);

    this.nome = _data['nome'];
    this.medida = _data['medida'];
    this.quantia = _data['quantia'];
    this._horario = _data['horario'];
    this.horario = TimeOfDay.fromDateTime(_dateTime);
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {
      'nome': nome,
      'medida': medida,
      'quantia': quantia,
      'horario': _horario,
    };

    return data;
  }

  String toJson() {
    return json.encode(toMap());
  }

  @override
  String toString() {
    return toJson();
  }
}