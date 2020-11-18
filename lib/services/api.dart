import 'package:dio/dio.dart';
import 'package:observe/classes/api_response.dart';



class ObserveAPI {
  final String _path = 'http://localhost:5000/api';
  Dio _dio = Dio();
  Options _options = Options(
    contentType: 'application/json',
    followRedirects: false,
    validateStatus: (status) {
      return status < 500;
    },
  );

  Future<APIResponse> get(String route) async {
    Response response = await _dio.get(
      [_path, route].join('/'),
      options: _options
    );

    return APIResponse(
      status: response.statusCode,
      data: response.statusCode != 200
        ? response.statusMessage
        : response.toString()
    );
  }

  Future<APIResponse> post({String route, String data}) async {
    Response response = await _dio.post(
      [_path, route].join('/'),
      options: _options,
      data: data
    );

    return APIResponse(
      status: response.statusCode,
      data: response.statusCode != 201
        ? response.statusMessage
        : response.toString()
    );
  }

  Future<APIResponse> put({String route, int id, String data}) async {
    Response response = await _dio.put(
      [_path, route, 'id', id].join('/'),
      options: _options,
      data: data
    );

    return APIResponse(
      status: response.statusCode,
      data: response.statusCode != 204
        ? response.statusMessage
        : response.toString()
    );
  }

  Future<APIResponse> delete({String route, int id}) async {
    Response response = await _dio.delete(
      [_path, route, id].join('/'),
      options: _options
    );

    return APIResponse(
      status: response.statusCode,
      data: response.statusCode != 200
        ? response.statusMessage
        : response.toString()
    );
  }
}