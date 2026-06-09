import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_pic_setup_screen.dart';
import 'screens/personal_data_setup_screen.dart';
import 'screens/goals_setup_screen.dart';
import 'services/session_manager.dart';

void main() async {
  // Ensure Flutter binding is initialized for SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();

  final sessionManager = SessionManager();
  final hasToken = await sessionManager.hasToken();
  final isOnboardingCompleted = await sessionManager.isOnboardingCompleted();

  String initialRoute = '/welcome';
  if (hasToken) {
    if (isOnboardingCompleted) {
      initialRoute = '/home';
    } else {
      initialRoute = '/profile-pic-setup';
    }
  }

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String? initialRoute;
  final bool? isLoggedIn;

  const MyApp({super.key, this.initialRoute, this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final effectiveInitialRoute = initialRoute ?? ((isLoggedIn == true) ? '/home' : '/welcome');
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
      initialRoute: effectiveInitialRoute,
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
