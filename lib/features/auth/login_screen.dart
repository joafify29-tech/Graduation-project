import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'forgot_password_screen.dart';
import '../../core/main_screen.dart';
import '../doctor/doctor_main_screen.dart'; // 🔥 صح
import '../patient/patient_main_screen.dart';

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
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showError("Please fill all fields");
      return;
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
        showError("User data not found");
        return;
      }

      String role = doc['role'] ?? "referral";

      if (role.toLowerCase() != selectedRole.toLowerCase()) {
        showError("Wrong role selected");
        return;
      }

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
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xffF3F4F6),

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(Icons.arrow_back),
                  Row(
                    children: [
                      Icon(Icons.language, size: 18),
                      SizedBox(width: 5),
                      Text("AR"),
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

              const Text(
                "AI Recovery",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 5),

              const Text(
                "Professional Recovery Management",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              const Text(
                "SELECT YOUR ROLE",
                style: TextStyle(fontSize: 12, color: Colors.grey),
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
                decoration: InputDecoration(
                  hintText: "Enter your Username",
                  prefixIcon: const Icon(Icons.alternate_email),
                  filled: true,
                  fillColor: Colors.grey.shade200,
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
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
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
                  child: const Text("Login to Account →"),
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

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = title;
        });
      },
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isSelected ? Colors.blue : Colors.grey),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}