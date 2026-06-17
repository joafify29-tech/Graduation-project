import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_medication_screen.dart';
import 'edit_medication_screen.dart'; // 🔥 جديد

class TreatmentPlanScreen extends StatefulWidget {
  final dynamic data;

  const TreatmentPlanScreen({super.key, required this.data});

  @override
  State<TreatmentPlanScreen> createState() =>
      _TreatmentPlanScreenState();
}

class _TreatmentPlanScreenState extends State<TreatmentPlanScreen> {
  final TextEditingController notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final map = widget.data.data();

    final name = map['name'] ?? "";
    final id = map['refId'] ?? "";

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
                const Text("Treatment Plan",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                const Text("History",
                    style: TextStyle(color: Color(0xff2F6FED)))
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
                      Row(
                        children: [
                          Text(name,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xffE6F4EA),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "ACTIVE",
                              style: TextStyle(
                                  color: Color(0xff34A853), fontSize: 10),
                            ),
                          )
                        ],
                      ),
                      Text("ID: $id • Age: 34",
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔵 NOTES
            const Text("TREATMENT NOTES",
                style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 10),

            TextField(
              controller: notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    "Enter patient assessment, clinical observations...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔵 MEDICATION LIST
            const Text("MEDICATION LIST",
                style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('referrals')
                  .doc(widget.data.id)
                  .collection('medications')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final meds = snapshot.data!.docs;

                if (meds.isEmpty) {
                  return const Text("No medications added yet");
                }

                return Column(
                  children: meds.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return medicationCard(data, doc.id);
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 10),

            // 🔥 ADD BUTTON
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddMedicationScreen(
                      patientId: widget.data.id,
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
                  child: Text("+ Add Medication",
                      style: TextStyle(color: Color(0xff2F6FED))),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔵 INFO
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xffE8F0FE),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                "Changes to the treatment plan will be logged and stored automatically.",
                style: TextStyle(fontSize: 12),
              ),
            ),

            const SizedBox(height: 20),

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
                onPressed: savePlan,
                child: const Text("Save Treatment Plan"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 MED CARD WITH EDIT + TOGGLE + DELETE
  Widget medicationCard(Map<String, dynamic> med, String docId) {
    final isActive = med['isActive'] ?? true;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditMedicationScreen(
              patientId: widget.data.id,
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

            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xff2F6FED)
                    : Colors.grey,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    med['name'] ?? "",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: isActive
                          ? null
                          : TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    "${med['dosage']} ${med['type']}",
                    style: TextStyle(
                      color: isActive ? Colors.blue : Colors.grey,
                    ),
                  ),
                  Text(
                    med['instructions'] ?? "",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            Column(
              children: [

                GestureDetector(
                  onTap: () => toggleMedication(docId, isActive),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xffE6F4EA)
                          : const Color(0xffFEECEC),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isActive ? "Active" : "Stopped",
                      style: TextStyle(
                        color: isActive
                            ? const Color(0xff34A853)
                            : const Color(0xffEF4444),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                GestureDetector(
                  onTap: () => deleteMedication(docId),
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> toggleMedication(String docId, bool currentState) async {
    await FirebaseFirestore.instance
        .collection('referrals')
        .doc(widget.data.id)
        .collection('medications')
        .doc(docId)
        .update({
      "isActive": !currentState,
    });
  }

  Future<void> deleteMedication(String docId) async {
    await FirebaseFirestore.instance
        .collection('referrals')
        .doc(widget.data.id)
        .collection('medications')
        .doc(docId)
        .delete();
  }

  Future<void> savePlan() async {
    final uid = widget.data.id;

    await FirebaseFirestore.instance
        .collection('referrals')
        .doc(uid)
        .collection('treatment_plan')
        .add({
      "notes": notesController.text,
      "updatedAt": Timestamp.now(),
    });

    showSuccessDialog();
  }

  void showSuccessDialog() {
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
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.green,
                  child: Icon(Icons.check, color: Colors.white),
                ),
                const SizedBox(height: 15),
                const Text("Plan Saved Successfully",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                const Text(
                  "Treatment plan has been updated.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text("Back to Dashboard"),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}