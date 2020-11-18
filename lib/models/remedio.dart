import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:observe/models/item.dart';


class Remedio extends Item {
  int id;
  String nome, medida, _horario;
  double quantia;
  TimeOfDay horario;
  bool tomado = false;


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
    this.horario,
  }) {
    initializeDateFormatting('pt_BR', null);
    final DateFormat _format = DateFormat('HH:mm');

    _horario = _format.format(DateTime(0, 0, 0, horario.hour, horario.minute));
  }

  factory Remedio.fromMap(Map<String, dynamic> data) {
    final DateFormat _format = DateFormat('HH:mm');
    final DateTime _dateTime = _format.parse(data['horario']);    

    final Remedio remedio = Remedio(
      id : data['id'],
      nome : data['nome'],
      medida : data['medida'],
      quantia : data['quantia'],
      horario : TimeOfDay.fromDateTime(_dateTime),
    );

    return remedio;
  }

  factory Remedio.fromJson(String data) => Remedio.fromMap(json.decode(data));

  Map<String, dynamic> toMap([bool mostrarTomado = false]) {
    Map<String, dynamic> data = {
      'id': id,
      'nome': nome,
      'medida': medida,
      'quantia': quantia,
      'horario': _horario,
      'tomado': mostrarTomado ? tomado : null,
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