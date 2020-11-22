import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:observe/helpers/preferences.dart';
import 'package:observe/services/auth.dart';
import 'package:observe/views/authentication_page.dart';
import 'package:observe/views/main_page.dart';
import 'package:observe/views/verification_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();

Function onSelectNotification;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid
  );

  tz.initializeTimeZones();


  await notifications.initialize(
    initializationSettings,
    onSelectNotification: onSelectNotification,
  );

  await Firebase.initializeApp();
  
  final SharedPreferences preferences = await SharedPreferences.getInstance();

  runApp(MyApp(preferences));
}

class MyApp extends StatelessWidget {
  final SharedPreferences _sp;

  MyApp(this._sp) : assert(_sp != null);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Preferences>(
          create: (context) => Preferences(_sp),
        ),
        Provider<AuthMethods>(
          create: (context) => AuthMethods(FirebaseAuth.instance),
        ),
        Provider<FlutterLocalNotificationsPlugin>(
          create: (context) => notifications,
        ),
        StreamProvider<User>(
          create: (context) => context.read<AuthMethods>().authState,
        ),
      ],
      child: GetMaterialApp(
        // debugShowCheckedModeBanner: false,
        title: 'Observe',
        home: AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  AuthenticationWrapper() {
    onSelectNotification = (String payload) {
      print('############');
    };
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<User>(context);

    if (user != null) {
      return user.emailVerified ? MainPage() : VerificationPage();
    } else {
      return Authentication();   
    }
  }
}