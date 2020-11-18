import 'dart:convert';
import 'package:observe/models/item.dart';
import 'package:observe/models/remedio.dart';

class Alarme extends Item {
  final Remedio remedio;
  int  id;
  bool ligado;
  String get titulo => remedio.nome;
  int get horas => remedio.horario.hour;
  int get minutos => remedio.horario.minute;

  String get texto {
    final double _quantia = remedio.quantia;
    String _medida = remedio.medida;

    if (_medida == 'unidade') {
      _medida += _quantia.ceil() > 2 ? 's' : '';
    }

    return '$_quantia $_medida';
  }

  Alarme({this.id, this.remedio, this.ligado =  false}) :assert(remedio != null);

  factory Alarme.fromJson(String data) => Alarme.fromMap(json.decode(data));

  factory Alarme.fromMap(Map<String, dynamic> data) => Alarme(
    id: data['id'],
    ligado: data['ligado'],
    remedio: Remedio.fromMap(data['remedio']),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'ligado': ligado,
    'remedio': remedio.toMap(),
  };

  String toJson() => json.encode(toMap());

  @override
  String toString() => toJson();
}