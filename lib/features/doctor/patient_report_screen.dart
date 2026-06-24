import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PatientReportScreen extends StatelessWidget {
  final dynamic data;

  const PatientReportScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final map = data.data() as Map<String, dynamic>;
    final name = map['name'] ?? "Patient";
    final age = map['age'] ?? "";
    final addiction = map['addiction'] ?? "";
    final mood = map['mood'] ?? "Stable";
    final status = map['status'] ?? "LOW";
    final patientId = data.id;

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
                  const Expanded(
                    child: Text(
                      "AI Report",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff0F172A),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔥 REPORT CONTENT
            Expanded(
              child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('ai_reports')
                    .doc(patientId)
                    .get(),
                builder: (context, reportSnapshot) {
                  int moodScore = 50;
                  String riskLevel = status;
                  List<dynamic> moodHistory = [];

                  if (reportSnapshot.hasData &&
                      reportSnapshot.data!.exists) {
                    final reportData = reportSnapshot.data!.data()
                        as Map<String, dynamic>;
                    moodScore = reportData['currentMoodScore'] ?? 50;
                    riskLevel = reportData['currentRiskLevel'] ?? status;
                    moodHistory = reportData['moodHistory'] ?? [];
                  }

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('risk_alerts')
                        .where('patientId', isEqualTo: patientId)
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, alertSnapshot) {
                      List<Map<String, dynamic>> alerts = [];
                      if (alertSnapshot.hasData) {
                        alerts = alertSnapshot.data!.docs
                            .map((d) =>
                                d.data() as Map<String, dynamic>)
                            .toList();
                      }

                      return ListView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20),
                        children: [
                          // Patient info card
                          _patientInfoCard(
                              name, age, addiction, mood, riskLevel),
                          const SizedBox(height: 20),

                          // Scores
                          _scoresSection(moodScore, riskLevel),
                          const SizedBox(height: 20),

                          // Mood history
                          _moodHistorySection(moodHistory),
                          const SizedBox(height: 20),

                          // Alerts
                          _alertsSection(alerts),
                          const SizedBox(height: 20),

                          // AI Summary
                          _aiSummaryCard(
                              name, moodScore, riskLevel, alerts),
                          const SizedBox(height: 25),

                          // Download PDF
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xff2B82F6),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(24),
                                ),
                                elevation: 4,
                                shadowColor: const Color(0xff2B82F6)
                                    .withValues(alpha: 0.4),
                              ),
                              onPressed: () => _downloadPdf(
                                context,
                                name,
                                age,
                                addiction,
                                mood,
                                moodScore,
                                riskLevel,
                                moodHistory,
                                alerts,
                              ),
                              icon: const Icon(Icons.download,
                                  color: Colors.white),
                              label: const Text(
                                "Download as PDF",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
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

  Widget _patientInfoCard(String name, dynamic age, String addiction,
      String mood, String riskLevel) {
    final isHigh = riskLevel == 'HIGH';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: isHigh
                ? const Color(0xffFEECEC)
                : const Color(0xffE8F0FE),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : "?",
              style: TextStyle(
                color: isHigh
                    ? const Color(0xffEF4444)
                    : const Color(0xff2B82F6),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xff0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Age: $age • $addiction • Mood: $mood",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xff94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isHigh
                  ? const Color(0xffFEECEC)
                  : const Color(0xffE6F4EA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isHigh ? "HIGH RISK" : "LOW RISK",
              style: TextStyle(
                color: isHigh
                    ? const Color(0xffEF4444)
                    : const Color(0xff34A853),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoresSection(int moodScore, String riskLevel) {
    final isHigh = riskLevel == 'HIGH';
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xffF1F5F9)),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 70,
                  height: 70,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: moodScore / 100.0,
                        strokeWidth: 8,
                        backgroundColor: const Color(0xffE2E8F0),
                        valueColor: const AlwaysStoppedAnimation(
                            Color(0xff2B82F6)),
                      ),
                      Text(
                        "$moodScore%",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xff0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "SENTIMENT SCORE",
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xff94A3B8),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.25,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isHigh
                  ? const Color(0xffFEF2F2).withValues(alpha: 0.5)
                  : const Color(0xffE6F4EA).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isHigh
                    ? const Color(0xffFEE2E2)
                    : const Color(0xffBBF7D0),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isHigh
                        ? const Color(0xffFEE2E2).withValues(alpha: 0.8)
                        : const Color(0xffBBF7D0).withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isHigh
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline,
                    color: isHigh
                        ? const Color(0xffEF4444)
                        : const Color(0xff34A853),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "$riskLevel Risk",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isHigh
                        ? const Color(0xffEF4444)
                        : const Color(0xff34A853),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isHigh ? "IMMEDIATE REVIEW" : "STABLE",
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                    color: isHigh
                        ? const Color(0xffF87171).withValues(alpha: 0.8)
                        : const Color(0xff34A853).withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _moodHistorySection(List<dynamic> moodHistory) {
    final values = moodHistory.isEmpty
        ? [50, 50, 50, 50, 50, 50, 50]
        : moodHistory.map((e) => (e as int)).toList();
    final maxH = 120.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Mood History",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xff0F172A),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "Recent mood scores from AI sessions",
            style: TextStyle(fontSize: 12, color: Color(0xff94A3B8)),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: maxH + 25,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(values.length, (i) {
                final val = values[i];
                final h = (val / 100.0) * maxH;
                final isLow = val < 40;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 12,
                      height: h.clamp(8.0, maxH),
                      decoration: BoxDecoration(
                        color: isLow
                            ? const Color(0xffEF4444)
                            : const Color(0xff2B82F6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "$val",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            isLow ? FontWeight.bold : FontWeight.w500,
                        color: isLow
                            ? const Color(0xffEF4444)
                            : const Color(0xff94A3B8),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _alertsSection(List<Map<String, dynamic>> alerts) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "AI-Generated Alerts",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xff0F172A),
                ),
              ),
              const SizedBox(width: 8),
              if (alerts.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xffDBEAFE),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "${alerts.length}",
                    style: const TextStyle(
                      color: Color(0xff2B82F6),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (alerts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text("No alerts found for this patient",
                  style: TextStyle(color: Color(0xff94A3B8))),
            )
          else
            ...alerts.map((a) => _alertCard(a)),
        ],
      ),
    );
  }

  Widget _alertCard(Map<String, dynamic> alert) {
    final type = alert['alertType'] ?? "Alert";
    final desc = alert['description'] ?? "";
    final risk = alert['riskLevel'] ?? "LOW";
    final isHigh = risk == 'HIGH';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isHigh
                  ? const Color(0xffFEF2F2)
                  : const Color(0xffEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isHigh
                  ? Icons.warning_amber_rounded
                  : Icons.info_outline,
              color: isHigh
                  ? const Color(0xffEF4444)
                  : const Color(0xff2B82F6),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xff0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xff64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiSummaryCard(String name, int moodScore,
      String riskLevel, List<Map<String, dynamic>> alerts) {
    final isHigh = riskLevel == 'HIGH';
    final alertDescriptions = alerts
        .map((a) => "• ${a['alertType']}: ${a['description']}")
        .join('\n');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isHigh
            ? const Color(0xffFEF2F2)
            : const Color(0xffEFF6FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology,
                  color: isHigh
                      ? const Color(0xffEF4444)
                      : const Color(0xff2B82F6),
                  size: 20),
              const SizedBox(width: 8),
              const Text(
                "AI Clinical Summary",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xff0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Patient $name has a current sentiment score of $moodScore% "
            "with a $riskLevel risk level. "
            "${isHigh ? 'Immediate clinical review is recommended. ' : 'Patient appears stable. '}"
            "${alerts.isNotEmpty ? 'The following alerts have been generated:\n$alertDescriptions' : 'No active alerts detected.'}",
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xff475569),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPdf(
    BuildContext context,
    String name,
    dynamic age,
    String addiction,
    String mood,
    int moodScore,
    String riskLevel,
    List<dynamic> moodHistory,
    List<Map<String, dynamic>> alerts,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context ctx) {
          return [
            // Title
            pw.Header(
              level: 0,
              child: pw.Text(
                "AI Clinical Report",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),

            // Patient Info
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: PdfColors.grey300,
                ),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Patient Information",
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 16)),
                  pw.SizedBox(height: 8),
                  pw.Text("Name: $name"),
                  pw.Text("Age: $age"),
                  pw.Text("Addiction Type: $addiction"),
                  pw.Text("Current Mood: $mood"),
                  pw.Text("Sentiment Score: $moodScore%"),
                  pw.Text("Risk Level: $riskLevel"),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Mood History
            if (moodHistory.isNotEmpty) ...[
              pw.Text("Mood History (Last ${moodHistory.length} Sessions)",
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 16)),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                headers: List.generate(
                    moodHistory.length, (i) => "S${i + 1}"),
                data: [
                  moodHistory.map((e) => "$e%").toList(),
                ],
              ),
              pw.SizedBox(height: 20),
            ],

            // Alerts
            pw.Text("AI-Generated Alerts (${alerts.length})",
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, fontSize: 16)),
            pw.SizedBox(height: 8),
            if (alerts.isEmpty)
              pw.Text("No alerts detected.",
                  style: const pw.TextStyle(color: PdfColors.grey))
            else
              ...alerts.map((a) => pw.Container(
                    margin:
                        const pw.EdgeInsets.only(bottom: 8),
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                          color: PdfColors.grey300),
                      borderRadius:
                          pw.BorderRadius.circular(6),
                    ),
                    child: pw.Column(
                      crossAxisAlignment:
                          pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "${a['alertType'] ?? 'Alert'} — ${a['riskLevel'] ?? 'N/A'}",
                          style: pw.TextStyle(
                              fontWeight:
                                  pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                            a['description'] ?? ""),
                      ],
                    ),
                  )),
            pw.SizedBox(height: 20),

            // Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("AI Clinical Summary",
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 14)),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    "Patient $name has a current sentiment score of $moodScore% "
                    "with a $riskLevel risk level. "
                    "${riskLevel == 'HIGH' ? 'Immediate clinical review is recommended.' : 'Patient appears stable.'} "
                    "${alerts.isNotEmpty ? '${alerts.length} alert(s) have been generated.' : 'No active alerts detected.'}",
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 30),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Text(
              "Generated by AI Recovery App • ${DateTime.now().toString().substring(0, 16)}",
              style: const pw.TextStyle(
                  fontSize: 9, color: PdfColors.grey),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: "AI_Report_${name.replaceAll(' ', '_')}.pdf",
    );
  }
}
