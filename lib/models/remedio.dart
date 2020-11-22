import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:observe/models/item.dart';


class Remedio extends Item {
  int id;
  String nome, medida, _horario;
  double quantia;
  bool tomado = false;

  TimeOfDay get horario {
    initializeDateFormatting('pt_BR', null);
    final DateFormat _format = DateFormat('HH:mm');
    
    return TimeOfDay.fromDateTime(_format.parse(_horario));
  }

  set horario(TimeOfDay value) {
    initializeDateFormatting('pt_BR', null);
    final DateFormat _format = DateFormat('HH:mm');

    
    _horario = _format.format(DateTime(0, 0, 0, value.hour, value.minute));
    print(_horario);
  }

  bool get isEmpty {
    return toMap().isEmpty;
  }

  bool get isNotEmpty {
    return toMap().isNotEmpty;
  }
  
  Remedio({
    this.id,
    this.nome,
    this.medida,
    this.quantia,
    this.tomado,
    TimeOfDay horario,
  }) {
    if (horario != null) {
      this.horario = horario;
    }
  }

  factory Remedio.fromMap(Map<String, dynamic> data) {
    final DateFormat _format = DateFormat('HH:mm');
    final DateTime _dateTime = _format.parse(data['horario']);

    bool _tomado;

    switch(data['tomado']) {
      case 0:
        _tomado = false;
        break;
      case 1:
        _tomado = true;
        break;
      default:
        _tomado = false;
        break;
    }

    final Remedio remedio = Remedio(
      id : data['id'],
      nome : data['nome'],
      medida : data['medida'],
      quantia : data['quantia'] is double ? data['quantia'] : double.parse(data['quantia']),
      horario : TimeOfDay.fromDateTime(_dateTime),
      tomado: _tomado,
    );

    return remedio;
  }

  factory Remedio.fromJson(String data) => Remedio.fromMap(json.decode(data));

  Map<String, dynamic> toMap([bool mostrarTomado = false]) {
    int _tomado;

    switch(tomado) {
      case true:
        _tomado = 1;
        break;
      case false:
        _tomado = 0;
        break;
      default:
        _tomado = 0;
        break;
    }

    Map<String, dynamic> data = {
      'id': id,
      'nome': nome,
      'medida': medida,
      'quantia': quantia,
      'horario': _horario,
      'tomado': mostrarTomado ? _tomado : null,
    };

    data.removeWhere((key, value) {
      return value == null;
    });

    return data;
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() => toJson();
}