import 'package:flutter/material.dart';  
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase_options.dart';

import 'screens/welcome_page.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/sign_up_page.dart';
import 'screens/settings_page.dart';
import 'screens/history_page.dart';
import 'screens/alerts_page.dart';
import 'screens/child_info_page.dart';
import 'screens/add_child_info_page.dart'; 

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  const AndroidInitializationSettings androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');       
  
  const InitializationSettings initSettings =
      InitializationSettings(android: androidInitSettings);

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  runApp(const KidSafeBreathApp());
}

class KidSafeBreathApp extends StatelessWidget {
  const KidSafeBreathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KIDSAFE BREATH',
      theme: ThemeData(
        primaryColor: const Color(0xFF8EA7B5),
        scaffoldBackgroundColor: const Color(0xFF8EA7B5),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF8EA7B5),
          titleTextStyle: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8EA7B5),
          ),
        ),
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          bodyLarge: const TextStyle(color: Colors.white),
          bodyMedium: const TextStyle(color: Colors.white),
        ),
      ),
      supportedLocales: const [
        Locale('en', ''),
        Locale('ar', ''),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/signup': (context) => const SignUpPage(),
        '/settings': (context) => const SettingsPage(),
        '/history': (context) => const HistoryPage(),
        '/alerts': (context) => const AlertsPage(),
        '/child-info': (context) => const ChildInfoPage(),
        '/add-child-info': (context) => const AddChildInfoPage(), 
      },
    );
  }
}
