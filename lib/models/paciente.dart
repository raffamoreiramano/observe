import 'dart:convert';

class Paciente {
  int id, uid;
  DateTime nascimento;
  List<dynamic> doencas, alergias, remedios;

  bool get isEmpty {
    return toMap().isEmpty;
  }
  
  bool get isNotEmpty {
    return toMap().isNotEmpty;
  }

  Paciente({
    this.id,
    this.uid,
    this.nascimento,
    this.doencas,
    this.alergias,
    this.remedios,
  });

  Paciente.fromMap( Map<String, dynamic> data) {
    this.id = data['id'];
    this.uid = data['cid'];
    this.nascimento = DateTime.parse(data['nascimento']);
    this.doencas = data['doencas'];
    this.alergias = data['alergias'];
    this.remedios = data['remedios'];
  }

  Paciente.fromJson(String data) {
    final _data = json.decode(data);

    this.id = _data['id'];
    this.uid = _data['uid'];
    this.nascimento = DateTime.parse(_data['nascimento']);
    this.doencas = _data['doencas'];
    this.alergias = _data['alergias'];
    this.remedios = _data['remedios'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {
      'id': id,
      'uid': uid,
      'nascimento': nascimento?.toIso8601String(),
      'doencas': doencas,
      'alergias': alergias,
      'remedios': remedios,
    };

    data.removeWhere((key, value) {
      if (value is List) {
        return value.isEmpty;
      }

      return value == null;
    });

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