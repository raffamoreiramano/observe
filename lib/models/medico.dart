import 'dart:convert';

class Medico {
  int id, uid;
  String crm;

  bool get isEmpty {
    return toMap().isEmpty;
  }

  bool get isNotEmpty {
    return toMap().isNotEmpty;
  }

  Medico({
    this.id,
    this.uid,
    this.crm,
  });

  Medico.fromMap(Map<String, dynamic> data) {
    this.id = data['id'];
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
    return toJson();
  }
}