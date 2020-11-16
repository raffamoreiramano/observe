import 'dart:convert';

class APIResponse {
  final int status;
  final String data;

  APIResponse({
    this.status,
    this.data,
  });

  @override
  String toString() {
    return json.encode({
      'status': status,
      'data': data
    });
  }
}