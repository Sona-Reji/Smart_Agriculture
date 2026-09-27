import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/farmer_onboarding_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint("Firebase init note: $e");
  }
  runApp(const SmartAgriApp());
}

class SmartAgriApp extends StatelessWidget {
  const SmartAgriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Agri Monitoring',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData && snapshot.data != null) {
            final uid = snapshot.data!.uid;
            return StreamBuilder<DatabaseEvent>(
              stream: FirebaseDatabase.instance.ref('users/$uid/profile/isOnboarded').onValue,
              builder: (context, onboardSnap) {
                if (onboardSnap.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }
                final isOnboarded = onboardSnap.data?.snapshot.value == true;
                if (isOnboarded) {
                  return const MainNavigationScreen();
                } else {
                  return const FarmerOnboardingScreen();
                }
              },
            );
          }
          return const LoginScreen();
        },
      );
    } catch (e) {
      debugPrint("AuthWrapper stream error: $e");
      return const LoginScreen();
    }
  }
}
