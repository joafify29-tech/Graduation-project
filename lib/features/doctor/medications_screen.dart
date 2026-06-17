import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_medication_screen.dart';
import 'add_medication_screen.dart'; // 🔥 جديد

class MedicationsScreen extends StatelessWidget {
  final dynamic data;

  const MedicationsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final map = data.data();
    final name = map['name'] ?? "";

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
                const Text("Medications",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 20),

            // 🔥 PATIENT CARD
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const CircleAvatar(radius: 25),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                      const Text(
                        "Active Prescriptions",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text("ACTIVE PRESCRIPTIONS",
                style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 10),

            // 🔥 FIREBASE LIST
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('referrals')
                  .doc(data.id)
                  .collection('medications')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final meds = snapshot.data!.docs;

                if (meds.isEmpty) {
                  return const Text("No medications found");
                }

                return Column(
                  children: meds.map((doc) {
                    final med = doc.data() as Map<String, dynamic>;
                    return medicationItem(context, med, doc.id);
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 15),

            // 🔥 ADD MEDICATION BUTTON
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddMedicationScreen(
                      patientId: data.id,
                    ),
                  ),
                );
              },
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xff2F6FED)),
                ),
                child: const Center(
                  child: Text(
                    "+ Add Medication",
                    style: TextStyle(color: Color(0xff2F6FED)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget medicationItem(BuildContext context, Map<String, dynamic> med, String docId) {
    final isActive = med['isActive'] ?? true;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditMedicationScreen(
              patientId: data.id,
              docId: docId,
              data: med,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [

            const Icon(Icons.medication, color: Color(0xff2F6FED)),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(med['name'] ?? "",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    "${med['dosage']} • ${med['frequency']}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            Switch(
              value: isActive,
              onChanged: (val) {
                FirebaseFirestore.instance
                    .collection('referrals')
                    .doc(data.id)
                    .collection('medications')
                    .doc(docId)
                    .update({"isActive": val});
              },
            ),
          ],
        ),
      ),
    );
  }
}