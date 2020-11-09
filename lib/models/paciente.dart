import 'dart:convert';

class Paciente {
  int id, uid;
  DateTime nascimento;
  List<dynamic> doencas, alergias, remedios;

  Paciente({
    this.id,
    this.uid,
    this.nascimento,
    this.doencas,
    this.alergias,
    this.remedios,
  });

  Paciente.fromMap({int id, Map<String, dynamic> data}) {
    this.id = id;
    this.uid = data['cid'];
    this.nascimento = DateTime.parse(data['nascimento']);
    this.doencas = data['doencas'];
    this.alergias = data['alergias'];
    this.remedios = data['remedios'];
  }

  Paciente.fromJson(String data) {
    final _data = json.decode(data);

    this.id = id;
    this.uid = _data['uid'];
    this.nascimento = DateTime.parse(_data['nascimento']);
    this.doencas = _data['doencas'];
    this.alergias = _data['alergias'];
    this.remedios = _data['remedios'];
  }

  Map<String, dynamic> toMap({bool includeId = false}) {
    final Map<String, dynamic> data = {
      'id': includeId? id : null,
      'uid': uid,
      'nascimento': nascimento.toIso8601String(),
      'doencas': doencas,
      'alergias': alergias,
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