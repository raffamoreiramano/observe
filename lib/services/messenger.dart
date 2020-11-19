import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:observe/classes/notification.dart';

class CloudMessenger {
  FirebaseFirestore _db = FirebaseFirestore.instance;
  FirebaseMessaging _fcm = FirebaseMessaging();

  initialize({
    Future<dynamic> Function(ObserveNotification notification) onMessage,
    Future<dynamic> Function(ObserveNotification notification) onLaunch,
    Future<dynamic> Function(ObserveNotification notification) onResume,
  }) {
    _fcm.configure(
      onMessage: (message) async {
        onMessage.call(ObserveNotification.fromMap(message));
      },
      onLaunch: (message) async {
        onLaunch.call(ObserveNotification.fromMap(message));
      },
      onResume: (message) async {
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
        .collection('pacientes')
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