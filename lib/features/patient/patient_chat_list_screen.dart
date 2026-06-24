import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'patient_ai_chat_screen.dart';

class PatientChatListScreen extends StatefulWidget {
  const PatientChatListScreen({super.key});

  @override
  State<PatientChatListScreen> createState() => _PatientChatListScreenState();
}

class _PatientChatListScreenState extends State<PatientChatListScreen> {
  late String _patientId;

  @override
  void initState() {
    super.initState();
    _patientId = FirebaseAuth.instance.currentUser?.uid ?? 'test_patient_id';
  }

  void _startNewChat() {
    final newSessionRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(_patientId)
        .collection('sessions')
        .doc(); // Auto-generate an ID

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientAiChatScreen(sessionId: newSessionRef.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xff121212) : const Color(0xffF7F8FA);
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xff121212) : Colors.white,
        elevation: 0,
        title: Text(
          "My Chat Sessions",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .doc(_patientId)
            .collection('sessions')
            .orderBy('updatedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 60, color: subtextColor),
                  const SizedBox(height: 16),
                  Text(
                    "No chat sessions yet.",
                    style: TextStyle(color: subtextColor, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _startNewChat,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff2F6FED),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text("Start New Chat", style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            );
          }

          final sessions = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['deletedByPatient'] != true;
          }).toList();

          if (sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 60, color: subtextColor),
                  const SizedBox(height: 16),
                  Text(
                    "No chat sessions yet.",
                    style: TextStyle(color: subtextColor, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _startNewChat,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff2F6FED),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text("Start New Chat", style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final sessionData = sessions[index].data() as Map<String, dynamic>;
              final title = sessionData['title'] ?? "New Conversation";
              final timestamp = sessionData['updatedAt'] as Timestamp?;
              final timeString = timestamp != null
                  ? "${timestamp.toDate().month}/${timestamp.toDate().day} ${timestamp.toDate().hour}:${timestamp.toDate().minute.toString().padLeft(2, '0')}"
                  : "";

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PatientAiChatScreen(sessionId: sessions[index].id),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: isDark ? const Color(0xff1A2A4A) : const Color(0xffE8F0FE),
                        child: const Icon(Icons.smart_toy, color: Color(0xff2F6FED)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Last updated: $timeString",
                              style: TextStyle(color: subtextColor, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: cardBg,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: Text("Delete Chat?", style: TextStyle(color: textColor)),
                              content: Text("This will remove the chat from your list. Are you sure?", style: TextStyle(color: textColor)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await FirebaseFirestore.instance
                                        .collection('chats')
                                        .doc(_patientId)
                                        .collection('sessions')
                                        .doc(sessions[index].id)
                                        .update({'deletedByPatient': true});
                                  },
                                  child: const Text("Delete", style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Icon(Icons.arrow_forward_ios, color: subtextColor, size: 16),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startNewChat,
        backgroundColor: const Color(0xff2F6FED),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("New Chat", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
