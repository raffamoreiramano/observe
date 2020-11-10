import 'dart:convert';
import 'package:observe/models/remedio.dart';

class Receita {
  int id, mid, pid;
  List<dynamic> remedios;

  Receita({
    this.id,
    this.mid,
    this.pid,
    this.remedios,
  });

  Receita.fromMap({int id, Map<String, dynamic> data}) {
    this.id = id;
    this.mid = data['mid'];
    this.pid = data['pid'];
    this.remedios = data['remedios'];
  }

  Receita.fromJson(String data) {
    final _data = json.decode(data);

    this.id = id;
    this.mid = _data['mid'];
    this.pid = _data['pid'];
    this.remedios = _data['remedios'];
  }

  Map<String, dynamic> toMap({bool includeId = false}) {
    final Map<String, dynamic> data = {
      'id': includeId? id : null,
      'mid': mid,
      'pid': pid,
      'remedios': remedios,
    };

    data.removeWhere((key, value) => value == null);

    return data;
  }

  String toJson() {
    return json.encode(toMap());
  }

  @override
  String toString() {
    return json.encode(toMap(includeId: true));
  }
}