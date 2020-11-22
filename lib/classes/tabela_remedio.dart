import 'package:observe/classes/tabela_abstract.dart';
import 'package:observe/models/remedio.dart';

class TabelaRemedio extends Tabela {
  TabelaRemedio([database]) : super('remedio', database);

  @override
  Future<void> create(Remedio remedio) async {
    var result = await database.insert(tabela, remedio.toMap());
    print('result : $result');
  }
  
  @override
  Future<List<Remedio>> read() async {
    var result = await database.query(tabela);
    List<Remedio> _remedios = result.map((e) => Remedio.fromMap(e)).toList();

    return _remedios;
  }

  @override
  Future<void> update(Remedio remedio) async {
    var result = await database.update(tabela, remedio.toMap(true), where: 'id = ?', whereArgs: [remedio.id]);
    print('result : $result');
  }

  @override
  Future<void> delete(int id) async {
    return await database.delete(tabela, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<Remedio> select(int id) async {
    var result = await database.query(tabela, where: 'id = ?', whereArgs: [id]);
    List<Remedio> _remedios = result.map((e) => Remedio.fromMap(e)).toList();

    return _remedios.single;
  }
}