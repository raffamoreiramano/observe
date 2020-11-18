import 'package:observe/models/alarme.dart';
import 'package:observe/models/item.dart';
import 'package:observe/models/remedio.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

abstract class Tabela {
  Database database;
  String tabela;
  Future<void> create(covariant Item item);
  Future<Item> select(int id);
  Future<List<Item>> read();
  Future<void> update(covariant Item item);
  Future<void> delete(int id);

  Tabela(this.tabela, [this.database]);

  Future<void> clear() async {
    return await database.delete(tabela);
  }
}

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
    var result = await database.update(tabela, remedio.toMap(), where: 'id = ?', whereArgs: [remedio.id]);
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