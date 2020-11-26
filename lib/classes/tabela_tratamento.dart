import 'package:observe/classes/tabela_abstract.dart';
import 'package:observe/models/tratamento.dart';

class TabelaTratamento extends Tabela {
  TabelaTratamento([database]) : super('tratamento', database);

  @override
  Future<void> create(Tratamento tratamento) async {
    await database.insert(tabela, tratamento.toMap());
  }

  @override
  Future<List<Tratamento>> read() async {
    var result = await database.query(tabela);
    List<Tratamento> _tratamentos = result.map((e) => Tratamento.fromMap(e)).toList();

    return _tratamentos;
  }

  @override
  Future<void> update(Tratamento tratamento) async {
    await database.update(tabela, tratamento.toMap(), where: 'id = ?', whereArgs: [tratamento.id]);
  }

  @override
  Future<void> delete(int id) async {
    return await database.delete(tabela, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<Tratamento> select(int id) async {
    var result = await database.query(tabela, where: 'id = ?', whereArgs: [id]);
    List<Tratamento> _tratamentos = result.map((e) => Tratamento.fromMap(e)).toList();

    return _tratamentos.single;
  }
}