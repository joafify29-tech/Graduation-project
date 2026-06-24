import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

import 'features/auth/login_screen.dart';
import 'core/main_screen.dart';
import 'features/doctor/doctor_main_screen.dart';
import 'features/patient/patient_main_screen.dart';
import 'features/admin/admin_main_screen.dart';
import 'services/time_service.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  TimeService.syncTime();
  runApp(const AIRecoveryApp());
}

class AIRecoveryApp extends StatelessWidget {
  const AIRecoveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'AI Recovery',
          themeMode: currentMode,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xffF7F8FA),
            primaryColor: const Color(0xff2F6FED),
            fontFamily: 'Roboto',
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xff121212),
            primaryColor: const Color(0xff2F6FED),
            fontFamily: 'Roboto',
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xff121212),
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            cardColor: const Color(0xff1E1E1E),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xff1E1E1E),
              selectedItemColor: Color(0xff2F6FED),
              unselectedItemColor: Colors.grey,
            ),
          ),
          home: FutureBuilder(
            future: Firebase.apps.isEmpty
                ? Firebase.initializeApp(
                    options: DefaultFirebaseOptions.currentPlatform,
                  )
                : Future.value(null),
            builder: (context, firebaseSnapshot) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              if (firebaseSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  backgroundColor: isDark ? const Color(0xff121212) : const Color(0xffF7F8FA),
                  body: const Center(
                    child: CircularProgressIndicator(color: Color(0xff2F6FED)),
                  ),
                );
              }
              if (firebaseSnapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Text('Firebase Error: ${firebaseSnapshot.error}'),
                  ),
                );
              }
              return StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const LoginScreen();
                  }

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(snapshot.data!.uid)
                        .get(),
                    builder: (context, roleSnapshot) {
                      if (roleSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Scaffold(
                          body: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (!roleSnapshot.hasData ||
                          !roleSnapshot.data!.exists) {
                        return const LoginScreen();
                      }

                      final data =
                          roleSnapshot.data!.data() as Map<String, dynamic>;

                      final role =
                          (data['role'] ?? "referral")
                              .toString()
                              .toLowerCase();

                      if (role == "doctor") {
                        return const DoctorMainScreen();
                      }

                      if (role == "patient") {
                        return const PatientMainScreen();
                      }

                      if (role == "admin") {
                        return const AdminMainScreen();
                      }

                      return const MainScreen();
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}