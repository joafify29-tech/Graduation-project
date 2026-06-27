import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'patient_created_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../core/auth_credentials.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final notesController = TextEditingController();

  String selectedGender = "Male";
  String? addictionType;
  List<Map<String, dynamic>> _doctors = [];
  String? selectedDoctorId;
  String? selectedDoctorName;

  final List<String> addictions = [
    "Hashish",
    "Alcohol",
    "Tramadol",
    "Ice",
    "Cocaine",
  ];

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .get();
      setState(() {
        _doctors = snapshot.docs.map((doc) => {
          'id': doc.id,
          'name': doc.data()['name'] ?? 'Unknown Doctor',
        }).toList();
      });
    } catch (e) {
      showError("Error fetching doctors: $e");
    }
  }

  String generatePassword() {
    const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    Random rand = Random();
    return List.generate(10, (index) {
      return chars[rand.nextInt(chars.length)];
    }).join();
  }

  Future<String> generateEmail(String name) async {
    String base = name.toLowerCase().replaceAll(" ", "");
    String email = "$base@app.com";
    int counter = 1;

    while (true) {
      var query = await FirebaseFirestore.instance
          .collection('referrals')
          .where('email', isEqualTo: email)
          .get();

      if (query.docs.isEmpty) {
        return email;
      } else {
        email = "$base$counter@app.com";
        counter++;
      }
    }
  }

  Future<void> addPatient() async {
    final String? referralId = FirebaseAuth.instance.currentUser?.uid;
    String name = nameController.text.trim();
    String age = ageController.text.trim();
    String notes = notesController.text.trim();

    if (name.isEmpty || age.isEmpty || addictionType == null || selectedDoctorId == null) {
      showError("Please fill all required fields, including assigning a doctor");
      return;
    }

    try {
      String email = await generateEmail(name);
      String password = generatePassword();

      final secondaryApp = await Firebase.initializeApp(
        name: 'patientCreator',
        options: Firebase.app().options,
      );

      final secondaryAuth = FirebaseAuth.instanceFor(
        app: secondaryApp,
      );

      UserCredential userCredential =
          await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance
          .collection('referrals')
          .doc(uid)
          .set({
        "patientId": uid,
        "name": name,
        "age": age,
        "gender": selectedGender,
        "addiction": addictionType,
        "notes": notes,
        "status": "ACTIVE",
        "email": email,
        "tempPassword": password,
        "role": "patient",
        "doctorId": selectedDoctorId,
        "doctorName": selectedDoctorName,
        "referralId": referralId,
        "createdAt": Timestamp.now(),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({
        "name": name,
        "email": email,
        "role": "patient",
        "doctorId": selectedDoctorId,
        "doctorName": selectedDoctorName,
        "referralId": referralId,
        "createdAt": Timestamp.now(),
      });

      await secondaryAuth.signOut();
      await secondaryApp.delete();

      // Restore referral user session to default FirebaseAuth instance only if signed out
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null || currentUser.email != AuthCredentials.email) {
        if (AuthCredentials.email != null && AuthCredentials.password != null) {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: AuthCredentials.email!,
            password: AuthCredentials.password!,
          );
        }
      }

      if (!mounted) return;

      nameController.clear();
      ageController.clear();
      notesController.clear();
      setState(() {
        selectedGender = "Male";
        addictionType = null;
        selectedDoctorId = null;
        selectedDoctorName = null;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PatientCreatedScreen(
            email: email,
            password: password,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      showError(e.message ?? "Error creating user");
    } catch (e) {
      showError(e.toString());
    }
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget buildField(BuildContext context, String hint, TextEditingController controller,
      {int maxLines = 1}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputBg = isDark ? const Color(0xff2A2A2A) : const Color(0xffF0F2F5);
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final subtextColor = isDark ? Colors.grey[400]! : const Color(0xff64748B);

    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: subtextColor),
        filled: true,
        fillColor: inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xff121212) : const Color(0xffF7F8FA);
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final subtextColor = isDark ? Colors.grey[400]! : const Color(0xff64748B);
    final inputBg = isDark ? const Color(0xff2A2A2A) : const Color(0xffF0F2F5);
    final containerBg = isDark ? const Color(0xff222222) : const Color(0xffEDEFF2);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: [
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: textColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Row(
                    children: [
                      Icon(Icons.language, size: 18, color: textColor),
                      const SizedBox(width: 5),
                      Text("AR", style: TextStyle(color: textColor)),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 20),

              Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: isDark ? const Color(0xff1A2A4A) : const Color(0xffE3EDFF),
                    child: const Icon(Icons.health_and_safety,
                        color: Color(0xff2F6FED)),
                  ),
                  const SizedBox(height: 10),
                  const Text("AI RECOVERY",
                      style: TextStyle(color: Color(0xff2F6FED))),
                  const SizedBox(height: 10),
                  Text(
                    "Add New Patient",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Enter patient details to begin recovery tracking",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: subtextColor),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Text("Full Name", style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
              const SizedBox(height: 5),
              buildField(context, "e.g. Jonathan Doe", nameController),

              const SizedBox(height: 15),

              Text("Age", style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
              const SizedBox(height: 5),
              buildField(context, "Enter patient age", ageController),

              const SizedBox(height: 15),

              Text("Gender", style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
              const SizedBox(height: 5),

              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: containerBg,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    genderButton(context, "Male"),
                    genderButton(context, "Female"),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              Text("Addiction Type", style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
              const SizedBox(height: 5),

              DropdownButtonFormField<String>(
                value: addictionType,
                dropdownColor: cardBg,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: "Select addiction type",
                  hintStyle: TextStyle(color: subtextColor),
                  filled: true,
                  fillColor: inputBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: addictions
                    .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: textColor))))
                    .toList(),
                onChanged: (val) => setState(() => addictionType = val),
              ),

              const SizedBox(height: 15),

              Text("Assign Doctor", style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
              const SizedBox(height: 5),

              DropdownButtonFormField<String>(
                value: selectedDoctorId,
                dropdownColor: cardBg,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: _doctors.isEmpty ? "No doctors available" : "Select doctor",
                  hintStyle: TextStyle(color: subtextColor),
                  filled: true,
                  fillColor: inputBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _doctors
                    .map((doc) => DropdownMenuItem<String>(
                          value: doc['id'] as String,
                          child: Text(doc['name'] as String, style: TextStyle(color: textColor)),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedDoctorId = val;
                    selectedDoctorName = _doctors.firstWhere((doc) => doc['id'] == val)['name'];
                  });
                },
              ),

              const SizedBox(height: 15),

              Text("Initial Notes (Optional)", style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
              const SizedBox(height: 5),

              buildField(
                context,
                "Enter any preliminary observations or medical history...",
                notesController,
                maxLines: 4,
              ),

              const SizedBox(height: 30),

              SizedBox(
                height: 55,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff2F6FED),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextButton(
                    onPressed: addPatient,
                    child: const Text(
                      "Create Patient Account",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget genderButton(BuildContext context, String gender) {
    final isSelected = selectedGender == gender;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedGender = gender),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? cardBg : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            gender,
            style: TextStyle(
              color: isSelected ? const Color(0xff2F6FED) : (isDark ? Colors.grey[400]! : Colors.grey),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}