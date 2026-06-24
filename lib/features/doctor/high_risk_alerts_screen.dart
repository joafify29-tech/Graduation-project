import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'high_risk_patient_detail_screen.dart';

class HighRiskAlertsScreen extends StatelessWidget {
  final bool isDarkMode;

  const HighRiskAlertsScreen({super.key, this.isDarkMode = false});

  @override
  Widget build(BuildContext context) {
    final bg = isDarkMode ? const Color(0xff121212) : const Color(0xffF7F8FA);
    final cardBg = isDarkMode ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtextColor = isDarkMode ? Colors.grey[400]! : Colors.grey;

    final currentDoctorUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('referrals')
              .where('doctorId', isEqualTo: currentDoctorUid)
              .snapshots(),
          builder: (context, referralsSnapshot) {
            if (!referralsSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final referralDocs = referralsSnapshot.data!.docs;
            final assignedPatientIds = referralDocs.map((d) => d.id).toSet();

            return Column(
              children: [
                // 🔝 HEADER
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.arrow_back, color: textColor),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "High Risk Alerts",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            Text(
                              "Patients requiring immediate attention",
                              style: TextStyle(
                                color: subtextColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xffFEECEC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xffEF4444),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                // 🔥 HIGH RISK ALERTS LIST from risk_alerts collection
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('risk_alerts')
                        .where('riskLevel', isEqualTo: 'HIGH')
                        .where('status', isEqualTo: 'UNRESOLVED')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final allDocs = snapshot.data!.docs;
                      final docs = allDocs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final patientId = data['patientId'] ?? '';
                        return assignedPatientIds.contains(patientId);
                      }).toList();

                      if (docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 64,
                                color: const Color(0xff34A853).withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No Risk Alerts Detected",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "All patients are currently stable",
                                style: TextStyle(color: subtextColor),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final alertDoc = docs[index];
                      final alertMap = alertDoc.data() as Map<String, dynamic>;
                      final patientId = alertMap['patientId'] ?? '';

                      // Fetch patient info from referrals using patientId
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('referrals')
                            .doc(patientId)
                            .get(),
                        builder: (context, patientSnapshot) {
                          String patientName = "Patient";
                          String patientAge = "";
                          String addiction = "";

                          if (patientSnapshot.hasData &&
                              patientSnapshot.data!.exists) {
                            final patientData = patientSnapshot.data!.data()
                                as Map<String, dynamic>;
                            patientName = patientData['name'] ?? "Patient";
                            patientAge = (patientData['age'] ?? "").toString();
                            addiction = patientData['addiction'] ?? "";
                          }

                          return _highRiskAlertCard(
                            context,
                            alertDoc,
                            alertMap,
                            patientName,
                            patientAge,
                            addiction,
                            cardBg,
                            textColor,
                            subtextColor,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    ),
  ),
);
}

  Widget _highRiskAlertCard(
    BuildContext context,
    dynamic alertDoc,
    Map<String, dynamic> alertMap,
    String patientName,
    String patientAge,
    String addiction,
    Color cardBg,
    Color textColor,
    Color subtextColor,
  ) {
    final alertType = alertMap['alertType'] ?? "Risk Alert";
    final description = alertMap['description'] ??
        "Elevated risk indicators detected.";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HighRiskPatientDetailScreen(
              alertData: alertDoc,
              patientId: alertMap['patientId'] ?? '',
              isDarkMode: isDarkMode,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xffEF4444).withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xffEF4444).withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient info row
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xffFEECEC),
                  child: Text(
                    patientName.isNotEmpty
                        ? patientName[0].toUpperCase()
                        : "?",
                    style: const TextStyle(
                      color: Color(0xffEF4444),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        patientAge.isNotEmpty
                            ? "Age: $patientAge • $addiction"
                            : alertType,
                        style: TextStyle(
                          color: subtextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffFEECEC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        color: Color(0xffEF4444),
                        size: 12,
                      ),
                      SizedBox(width: 3),
                      Text(
                        "HIGH RISK",
                        style: TextStyle(
                          color: Color(0xffEF4444),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Divider
            Divider(
              color: subtextColor.withValues(alpha: 0.2),
              height: 1,
            ),

            const SizedBox(height: 12),

            // Alert description from risk_alerts
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.psychology,
                  color: const Color(0xffEF4444).withValues(alpha: 0.7),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: subtextColor,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Tap to view
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Tap to review details",
                  style: TextStyle(
                    color: const Color(0xff2F6FED),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 11,
                  color: Color(0xff2F6FED),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
