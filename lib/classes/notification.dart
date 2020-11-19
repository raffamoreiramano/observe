import 'dart:convert';

class ObserveNotification {
  final int id;
  final String type;
  final String title;
  final String body;
  final String payload;

  ObserveNotification({
    this.id,
    this.type,
    this.title,
    this.body,
    this.payload,
  });

  factory ObserveNotification.fromMap(Map<String, dynamic> data) => ObserveNotification(
    id: data['id'],
    type: data['type'],
    title: data['title'],
    body: data['body'],
    payload: data['payload'],
  );

  factory ObserveNotification.fromJson(String data) => ObserveNotification.fromMap(json.decode(data));

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type,
    'title': title,
    'body':body,
    'payload': payload,
  };

  String toJson() => json.encode(toMap());

  @override
  String toString() => toJson();
}