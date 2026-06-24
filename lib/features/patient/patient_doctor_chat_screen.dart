import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientDoctorChatScreen extends StatefulWidget {
  const PatientDoctorChatScreen({super.key});

  @override
  State<PatientDoctorChatScreen> createState() =>
      _PatientDoctorChatScreenState();
}

class _PatientDoctorChatScreenState
    extends State<PatientDoctorChatScreen> {

  final TextEditingController
      messageController =
      TextEditingController();

  final ScrollController
      scrollController =
      ScrollController();

  final uid =
      FirebaseAuth.instance.currentUser!.uid;

  Map<String, dynamic>? replyingToMessage;

  String _doctorId = 'test_doctor_id';
  String _doctorName = 'Dr. test';

  TextDirection _getDirection(String text) {
    if (text.isEmpty) return TextDirection.ltr;
    for (int i = 0; i < text.length; i++) {
      final char = text.codeUnitAt(i);
      // If it contains any Arabic characters
      if (char >= 0x0600 && char <= 0x06FF) {
        return TextDirection.rtl;
      }
    }
    return TextDirection.ltr;
  }

  String _formatTimestamp(dynamic timestamp) {
    DateTime dt;
    if (timestamp is Timestamp) {
      dt = timestamp.toDate();
    } else if (timestamp is DateTime) {
      dt = timestamp;
    } else {
      // Fallback to local device time while pending server timestamp
      dt = DateTime.now();
    }
    
    // Convert to Egypt time (UTC + 3 hours)
    final egyptDt = dt.toUtc().add(const Duration(hours: 3));
    final hour = egyptDt.hour == 0
        ? 12
        : (egyptDt.hour > 12 ? egyptDt.hour - 12 : egyptDt.hour);
    final amPm = egyptDt.hour >= 12 ? 'PM' : 'AM';
    final min = egyptDt.minute.toString().padLeft(2, '0');
    return "$hour:$min $amPm";
  }

  void _clearChat() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xff1E1E1E) : Colors.white,
        title: Text("Clear Chat", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete all messages in this chat? This cannot be undone.", style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final messagesRef = FirebaseFirestore.instance
                    .collection('referrals')
                    .doc(uid)
                    .collection('messages_$_doctorId');
                final snapshots = await messagesRef.get();
                for (var doc in snapshots.docs) {
                  await doc.reference.delete();
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Chat cleared successfully"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error clearing chat: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text("Clear", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _deleteChatForMe() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xff1E1E1E) : Colors.white,
        title: Text("Delete Chat", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete this chat for yourself? This will clear your chat history, but the doctor will still see it.", style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await FirebaseFirestore.instance
                    .collection('referrals')
                    .doc(uid)
                    .update({
                  'chatDeletedAt': FieldValue.serverTimestamp(),
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Chat history deleted for you"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error deleting chat: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) {
      return;
    }

    final replyData = replyingToMessage;

    // Reset input immediately for responsive UI
    messageController.clear();
    setState(() {
      replyingToMessage = null;
    });

    await FirebaseFirestore.instance
        .collection('referrals')
        .doc(uid)
        .collection('messages_$_doctorId')
        .add({
      'text': text,
      'sender': 'patient',
      'seen': false,
      'createdAt': FieldValue.serverTimestamp(),
      if (replyData != null) ...{
        'replyToText': replyData['text'],
        'replyToSender': replyData['sender'],
      }
    });
  }

  void _showDeleteMessageDialog(DocumentReference ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xff1E1E1E) : Colors.white,
        title: Text("Delete Message", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete this message? This action cannot be undone.", style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.delete();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error deleting message: $e")),
                  );
                }
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSosBottomSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xff1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_rounded, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                "Emergency Assistance",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 8),
              Text(
                "Who would you like to contact?",
                style: TextStyle(color: subtextColor),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: isDark ? const Color(0xff1A2A4A) : const Color(0xffEEF4FF),
                  child: const Icon(Icons.phone, color: Color(0xff2F6FED)),
                ),
                title: Text("Call Last Number", style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  launchUrl(Uri.parse('tel:911')); // Mock fallback
                },
              ),
              const Divider(),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: isDark ? const Color(0xff3A2A1A) : const Color(0xffFFF2E5),
                  child: const Icon(Icons.family_restroom, color: Colors.orange),
                ),
                title: Text("Call Family", style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  launchUrl(Uri.parse('tel:1234567890'));
                },
              ),
              const Divider(),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: isDark ? const Color(0xff1A3B2B) : const Color(0xffE8F8EE),
                  child: const Icon(Icons.medical_services, color: Color(0xff34C759)),
                ),
                title: Text("Call Doctor", style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  launchUrl(Uri.parse('tel:0987654321'));
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xff121212) : const Color(0xffF7F8FA);
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('referrals')
          .doc(uid)
          .snapshots(),
      builder: (context, patientSnapshot) {
        if (!patientSnapshot.hasData) {
          return Scaffold(
            backgroundColor: bg,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final patientData = patientSnapshot.data!.data() as Map<String, dynamic>? ?? {};
        _doctorId = patientData['doctorId'] ?? 'test_doctor_id';
        _doctorName = patientData['doctorName'] ?? 'Dr. test';

        return Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            child: Column(
              children: [
                /// HEADER
                Container(
                  color: cardBg,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: textColor,
                        ),
                      ),
                      const CircleAvatar(
                        radius: 20,
                        child: Icon(Icons.person),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _doctorName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                            const Text(
                              "Online",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.delete_sweep, color: Colors.red),
                        tooltip: "Chat Options",
                        onSelected: (value) {
                          if (value == 'clear') {
                            _clearChat();
                          } else if (value == 'delete') {
                            _deleteChatForMe();
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'clear',
                            child: Text(
                              "Clear Chat (for everyone)",
                              style: TextStyle(color: isDark ? Colors.white : Colors.black),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              "Delete Chat (for me)",
                              style: TextStyle(color: isDark ? Colors.white : Colors.black),
                            ),
                          ),
                        ],
                        color: cardBg,
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: _showSosBottomSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "SOS",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(
                  height: 1,
                  color: isDark ? Colors.grey[800] : const Color(0xffE2E8F0),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('referrals')
                        .doc(uid)
                        .collection('messages_$_doctorId')
                        .orderBy(
                          'createdAt',
                          descending: true,
                        )
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final messages = snapshot.data!.docs;
                      final chatDeletedAt = patientData['chatDeletedAt'];
                      final filteredMessages = chatDeletedAt == null
                          ? messages
                          : messages.where((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final createdAt = data['createdAt'];
                              if (createdAt == null) return true; // Keep local/pending messages
                              if (createdAt is Timestamp && chatDeletedAt is Timestamp) {
                                return createdAt.compareTo(chatDeletedAt) > 0;
                              }
                              return true;
                            }).toList();

                      if (filteredMessages.isEmpty) {
                        return Center(
                          child: Text(
                            "No messages yet",
                            style: TextStyle(color: subtextColor),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: scrollController,
                        reverse: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredMessages.length,
                        itemBuilder: (context, index) {
                          final doc = filteredMessages[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final isPatient = data['sender'] == 'patient';
                          final messageId = doc.id;

                          return GestureDetector(
                            onLongPress: () => _showDeleteMessageDialog(doc.reference),
                            child: Dismissible(
                              key: Key('reply_$messageId'),
                              direction: DismissDirection.startToEnd,
                              confirmDismiss: (direction) async {
                                setState(() {
                                  replyingToMessage = data;
                                });
                                return false;
                              },
                              background: Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 20),
                                child: const Icon(Icons.reply, color: Color(0xff2F6FED)),
                              ),
                              child: messageBubble(
                                message: data['text'] ?? '',
                                isPatient: isPatient,
                                timestamp: data['createdAt'],
                                replyToText: data['replyToText'],
                                replyToSender: data['replyToSender'],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                /// INPUT BAR
                Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    border: Border(
                      top: BorderSide(
                        color: isDark ? Colors.grey[850]! : const Color(0xffE2E8F0),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (replyingToMessage != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: isDark ? const Color(0xff1E293B) : const Color(0xffF1F5F9),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 36,
                                color: const Color(0xff2F6FED),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      replyingToMessage!['sender'] == 'patient' ? "You" : _doctorName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                        color: Color(0xff2F6FED),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      replyingToMessage!['text'] ?? "",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: textColor.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    replyingToMessage = null;
                                  });
                                },
                                child: Icon(Icons.close, size: 20, color: subtextColor),
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: messageController,
                                textDirection: _getDirection(messageController.text),
                                onChanged: (val) {
                                  setState(() {});
                                },
                                style: TextStyle(color: textColor),
                                decoration: InputDecoration(
                                  hintText: "Type a message...",
                                  hintStyle: TextStyle(color: subtextColor),
                                  filled: true,
                                  fillColor: isDark ? const Color(0xff121212) : const Color(0xffF4F6FA),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: sendMessage,
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: const BoxDecoration(
                                  color: Color(0xff2F6FED),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget messageBubble({
    required String message,
    required bool isPatient,
    required dynamic timestamp,
    String? replyToText,
    String? replyToSender,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bubbleBgDoctor = isDark ? const Color(0xff2C2C2C) : Colors.white;
    final textBgDoctor = isDark ? Colors.white : Colors.black87;

    return Align(
      alignment: isPatient ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 280,
        ),
        margin: const EdgeInsets.only(
          bottom: 14,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isPatient ? const Color(0xff2F6FED) : bubbleBgDoctor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(22),
            topRight: const Radius.circular(22),
            bottomLeft: Radius.circular(
              isPatient ? 22 : 6,
            ),
            bottomRight: Radius.circular(
              isPatient ? 6 : 22,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (replyToText != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isPatient
                      ? Colors.black.withValues(alpha: 0.15)
                      : (isDark ? const Color(0xff3A3A3A) : const Color(0xffF1F5F9)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border(
                    left: BorderSide(
                      color: isPatient ? Colors.white70 : const Color(0xff2F6FED),
                      width: 3,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      replyToSender == 'patient'
                          ? (isPatient ? "You" : "Patient")
                          : (isPatient ? _doctorName : "You"),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: isPatient ? Colors.white70 : const Color(0xff2F6FED),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      replyToText,
                      textDirection: _getDirection(replyToText),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isPatient
                            ? Colors.white.withValues(alpha: 0.8)
                            : (isDark ? Colors.grey[300]! : Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Text(
              message,
              textDirection: _getDirection(message),
              style: TextStyle(
                color: isPatient ? Colors.white : textBgDoctor,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Spacer(),
                Text(
                  _formatTimestamp(timestamp),
                  style: TextStyle(
                    color: isPatient
                        ? Colors.white70
                        : (isDark ? Colors.grey[400]! : Colors.grey[500]!),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}