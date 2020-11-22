import 'package:observe/classes/tabela_abstract.dart';
import 'package:observe/models/alarme.dart';

class TabelaAlarme extends Tabela {
  TabelaAlarme([database]) : super('alarme', database);

  @override
  Future<void> create(Alarme alarme) async {
    var result = await database.insert(tabela, alarme.toMap());
    print('result : $result');
  }

  @override
  Future<List<Alarme>> read() async {
    var result = await database.query(tabela);
    List<Alarme> _alarmes = result.map((e) => Alarme.fromMap(e)).toList();

    return _alarmes;
  }

  @override
  Future<void> update(Alarme alarme) async {
    var result = await database.update(tabela, alarme.toMap(), where: 'id = ?', whereArgs: [alarme.id]);
    print('result : $result');
  }

  @override
  Future<void> delete(int id) async {
    return await database.delete(tabela, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<Alarme> select(int id) async {
    var result = await database.query(tabela, where: 'id = ?', whereArgs: [id]);
    List<Alarme> _alarmes = result.map((e) => Alarme.fromMap(e)).toList();

    return _alarmes.single;
  }
}