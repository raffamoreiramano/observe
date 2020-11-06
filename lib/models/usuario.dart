class Usuario {
  String uid, nome, sobrenome, email;

  Usuario({
    this.uid,
    this.nome,
    this.sobrenome,
    this.email,
  });

  Usuario.fromMap({String uid, Map<String, dynamic> data}) {
    this.uid = uid;
    this.sobrenome = data['sobrenome'];
    this.nome = data['nome'];
    this.email = data['email'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {
      'sobrenome': sobrenome,
      'nome': nome,
      'email': email,
    };

    data.removeWhere((key, value) => value == null);

    return data;
  }
}