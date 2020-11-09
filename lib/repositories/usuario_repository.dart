import 'package:observe/models/usuario.dart';
import 'package:observe/services/api.dart';

class UsuarioRepository {
  final ObserveAPI _api = ObserveAPI();
  final String _route = 'usuarios';

  Future<Usuario> createUsuario(Usuario usuario) async {
    try {
      APIResponse response = await _api.post(route: _route, data: usuario.toJson());

      if (response.status != 201) {
        throw response;
      }

      return Usuario.fromJson(response.data);
    } on APIResponse {
      rethrow;
    }
  }

  Future<Usuario> readUsuario(int id) async {
    try {
      APIResponse response = await _api.get('$_route/$id');

      if (response.status != 200) {
        throw response;
      }

      return Usuario.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Usuario> updateUsuario({int id, Usuario data}) async {
    try {
      APIResponse response = await _api.put(route: _route, id: id, data: data.toString());

      if (response.status != 204) {
        throw response;
      }

      return await readUsuario(id);
    } on APIResponse {
      rethrow;
    }
  }

  Future<Usuario> deleteUsuario(int id) async {
    try {
      APIResponse response = await _api.delete(route: _route, id: id);

      if (response.status != 200) {
        throw response;
      }

      return Usuario.fromJson(response.data);
    } on APIResponse {
      rethrow;
    }
  }
}