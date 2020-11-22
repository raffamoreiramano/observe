import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:observe/classes/notification.dart';

class CloudMessenger {
  final FirebaseFirestore _db;
  FirebaseMessaging _fcm = FirebaseMessaging();

  CloudMessenger(this._db);

  initialize({
    Future<dynamic> Function(ObserveNotification notification) onMessage,
    Future<dynamic> Function(ObserveNotification notification) onLaunch,
    Future<dynamic> Function(ObserveNotification notification) onResume,
  }) {
    _fcm.configure(
      onMessage: (message) async {
        print(message);
        onMessage.call(ObserveNotification.fromMap(message));
      },
      onLaunch: (message) async {
        print(message);
        onLaunch.call(ObserveNotification.fromMap(message));
      },
      onResume: (message) async {
        print(message);
        onResume.call(ObserveNotification.fromMap(message));
      },
    );
  }

  salvarTokenPaciente(int pid) async {
    var token = await _fcm.getToken();

    if (token != null) {
      var tokenRef = _db
        .collection('pacientes')
        .doc(pid.toString())
        .collection('tokens')
        .doc(token);
      
      await tokenRef.set({
        'token': token,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } 
  }

  salvarTokenMedico(int mid) async {
    var token = await _fcm.getToken();

    if (token != null) {
      var tokenRef = _db
        .collection('medicos')
        .doc(mid.toString())
        .collection('tokens')
        .doc(token);
      
      await tokenRef.set({
        'token': token,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } 
  }

  Future<bool> deletarToken() async {
    return await _fcm.deleteInstanceID(); 
  }
}