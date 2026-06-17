import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'features/auth/login_screen.dart';
import 'core/main_screen.dart';
import 'features/doctor/doctor_main_screen.dart';
import 'features/patient/patient_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const AIRecoveryApp());
}

class AIRecoveryApp extends StatelessWidget {
  const AIRecoveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Recovery',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xffF7F8FA),
        primaryColor: const Color(0xff2F6FED),
        fontFamily: 'Roboto',
      ),

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {

          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Not logged in
          if (!snapshot.hasData) {
            return const LoginScreen();
          }

          // Logged in
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
                return const MainScreen();
              }

              final data =
                  roleSnapshot.data!.data() as Map<String, dynamic>;

              final role =
                  (data['role'] ?? "referral")
                      .toString()
                      .toLowerCase();

              // Doctor
              if (role == "doctor") {
                return const DoctorMainScreen();
              }

              // Patient
              if (role == "patient") {
                return const PatientMainScreen();
              }

              // Referral
              return const MainScreen();
            },
          );
        },
      ),
    );
  }
}