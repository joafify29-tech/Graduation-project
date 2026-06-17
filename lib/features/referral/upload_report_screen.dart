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
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.green.shade100,
                  child: const Icon(Icons.check,
                      color: Colors.green, size: 30),
                ),
                const SizedBox(height: 20),
                const Text("Upload Successful",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text(
                  "Report uploaded successfully.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
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
    return Scaffold(
      backgroundColor: const Color(0xffF3F4F6),
      appBar: AppBar(
        title: const Text("Upload Medical Report"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [

            // 👤 Patient Card
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const CircleAvatar(child: Icon(Icons.person)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.patientName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                      Text("Ref ID: ${widget.patientId}"),
                      Text("Addiction: ${widget.addiction}"),
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
                          children: const [
                            Icon(Icons.cloud_upload),
                            SizedBox(height: 10),
                            Text("Select File"),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(selectedFile!.name),
                            const SizedBox(height: 10),
                            LinearProgressIndicator(value: uploadProgress),
                          ],
                        ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Title
            TextField(
              controller: titleController,
              decoration:
                  const InputDecoration(labelText: "Report Title"),
            ),

            const SizedBox(height: 15),

            // Category
            DropdownButton<String>(
              value: category,
              isExpanded: true,
              items: categories
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => category = v!),
            ),

            const SizedBox(height: 15),

            // Notes
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Notes"),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: uploadFile,
              child: const Text("Upload Report"),
            ),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            )
          ],
        ),
      ),
    );
  }
}