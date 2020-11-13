import 'dart:convert';

class Remedio {
  String nome, medida, horario;
  double quantia;

  bool get isEmpty {
    return toMap().isEmpty;
  }

  bool get isNotEmpty {
    return toMap().isNotEmpty;
  }
  
  Remedio({
    this.nome,
    this.medida,
    this.quantia,
    this.horario,
  });

  Remedio.fromMap(Map<String, dynamic> data) {
    this.nome = data['nome'];
    this.medida = data['medida'];
    this.quantia = data['quantia'];
    this.horario = data['horario'];
  }

  Remedio.fromJson(String data) {
    final _data = json.decode(data);

    this.nome = _data['nome'];
    this.medida = _data['medida'];
    this.quantia = _data['quantia'];
    this.horario = _data['horario'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {
      'nome': nome,
      'medida': medida,
      'quantia': quantia,
      'horario': horario,
    };

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