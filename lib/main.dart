import 'package:farmer_app/auth_screen.dart';
import 'package:farmer_app/error_screen.dart';
import 'package:farmer_app/home_screen.dart';
import 'package:farmer_app/planting_screen.dart';
import 'package:farmer_app/sensing_screen.dart';
import 'package:farmer_app/signin_screen.dart';
import 'package:farmer_app/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  debugPrint("Main Started Application");

  // Ensure Flutter is properly initialized before calling async code
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmers App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
// Define all your named routes here
      routes: {
        '/': (context) => AuthScreen(), //  starting screen (AuthScreen)
        '/signin': (context) => const SignInScreen(), // Sign-in screen
        '/signup': (context) => const SignUpScreen(), // Sign-up screen
        '/home': (context) =>
            const HomeScreen(), // Home screen after login and signup
        '/sensing': (context) => const SensingScreen(), // Sensing screen
        '/planting': (context) => const PlantingScreen(), // Planting screen
      },
      // Optional: Handle undefined routes (for unknown URLs)
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const ErrorScreen(), // A generic error screen
        );
      },
    );
  }
}
