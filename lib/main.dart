import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:observe/services/auth.dart';
import 'package:observe/views/authentication_page.dart';
import 'package:observe/views/main_page.dart';
import 'package:observe/views/verification_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthMethods>(
          create: (_) => AuthMethods(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (context) => context.read<AuthMethods>().authState,
        ),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Observe',
        home: AuthenticationWrapper(),
        theme: ThemeData(
          // brightness: Brightness.dark,
        ),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<User>();

    if (user != null) {
      return user.emailVerified ? MainPage() : VerificationPage();
    } else {
      return Authentication();   
    }
  }
}
