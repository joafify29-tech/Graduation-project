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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xff121212) : const Color(0xffF7F8FA);
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return Scaffold(
      backgroundColor: bg,

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            // 🔝 HEADER
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back, color: textColor),
                ),
                const SizedBox(width: 10),
                Text("Treatment Plan",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
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
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: isDark ? const Color(0xff2A2A2A) : const Color(0xffE8E8E8),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : "?",
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(name,
                              style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
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
                          style: TextStyle(color: subtextColor)),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔵 NOTES
            Text("TREATMENT NOTES",
                style: TextStyle(color: subtextColor)),

            const SizedBox(height: 10),

            TextField(
              controller: notesController,
              maxLines: 4,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText:
                    "Enter patient assessment, clinical observations...",
                hintStyle: TextStyle(color: subtextColor),
                filled: true,
                fillColor: cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔵 MEDICATION LIST
            Text("MEDICATION LIST",
                style: TextStyle(color: subtextColor)),

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
                  return Text("No medications added yet",
                      style: TextStyle(color: subtextColor));
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
                color: isDark ? const Color(0xff1E293B) : const Color(0xffE8F0FE),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                "Changes to the treatment plan will be logged and stored automatically.",
                style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[300]! : Colors.black87),
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
                  foregroundColor: Colors.white,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

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
          color: cardBg,
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
                    : subtextColor,
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
                      color: textColor,
                      decoration: isActive
                          ? null
                          : TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    "${med['dosage']} ${med['type']}",
                    style: TextStyle(
                      color: isActive ? Colors.blue : subtextColor,
                    ),
                  ),
                  Text(
                    med['instructions'] ?? "",
                    style: TextStyle(fontSize: 12, color: textColor),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: dialogBg,
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
                Text("Plan Saved Successfully",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                const SizedBox(height: 10),
                Text(
                  "Treatment plan has been updated.",
                  style: TextStyle(color: textColor),
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