import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/time_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'forgot_password_screen.dart';
import '../../core/main_screen.dart';
import '../doctor/doctor_main_screen.dart'; // 🔥 صح
import '../patient/patient_main_screen.dart';
import '../admin/admin_main_screen.dart';
import '../../main.dart';
import '../../core/auth_credentials.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String selectedRole = "Referral";
  bool isPasswordVisible = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _logLoginAttempt({required bool success, required String email}) async {
    try {
      String ip = "Unknown IP";
      try {
        final interfaces = await NetworkInterface.list();
        for (var interface in interfaces) {
          for (var addr in interface.addresses) {
            if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
              ip = addr.address;
              break;
            }
          }
          if (ip != "Unknown IP") break;
        }
      } catch (e) {
        debugPrint("Error getting IP: $e");
      }

      String deviceModel = "Unknown Device";
      try {
        final deviceInfo = DeviceInfoPlugin();
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          deviceModel = "${androidInfo.manufacturer} ${androidInfo.model}";
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          deviceModel = iosInfo.name;
        }
      } catch (e) {
        debugPrint("Error getting device info: $e");
      }

      // Format time
      final now = TimeService.now();
      final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
      final minute = now.minute.toString().padLeft(2, '0');
      final ampm = now.hour >= 12 ? 'PM' : 'AM';
      final timeStr = "$hour:$minute $ampm";

      if (success) {
        await FirebaseFirestore.instance.collection('activity_logs').add({
          'title': 'User Login Success',
          'subtitle': 'IP: $ip • User: $email • Device: $deviceModel',
          'time': timeStr,
          'type': 'success',
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        await FirebaseFirestore.instance.collection('activity_logs').add({
          'title': 'Failed Login Attempt',
          'subtitle': 'IP: $ip • User: ${email.isEmpty ? "Unknown" : email} • Device: $deviceModel',
          'time': timeStr,
          'type': 'error',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint("Failed to log activity: $e");
    }
  }

  Future<void> login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showError("Please fill all fields");
      return;
    }

    if (!email.contains('@')) {
      email = "${email.toLowerCase().replaceAll(" ", "")}@app.com";
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      var doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!doc.exists) {
        if (email.toLowerCase() == 'admin@app.com') {
          // Fix missing Firestore document for the admin user
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'name': 'System Admin',
            'email': 'admin@app.com',
            'role': 'Admin',
            'status': 'Active',
          });
          // Re-fetch the doc
          doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        } else {
          await FirebaseAuth.instance.signOut();
          showError("User data not found");
          _logLoginAttempt(success: false, email: email);
          return;
        }
      }

      String role = (doc['role'] ?? "referral").toString().trim();

      if (role.toLowerCase() != selectedRole.toLowerCase().trim()) {
        await FirebaseAuth.instance.signOut();
        showError("Wrong role selected");
        _logLoginAttempt(success: false, email: email);
        return;
      }

      // Save credentials for restoring session in case of KGP/secondary app conflicts
      AuthCredentials.email = email;
      AuthCredentials.password = password;

      _logLoginAttempt(success: true, email: email);

      if (!mounted) return;

      if (role.toLowerCase() == "doctor") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DoctorMainScreen(),
          ),
        );
      } else if (role.toLowerCase() == "patient") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const PatientMainScreen(),
          ),
        );
      } else if (role.toLowerCase() == "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminMainScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainScreen(),
          ),
        );
      }

    } on FirebaseAuthException catch (e) {
      showError(e.message ?? "Login failed");
      _logLoginAttempt(success: false, email: email);
      if (email.isNotEmpty) {
        _triggerAdminAlertForFailedLogin(email);
      }
    }
  }

  Future<void> _triggerAdminAlertForFailedLogin(String email) async {
    try {
      var query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      QueryDocumentSnapshot? doc;
      if (query.docs.isNotEmpty) {
        doc = query.docs.first;
      } else {
        final referralQuery = await FirebaseFirestore.instance
            .collection('referrals')
            .where('email', isEqualTo: email)
            .get();
        if (referralQuery.docs.isNotEmpty) {
          doc = referralQuery.docs.first;
        }
      }

      if (doc != null) {
        final uid = doc.id;
        final data = doc.data() as Map<String, dynamic>;
        final name = data['name'] ?? 'Unknown';
        final role = data['role'] ?? 'patient';

        // Check if there is already a pending request
        final existing = await FirebaseFirestore.instance
            .collection('password_reset_requests')
            .where('uid', isEqualTo: uid)
            .where('status', isEqualTo: 'pending')
            .get();

        if (existing.docs.isEmpty) {
          await FirebaseFirestore.instance.collection('password_reset_requests').add({
            'uid': uid,
            'name': name,
            'role': role,
            'email': email,
            'status': 'pending',
            'timestamp': FieldValue.serverTimestamp(),
          });
          debugPrint("Admin alert triggered for failed login of $email");
        }
      }
    } catch (e) {
      debugPrint("Error triggering failed login alert: $e");
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xff121212) : const Color(0xffF3F4F6);
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;
    final inputBg = isDark ? const Color(0xff1E1E1E) : Colors.grey.shade200;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: bg,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom, // 🔥 أهم سطر
          ),
          child: Column(
            children: [

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(Icons.language, size: 18, color: textColor),
                      const SizedBox(width: 5),
                      Text("EN", style: TextStyle(color: textColor)),
                      const SizedBox(width: 15),
                      ValueListenableBuilder<ThemeMode>(
                        valueListenable: themeNotifier,
                        builder: (context, themeMode, _) {
                          final localIsDark = themeMode == ThemeMode.dark;
                          return GestureDetector(
                            onTap: () {
                              themeNotifier.value =
                                  localIsDark ? ThemeMode.light : ThemeMode.dark;
                            },
                            child: Icon(
                              localIsDark ? Icons.light_mode : Icons.dark_mode,
                              color: localIsDark ? Colors.amber : Colors.black87,
                              size: 20,
                            ),
                          );
                        },
                      ),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 20),

              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.blue.shade100,
                child: const Icon(Icons.add_box,
                    color: Colors.blue, size: 30),
              ),

              const SizedBox(height: 15),

              Text(
                "AI Recovery",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor),
              ),

              const SizedBox(height: 5),

              Text(
                "Professional Recovery Management",
                style: TextStyle(color: subtextColor),
              ),

              const SizedBox(height: 20),

              Text(
                "SELECT YOUR ROLE",
                style: TextStyle(fontSize: 12, color: subtextColor),
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(child: roleCard("Referral", Icons.people)),
                  const SizedBox(width: 10),
                  Expanded(child: roleCard("Doctor", Icons.medical_services)),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(child: roleCard("Patient", Icons.person)),
                  const SizedBox(width: 10),
                  Expanded(child: roleCard("Admin", Icons.admin_panel_settings)),
                ],
              ),

              const SizedBox(height: 20),

              TextField(
                controller: emailController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: "Enter your Username",
                  hintStyle: TextStyle(color: subtextColor),
                  prefixIcon: Icon(Icons.alternate_email, color: subtextColor),
                  filled: true,
                  fillColor: inputBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  hintStyle: TextStyle(color: subtextColor),
                  prefixIcon: Icon(Icons.lock, color: subtextColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: subtextColor,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: inputBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.blue.shade600),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2F6FED),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: login,
                  child: const Text(
                    "Login to Account →",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget roleCard(String title, IconData icon) {
    final isSelected = selectedRole == title;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = title;
        });
      },
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.blue.withValues(alpha: 0.15) : Colors.blue.shade50)
              : (isDark ? const Color(0xff1E1E1E) : Colors.transparent),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.blue
                : (isDark ? const Color(0xff2A2A2A) : Colors.grey.shade300),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isSelected ? Colors.blue : (isDark ? Colors.grey[400] : Colors.grey)),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.blue : (isDark ? Colors.white : Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}