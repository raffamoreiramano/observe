import 'dart:convert';

class Usuario {
  int id;
  String cid, nome, sobrenome;

  Usuario({
    this.id,
    this.cid,
    this.nome,
    this.sobrenome,
  });

  Usuario.fromMap({int id, Map<String, dynamic> data}) {
    this.id = id;
    this.cid = data['cid'];
    this.nome = data['nome'];
    this.sobrenome = data['sobrenome'];
  }

  Usuario.fromJson(String data) {
    final _data = json.decode(data);

    this.id = _data['id'];
    this.cid = _data['cid'];
    this.nome = _data['nome'];
    this.sobrenome = _data['sobrenome'];
  }

  Map<String, dynamic> toMap({bool includeId = false}) {
    final Map<String, dynamic> data = {
      'id': includeId? id : null,
      'cid': cid,
      'nome': nome,
      'sobrenome': sobrenome,
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