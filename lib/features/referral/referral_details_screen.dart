import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_patient_screen.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: Column(
          children: [
            Text(
              name,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: status == "ACTIVE"
                    ? const Color(0xffE6F4EA)
                    : const Color(0xffFFF4E5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: status == "ACTIVE"
                      ? const Color(0xff34A853)
                      : const Color(0xffF59E0B),
                  fontSize: 11,
                ),
              ),
            )
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
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
                color: const Color(0xffF0F2F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      infoItem("AGE", age),
                      infoItem("GENDER", gender),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      infoItem("ADDICTION", type),
                      infoItem("DATE ADMITTED", "12/10/2023"),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: infoItem("REF ID", "#AR-9021",
                        isBlue: true),
                  )
                ],
              ),
            ),

            const SizedBox(height: 25),

            sectionTitle("INITIAL CLINICAL NOTES"),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xffF0F2F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                notes.isEmpty ? "No notes available" : notes,
                style: const TextStyle(height: 1.5),
              ),
            ),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                sectionTitle("MEDICAL REPORTS"),
                const Text(
                  "+ Upload Report",
                  style: TextStyle(
                    color: Color(0xff2F6FED),
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),

            const SizedBox(height: 10),

            reportItem("Blood_Work_Analysis_v2.pdf", "2.4 MB"),
            const SizedBox(height: 10),
            reportItem("Psych_Eval_initial.pdf", "1.8 MB"),

            const SizedBox(height: 25),

            sectionTitle("CURRENT STATUS"),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xffEDEFF2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  statusButton("Active", status == "ACTIVE"),
                  statusButton("Discharged", status == "DISCHARGED"),
                  statusButton("Pending", status == "PENDING"),
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
                        color: Colors.white, // 🔥 FIX
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

  Widget sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: Colors.grey,
      ),
    );
  }

  Widget infoItem(String title, String value, {bool isBlue = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isBlue ? const Color(0xff2F6FED) : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget reportItem(String name, String size) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffF0F2F5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(child: Text(name)),
          const Icon(Icons.download, color: Colors.blue),
        ],
      ),
    );
  }

  Widget statusButton(String text, bool selected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
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
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: const Text("Delete Patient?"),
          content: const Text("This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('referrals')
                    .doc(docId)
                    .delete();

                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            )
          ],
        );
      },
    );
  }
}