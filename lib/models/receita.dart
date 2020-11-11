import 'dart:convert';
import 'package:observe/models/remedio.dart';

class Receita {
  int id, mid, pid;
  List<Remedio> remedios;

  Receita({
    this.id,
    this.mid,
    this.pid,
    this.remedios,
  });

  Receita.fromMap(Map<String, dynamic> data) {
    final List<Remedio> _remedios = 
      List.from(data['remedios'])
      .map((remedio) => Remedio.fromMap(remedio))
      .toList();

    this.id = data['id'];
    this.mid = data['mid'];
    this.pid = data['pid'];
    this.remedios = _remedios;
  }

  Receita.fromJson(String data) {
    final _data = json.decode(data);

    final _remedios = 
      List.from(_data['remedios'])
      .map((remedio) => Remedio.fromMap(remedio))
      .toList();

    this.id = _data['id'];
    this.mid = _data['mid'];
    this.pid = _data['pid'];
    this.remedios = _remedios;
  }

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

  String toJson() {
    return json.encode(toMap());
  }

  @override
  String toString() {
    return toJson();
  }
}