import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'patient_created_screen.dart';
import 'package:firebase_core/firebase_core.dart';

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

  final List<String> addictions = [
    "Hashish",
    "Alcohol",
    "Tramadol",
    "Ice",
    "Cocaine",
  ];

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
    String name = nameController.text.trim();
    String age = ageController.text.trim();
    String notes = notesController.text.trim();

    if (name.isEmpty || age.isEmpty || addictionType == null) {
      showError("Please fill all required fields");
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
        "createdAt": Timestamp.now(),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({
        "name": name,
        "email": email,
        "role": "patient",
        "createdAt": Timestamp.now(),
      });

      await secondaryAuth.signOut();
      await secondaryApp.delete();

      if (!mounted) return;

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

  Widget buildField(String hint, TextEditingController controller,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xffF0F2F5),
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
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: [
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.arrow_back),
                  Row(
                    children: const [
                      Icon(Icons.language, size: 18),
                      SizedBox(width: 5),
                      Text("AR"),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 20),

              Column(
                children: const [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xffE3EDFF),
                    child: Icon(Icons.health_and_safety,
                        color: Color(0xff2F6FED)),
                  ),
                  SizedBox(height: 10),
                  Text("AI RECOVERY",
                      style: TextStyle(color: Color(0xff2F6FED))),
                  SizedBox(height: 10),
                  Text(
                    "Add New Patient",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Enter patient details to begin recovery tracking",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              const Text("Full Name"),
              const SizedBox(height: 5),
              buildField("e.g. Jonathan Doe", nameController),

              const SizedBox(height: 15),

              const Text("Age"),
              const SizedBox(height: 5),
              buildField("Enter patient age", ageController),

              const SizedBox(height: 15),

              const Text("Gender"),
              const SizedBox(height: 5),

              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xffEDEFF2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    genderButton("Male"),
                    genderButton("Female"),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              const Text("Addiction Type"),
              const SizedBox(height: 5),

              DropdownButtonFormField<String>(
                value: addictionType,
                decoration: InputDecoration(
                  hintText: "Select addiction type",
                  filled: true,
                  fillColor: const Color(0xffF0F2F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: addictions
                    .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => addictionType = val),
              ),

              const SizedBox(height: 15),

              const Text("Initial Notes (Optional)"),
              const SizedBox(height: 5),

              buildField(
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

  Widget genderButton(String gender) {
    final isSelected = selectedGender == gender;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedGender = gender),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            gender,
            style: TextStyle(
              color: isSelected ? const Color(0xff2F6FED) : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}