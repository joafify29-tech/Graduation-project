import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';
import 'patient_report_screen.dart';
import 'reminders_screen.dart';

/// Reusable screen to select a patient from referrals.
/// [mode] = 'report' → opens full AI report for that patient
/// [mode] = 'chat'   → opens doctor-patient chat
/// [mode] = 'reminder' → opens reminders screen
class PatientSelectScreen extends StatelessWidget {
  final String mode; // 'report' or 'chat'

  const PatientSelectScreen({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    final isReport = mode == 'report';

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // 🔝 HEADER
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xffF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: Color(0xff0F172A), size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isReport ? "Export Report" : (mode == 'reminder' ? "Add Reminder" : "Urgent Contact"),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isReport
                              ? "Select a patient to view their AI report"
                              : (mode == 'reminder' ? "Select a patient to add a reminder" : "Select a patient to message"),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xff94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 🔥 PATIENT LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('referrals')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text("No patients found",
                          style: TextStyle(color: Color(0xff94A3B8))),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final map = doc.data() as Map<String, dynamic>;
                      return _patientTile(context, doc, map, isReport);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _patientTile(
    BuildContext context,
    dynamic doc,
    Map<String, dynamic> map,
    bool isReport,
  ) {
    final name = map['name'] ?? "Patient";
    final age = map['age'] ?? "";
    final addiction = map['addiction'] ?? "";
    final status = map['status'] ?? "LOW";
    final isHigh = status == "HIGH";

    return GestureDetector(
      onTap: () {
        if (isReport) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PatientReportScreen(data: doc),
            ),
          );
        } else if (mode == 'reminder') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RemindersScreen(data: doc),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(data: doc, role: "doctor"),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHigh
                ? const Color(0xffFEE2E2)
                : const Color(0xffF1F5F9),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor:
                  isHigh ? const Color(0xffFEECEC) : const Color(0xffE8F0FE),
              child: Text(
                name.toString().isNotEmpty ? name[0].toUpperCase() : "?",
                style: TextStyle(
                  color: isHigh
                      ? const Color(0xffEF4444)
                      : const Color(0xff2B82F6),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isHigh
                          ? const Color(0xffEF4444)
                          : const Color(0xff0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "Age: $age • $addiction",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xff94A3B8),
                    ),
                  ),
                ],
              ),
            ),

            // Risk badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isHigh
                    ? const Color(0xffFEECEC)
                    : const Color(0xffE6F4EA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isHigh ? "HIGH" : "LOW",
                style: TextStyle(
                  color: isHigh
                      ? const Color(0xffEF4444)
                      : const Color(0xff34A853),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: Color(0xff94A3B8)),
          ],
        ),
      ),
    );
  }
}
