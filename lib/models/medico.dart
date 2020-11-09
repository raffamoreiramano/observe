import 'dart:convert';

class Medico {
  int id, uid;
  String crm;

  Medico({
    this.id,
    this.uid,
    this.crm,
  });

  Medico.fromMap({int id, Map<String, dynamic> data}) {
    this.id = id;
    this.uid = data['uid'];
    this.crm = data['crm'];
  }

  Medico.fromJson(String data) {
    final _data = json.decode(data);

    this.id = _data['id'];
    this.uid = _data['uid'];
    this.crm = _data['crm'];
  }

  Map<String, dynamic> toMap({bool includeId = false}) {
    final Map<String, dynamic> data = {
      'id': includeId? id : null,
      'uid': uid,
      'crm': crm,
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