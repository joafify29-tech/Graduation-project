import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RemindersScreen extends StatefulWidget {
  final dynamic data;

  const RemindersScreen({super.key, required this.data});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {

  final titleController = TextEditingController();
  String selectedTime = "09:00 AM";
  String frequency = "Daily";
  bool isHigh = false;

  @override
  Widget build(BuildContext context) {
    final map = widget.data.data();
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
                const Text("Reminders",
                    style: TextStyle(fontWeight: FontWeight.bold)),
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
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Text("Active Reminders",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text("ACTIVE REMINDERS",
                style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 10),

            // 🔥 LIST
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('referrals')
                  .doc(widget.data.id)
                  .collection('reminders')
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Text("No reminders yet");
                }

                return Column(
                  children: docs.map((doc) {
                    final r = doc.data() as Map<String, dynamic>;

                    return reminderItem(r, doc.id);
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 20),

            const Text("CREATE REMINDER",
                style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 10),

            // 🔥 FORM
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [

                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: "Reminder Title",
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [

                      Expanded(
                        child: GestureDetector(
                          onTap: pickTime,
                          child: box(selectedTime),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: DropdownButtonFormField(
                          value: frequency,
                          items: ["Daily", "Weekly", "Monthly"]
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setState(() => frequency = val.toString());
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Text("High Priority"),
                      const Spacer(),
                      Switch(
                        value: isHigh,
                        onChanged: (v) {
                          setState(() => isHigh = v);
                        },
                      )
                    ],
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: saveReminder,
                      child: const Text("Set Reminder"),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget reminderItem(Map<String, dynamic> r, String id) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [

          const Icon(Icons.notifications, color: Colors.orange),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r['title'] ?? "",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("${r['frequency']} • ${r['time']}"),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('referrals')
                  .doc(widget.data.id)
                  .collection('reminders')
                  .doc(id)
                  .delete();
            },
            icon: const Icon(Icons.delete),
          )
        ],
      ),
    );
  }

  Widget box(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(),
      ),
      child: Text(text),
    );
  }

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked.format(context);
      });
    }
  }

  Future<void> saveReminder() async {
     if (titleController.text.trim().isEmpty) {
    return;
  }
    await FirebaseFirestore.instance
    .collection('referrals')
    .doc(widget.data.id)
    .collection('reminders')
    .add({
  "title": titleController.text.trim(),
  "time": selectedTime,
  "frequency": frequency,
  "high": isHigh,

  // 🔥 مهم للـ Calendar Screen
  "completedDates": <String>[],

  "createdAt": Timestamp.now(),
});

    showSuccess();
  }

  void showSuccess() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Success"),
          content: const Text("Reminder Set Successfully"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            )
          ],
        );
      },
    );
  }
}