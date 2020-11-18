import 'package:observe/classes/api_response.dart';
import 'package:observe/models/receita.dart';
import 'package:observe/services/api.dart';

class ReceitaRepository {
  final ObserveAPI _api = ObserveAPI();
  final String _route = 'Receitas';

  Future<Receita> createReceita(Receita receita) async {
    try {
      APIResponse response = await _api.post(route: _route, data: receita.toJson());

      if (response.status != 201) {
        throw response;
      }

      return Receita.fromJson(response.data);
    } on APIResponse {
      rethrow;
    }
  }

  Future<Receita> readReceita(int id) async {
    try {
      APIResponse response = await _api.get('$_route/id/$id');

      if (response.status != 200) {
        throw response;
      }

      return Receita.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Receita> updateReceita({int id, Receita data}) async {
    try {
      APIResponse response = await _api.put(route: _route, id: id, data: data.toString());

      if (response.status != 204) {
        throw response;
      }

      return await readReceita(id);
    } on APIResponse {
      rethrow;
    }
  }

  Future<Receita> deleteReceita(int id) async {
    try {
      APIResponse response = await _api.delete(route: _route, id: id);

      if (response.status != 200) {
        throw response;
      }

      return Receita.fromJson(response.data);
    } on APIResponse {
      rethrow;
    }
  }
}