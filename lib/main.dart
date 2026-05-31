// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'services/notification_service.dart';
import 'models/user_model.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'uj_isms.dart';
import 'first_page.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseAppCheck.instance.activate(androidProvider: AndroidProvider.debug);
  await NotificationService().initialize();
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: const UjIsmsApp(),
    ),
  );
}

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  UserModel? get user => _user;
  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }
  void clearUser() {
    _user = null;
    notifyListeners();
  }
}

class UjIsmsApp extends StatelessWidget {
  const UjIsmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UJ ISMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: const Color(0xFFF4F7F6),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF062C2B)),
        useMaterial3: true,
      ),
      routes: {
        '/sign_in': (ctx) => const SignInScreen(),
        '/sign_up': (ctx) => const SignUpScreen(),
        '/home':    (ctx) => const UjIsmsShell(),
      },
      home: FirstPage(),
    );
  }
}