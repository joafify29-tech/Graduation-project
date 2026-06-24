import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_patient_screen.dart';
import 'upload_report_screen.dart';

class ReferralDetailsScreen extends StatelessWidget {
  final dynamic data;
  final String docId;

  const ReferralDetailsScreen({
    super.key,
    required this.data,
    required this.docId,
  });

  @override
  Widget build(BuildContext context) {
    String name = data['name'] ?? "";
    String age = data['age'].toString();
    String gender = data['gender'] ?? "";
    String type = data['addiction'] ?? "";
    String status = data['status'] ?? "ACTIVE";
    String notes = data['notes'] ?? "";

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xff121212) : const Color(0xffF7F8FA);
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final cardBg = isDark ? const Color(0xff1E1E1E) : const Color(0xffF0F2F5);
    final statusContainerBg = isDark ? const Color(0xff2A2A2A) : const Color(0xffEDEFF2);

    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              name,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: status == "ACTIVE"
                    ? (isDark ? const Color(0x1f34a853) : const Color(0xffE6F4EA))
                    : (isDark ? const Color(0x1fF59E0B) : const Color(0xffFFF4E5)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: status == "ACTIVE"
                      ? (isDark ? const Color(0xff81c784) : const Color(0xff34A853))
                      : (isDark ? const Color(0xffFFB74D) : const Color(0xffF59E0B)),
                  fontSize: 11,
                ),
              ),
            )
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: textColor),
            onPressed: () {},
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔥 INFO CARD
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      infoItem(context, "AGE", age),
                      infoItem(context, "GENDER", gender),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      infoItem(context, "ADDICTION", type),
                      infoItem(context, "DATE ADMITTED", "12/10/2023"),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: infoItem(context, "REF ID", "#AR-9021",
                        isBlue: true),
                  )
                ],
              ),
            ),

            const SizedBox(height: 25),

            sectionTitle(context, "INITIAL CLINICAL NOTES"),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                notes.isEmpty ? "No notes available" : notes,
                style: TextStyle(height: 1.5, color: textColor),
              ),
            ),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                sectionTitle(context, "MEDICAL REPORTS"),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UploadReportScreen(
                          patientName: name,
                          patientId: data['patientId'] ?? docId,
                          addiction: type,
                          docId: docId,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "+ Upload Report",
                    style: TextStyle(
                      color: Color(0xff2F6FED),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 10),

            reportItem(context, "Blood_Work_Analysis_v2.pdf", "2.4 MB"),
            const SizedBox(height: 10),
            reportItem(context, "Psych_Eval_initial.pdf", "1.8 MB"),

            const SizedBox(height: 25),

            sectionTitle(context, "CURRENT STATUS"),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: statusContainerBg,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  statusButton(context, "Active", status == "ACTIVE"),
                  statusButton(context, "Discharged", status == "DISCHARGED"),
                  statusButton(context, "Pending", status == "PENDING"),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🔥 BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff2F6FED),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditPatientScreen(
                            data: data,
                            docId: docId,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "Edit Patient",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: () => showDeleteDialog(context),
                    child: const Text("Delete"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: subtextColor,
      ),
    );
  }

  Widget infoItem(BuildContext context, String title, String value, {bool isBlue = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: subtextColor, fontSize: 11)),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isBlue ? const Color(0xff2F6FED) : textColor,
          ),
        ),
      ],
    );
  }

  Widget reportItem(BuildContext context, String name, String size) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xff1E1E1E) : const Color(0xffF0F2F5);
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: TextStyle(color: textColor),
            ),
          ),
          const Icon(Icons.download, color: Colors.blue),
        ],
      ),
    );
  }

  Widget statusButton(BuildContext context, String text, bool selected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedBg = isDark ? const Color(0xff3A3A3A) : Colors.white;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? selectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: selected ? const Color(0xff2F6FED) : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void showDeleteDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: dialogBg,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: Text(
            "Delete Patient?",
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "This action cannot be undone.",
            style: TextStyle(color: subtextColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: subtextColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final nav = Navigator.of(context);
                await FirebaseFirestore.instance
                    .collection('referrals')
                    .doc(docId)
                    .delete();

                nav.pop();
                nav.pop();
                nav.pop();
              },
              child: const Text("Delete"),
            )
          ],
        );
      },
    );
  }
}