import 'package:observe/classes/tabela_abstract.dart';
import 'package:observe/models/item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class LocalDatabase {
  static Database _database;
  static LocalDatabase _localDB;

  static Tabela _table;

  Future defineTable(covariant Tabela table) async {
    table.database = await database;
    _table = table;
  }

  LocalDatabase._createInstance();

  factory LocalDatabase([Tabela table]) {
    return _localDB ??= LocalDatabase._createInstance();
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    var dir = await getDatabasesPath();
    var path = dir + "observe.db";

    var database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE remedio ('
          'id INTEGER PRIMARY KEY, '
          'nome TEXT NOT NULL, '
          'medida TEXT NOT NULL, '
          'quantia TEXT NOT NULL, '
          'horario TEXT NOT NULL, '
          'tomado INTEGER DEFAULT 0);'
        );
        await db.execute(
          'CREATE TABLE alarme ('
          'id INTEGER PRIMARY KEY, '
          'ligado INTEGER DEFAULT 0);'
        );
        await db.execute(
          'CREATE TABLE tratamento ('
          'id INTEGER PRIMARY KEY, '
          'mid INTEGER NOT NULL, '
          'pid INTEGER NOT NULL, '
          'medico TEXT NOT NULL, '
          'paciente TEXT NOT NULL, '
          'inicio TEXT NOT NULL, '
          'retorno TEXT NOT NULL, '
          'estado REAL);'
        );
      },
    );
    
    return database;
  }

  Future<void> create(covariant Item objeto) async {
    await _table?.create(objeto);
  }

  Future<List<Item>> read() async {
    return await _table?.read();
  }

  Future<void> update(covariant Item objeto) async {
    await _table?.update(objeto);
  }

  Future<void> delete(int id) async {
    await _table?.delete(id);
  }

  Future<Item> select(int id) async {
    return await _table?.select(id);
  }

  Future<void> clear() async {
    return await _table?.clear();
  }

  Future<void> destroy() async {
    var db = await database;

    await db.delete('remedio');
    await db.delete('alarme');
  }
}