import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditMedicationScreen extends StatefulWidget {
  final String patientId;
  final String docId;
  final Map<String, dynamic> data;

  const EditMedicationScreen({
    super.key,
    required this.patientId,
    required this.docId,
    required this.data,
  });

  @override
  State<EditMedicationScreen> createState() =>
      _EditMedicationScreenState();
}

class _EditMedicationScreenState extends State<EditMedicationScreen> {

  late TextEditingController nameController;
  late TextEditingController dosageController;
  late TextEditingController frequencyController;
  late TextEditingController durationController;
  late TextEditingController instructionsController;

  String selectedType = "Tablet";

  @override
  void initState() {
    super.initState();

    final data = widget.data;

    nameController = TextEditingController(text: data['name']);
    dosageController = TextEditingController(text: data['dosage']);
    frequencyController = TextEditingController(text: data['frequency']);
    durationController = TextEditingController(text: data['duration']);
    instructionsController =
        TextEditingController(text: data['instructions']);

    selectedType = data['type'] ?? "Tablet";
  }

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
                const Text("Edit Medication",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 20),

            input("Medication Name", nameController),

            const SizedBox(height: 15),

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

            input("Dosage", dosageController),
            const SizedBox(height: 15),

            input("Frequency", frequencyController),
            const SizedBox(height: 15),

            input("Duration", durationController),
            const SizedBox(height: 15),

            input("Instructions", instructionsController, maxLines: 3),

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
                onPressed: updateMedication,
                child: const Text("Update Medication"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget input(String hint, TextEditingController controller,
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

  Widget typeChip(String text) {
    final selected = selectedType == text;

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
          color: selected ? const Color(0xff2F6FED) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  // 🔥 UPDATE
  Future<void> updateMedication() async {
    await FirebaseFirestore.instance
        .collection('referrals')
        .doc(widget.patientId)
        .collection('medications')
        .doc(widget.docId)
        .update({
      "name": nameController.text,
      "type": selectedType,
      "dosage": dosageController.text,
      "frequency": frequencyController.text,
      "duration": durationController.text,
      "instructions": instructionsController.text,
    });

    Navigator.pop(context);
  }
}