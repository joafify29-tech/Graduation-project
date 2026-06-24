import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadReportScreen extends StatefulWidget {
  final String patientName;
  final String patientId;
  final String addiction;
  final String docId;

  const UploadReportScreen({
    super.key,
    required this.patientName,
    required this.patientId,
    required this.addiction,
    required this.docId,
  });

  @override
  State<UploadReportScreen> createState() => _UploadReportScreenState();
}

class _UploadReportScreenState extends State<UploadReportScreen> {
  PlatformFile? selectedFile;
  double uploadProgress = 0;

  TextEditingController titleController = TextEditingController();
  TextEditingController notesController = TextEditingController();

  String category = "Select Category";

  final List<String> categories = [
    "Select Category",
    "Lab Report",
    "Psych Evaluation",
    "Medical History"
  ];

  // 📁 Pick File
  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        selectedFile = result.files.first;
      });
    }
  }

  // 🔥 Upload File
  Future<void> uploadFile() async {
    if (selectedFile == null) return;

    final ref = FirebaseStorage.instance
        .ref('reports/${selectedFile!.name}');

    final uploadTask = ref.putData(selectedFile!.bytes!);

    uploadTask.snapshotEvents.listen((event) {
      setState(() {
        uploadProgress =
            event.bytesTransferred / event.totalBytes;
      });
    });

    final snapshot = await uploadTask;

    final url = await snapshot.ref.getDownloadURL();

    // 🔥 Save in Firestore
    await FirebaseFirestore.instance
        .collection('referrals')
        .doc(widget.docId)
        .collection('reports')
        .add({
      'title': titleController.text,
      'category': category,
      'notes': notesController.text,
      'fileUrl': url,
      'fileName': selectedFile!.name,
      'createdAt': Timestamp.now(),
    });

    showSuccessDialog();
  }

  // ✅ Success Dialog
  void showSuccessDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: isDark ? const Color(0x1a34a853) : Colors.green.shade100,
                  child: const Icon(Icons.check,
                      color: Colors.green, size: 30),
                ),
                const SizedBox(height: 20),
                Text(
                  "Upload Successful",
                  style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 10),
                Text(
                  "Report uploaded successfully.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: subtextColor),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2F6FED),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xff121212) : const Color(0xffF3F4F6);
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.grey.shade200;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final subtextColor = isDark ? Colors.grey[400]! : const Color(0xff64748B);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(
          "Upload Medical Report",
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [

            // 👤 Patient Card
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isDark ? const Color(0xff2A2A2A) : const Color(0xffEDEFF2),
                    child: Icon(Icons.person, color: isDark ? Colors.white54 : Colors.black54),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.patientName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                        ),
                      ),
                      Text(
                        "Ref ID: ${widget.patientId}",
                        style: TextStyle(color: subtextColor),
                      ),
                      Text(
                        "Addiction: ${widget.addiction}",
                        style: TextStyle(color: subtextColor),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📁 Upload Box
            GestureDetector(
              onTap: pickFile,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.blue, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: selectedFile == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload, color: textColor),
                            const SizedBox(height: 10),
                            Text("Select File", style: TextStyle(color: textColor)),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(selectedFile!.name, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: LinearProgressIndicator(value: uploadProgress),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Title
            TextField(
              controller: titleController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: "Report Title",
                labelStyle: TextStyle(color: subtextColor),
                filled: true,
                fillColor: isDark ? const Color(0xff2A2A2A) : const Color(0xffF0F2F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),

            const SizedBox(height: 15),

            // Category
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xff2A2A2A) : const Color(0xffF0F2F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: category,
                  dropdownColor: isDark ? const Color(0xff1E1E1E) : Colors.white,
                  style: TextStyle(color: textColor, fontSize: 16),
                  icon: Icon(Icons.arrow_drop_down, color: subtextColor),
                  isExpanded: true,
                  items: categories
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e, style: TextStyle(color: textColor)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => category = v!),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Notes
            TextField(
              controller: notesController,
              maxLines: 3,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: "Notes",
                labelStyle: TextStyle(color: subtextColor),
                filled: true,
                fillColor: isDark ? const Color(0xff2A2A2A) : const Color(0xffF0F2F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2F6FED),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: uploadFile,
              child: const Text("Upload Report"),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: subtextColor, fontWeight: FontWeight.w600),
              ),
            )
          ],
        ),
      ),
    );
  }
}