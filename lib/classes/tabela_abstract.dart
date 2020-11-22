import 'package:observe/models/item.dart';
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