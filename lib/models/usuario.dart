import 'dart:convert';

class Usuario {
  String id, cid, nome, sobrenome, email;

  Usuario({
    this.id,
    this.cid,
    this.nome,
    this.sobrenome,
    this.email,
  });

  Usuario.fromMap({String id, Map<String, dynamic> data}) {
    this.id = id;
    this.cid = data['uid'];
    this.nome = data['nome'];
    this.sobrenome = data['sobrenome'];
    this.email = data['email'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {
      'cid': cid,
      'nome': nome,
      'sobrenome': sobrenome,
      'email': email,
    };

    data.removeWhere((key, value) => value == null);

    return data;
  }

  @override
  String toString() {
    return json.encode(toMap());
  }
}