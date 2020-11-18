import 'package:observe/classes/api_response.dart';
import 'package:observe/models/medico.dart';
import 'package:observe/services/api.dart';

class MedicoRepository {
  final ObserveAPI _api = ObserveAPI();
  final String _route = 'medicos';

  Future<Medico> createMedico(Medico medico) async {
    try {
      APIResponse response = await _api.post(route: _route, data: medico.toJson());

      if (response.status != 201) {
        throw response;
      }

      return Medico.fromJson(response.data);
    } on APIResponse {
      rethrow;
    }
  }

  Future<Medico> readMedico({int id, String cid}) async {
    try {
      if ((id == null && cid == null) || (id != null && cid != null)) {
        throw {
          'status': 400,
          'data': 'Bad Request'
        };
      }

      final _key = id == null ? 'cid/$cid' : 'id/$id';

      APIResponse response = await _api.get('$_route/$_key');

      if (response.status != 200) {
        throw response;
      }

      return Medico.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Medico> updateMedico({int id, Medico data}) async {
    try {
      APIResponse response = await _api.put(route: _route, id: id, data: data.toString());

      if (response.status != 204) {
        throw response;
      }

      return await readMedico(id: id);
    } on APIResponse {
      rethrow;
    }
  }

  Future<Medico> deleteMedico(int id) async {
    try {
      APIResponse response = await _api.delete(route: _route, id: id);

      if (response.status != 200) {
        throw response;
      }

      return Medico.fromJson(response.data);
    } on APIResponse {
      rethrow;
    }
  }
}