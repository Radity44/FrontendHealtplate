import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_pic_setup_screen.dart';
import 'screens/personal_data_setup_screen.dart';
import 'screens/goals_setup_screen.dart';

void main() async {
  // Ensure Flutter binding is initialized for SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  // Check if the user is logged in (defaults to false)
  final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthPlate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF095D40), // Forest Green
          primary: const Color(0xFF14B8A6), // Teal Accent
        ),
        useMaterial3: true,
      ),
      initialRoute: isLoggedIn ? '/home' : '/welcome',
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile-pic-setup': (context) => const ProfilePicSetupScreen(),
        '/personal-data-setup': (context) => const PersonalDataSetupScreen(),
        '/goals-setup': (context) => const GoalsSetupScreen(),
      },
    );
  }
}
