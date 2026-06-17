import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddMedicationScreen extends StatefulWidget {
  final String patientId;

  const AddMedicationScreen({super.key, required this.patientId});

  @override
  State<AddMedicationScreen> createState() =>
      _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {

  final nameController = TextEditingController();
  final dosageController = TextEditingController();
  final frequencyController = TextEditingController();
  final durationController = TextEditingController();
  final instructionsController = TextEditingController();

  String selectedType = "Tablet";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            // 🔝 HEADER
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 10),
                const Text("Add Medication",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 20),

            // 🔵 NAME
            inputField("Medication Name", nameController),

            const SizedBox(height: 15),

            // 🔵 TYPE
            const Text("Type", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),

            Row(
              children: [
                typeChip("Tablet"),
                typeChip("Capsule"),
                typeChip("Injection"),
              ],
            ),

            const SizedBox(height: 15),

            // 🔵 DOSAGE
            inputField("Dosage (e.g. 50mg)", dosageController),

            const SizedBox(height: 15),

            // 🔵 FREQUENCY
            inputField("Frequency (e.g. once daily)", frequencyController),

            const SizedBox(height: 15),

            // 🔵 DURATION
            inputField("Duration (e.g. 7 days)", durationController),

            const SizedBox(height: 15),

            // 🔵 INSTRUCTIONS
            inputField("Instructions", instructionsController, maxLines: 3),

            const SizedBox(height: 30),

            // 🔥 SAVE BUTTON
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
                onPressed: saveMedication,
                child: const Text("Save Medication"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔵 INPUT
  Widget inputField(String hint, TextEditingController controller,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // 🔵 TYPE CHIP
  Widget typeChip(String text) {
    final isSelected = selectedType == text;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedType = text;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff2F6FED) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  // 🔥 SAVE TO FIREBASE
  Future<void> saveMedication() async {

    if (nameController.text.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('referrals')
        .doc(widget.patientId)
        .collection('medications')
        .add({
      "name": nameController.text,
      "type": selectedType,
      "dosage": dosageController.text,
      "frequency": frequencyController.text,
      "duration": durationController.text,
      "instructions": instructionsController.text,
      "isActive": true,
      "createdAt": Timestamp.now(),
    });

    showSuccess();
  }

  // 🔥 SUCCESS
  void showSuccess() {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Icon(Icons.check_circle,
                    color: Colors.green, size: 50),

                const SizedBox(height: 10),

                const Text("Medication Added",
                    style: TextStyle(fontWeight: FontWeight.bold)),

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text("Done"),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}