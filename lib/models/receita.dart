import 'package:cloud_firestore/cloud_firestore.dart';

class Receita {
  String uid, username, nome, email, bio, rg, localidade, cpfcnpj;
  Timestamp cadastro, nascimento;

  Receita({
    this.uid,
    this.username,
    this.nome,
    this.email,
    this.bio,
    this.rg,
    this.localidade,
    this.cpfcnpj,
    this.cadastro,
    this.nascimento,
  });

  Receita.fromMap({String uid, Map<String, dynamic> data}) {
    this.uid = uid;
    this.username = data['username'];
    this.nome = data['nome'];
    this.email = data['email'];
    this.bio = data['email'];
    this.rg = data['rg'];
    this.localidade = data['localidade'];
    this.cpfcnpj = data['cpfcnpj'];
    this.cadastro = data['cadastro'];
    this.nascimento = data['nascimento'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {
      'username': username,
      'nome': nome,
      'email': email,
      'rg': rg,
      'localidade': localidade,
      'cpf_cnpj': cpfcnpj,
      'cadastro': cadastro,
      'nascimento': nascimento,
    };

    data.removeWhere((key, value) => value == null);

    return data;
  }
}