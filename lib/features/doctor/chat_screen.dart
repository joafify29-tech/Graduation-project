import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final dynamic data;
  final String role;

  const ChatScreen({super.key, required this.data, required this.role});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();
  final scrollController = ScrollController();

  bool isTyping = false;
  Map<String, dynamic>? replyingToMessage;

  @override
  void initState() {
    super.initState();
    _assignDoctorToPatient();
  }

  void _assignDoctorToPatient() {
    final doctorUid = FirebaseAuth.instance.currentUser?.uid;
    if (doctorUid != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(doctorUid)
          .get()
          .then((doc) {
        if (doc.exists) {
          final doctorName = doc.data()?['name'] ?? 'Doctor';
          FirebaseFirestore.instance
              .collection('referrals')
              .doc(widget.data.id)
              .update({
            'doctorId': doctorUid,
            'doctorName': doctorName,
          }).catchError((e) {
            debugPrint("Error updating patient's assigned doctor: $e");
          });
        }
      });
    }
  }

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
                    .doc(widget.data.id)
                    .collection('messages_${FirebaseAuth.instance.currentUser?.uid ?? "unknown"}');
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

  Future<void> sendMessage() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    final replyData = replyingToMessage;

    // Clear controller and reset state immediately for responsive UI
    controller.clear();
    setState(() {
      isTyping = false;
      replyingToMessage = null;
    });

    final doctorUid = FirebaseAuth.instance.currentUser?.uid ?? "unknown";
    await FirebaseFirestore.instance
        .collection('referrals')
        .doc(widget.data.id)
        .collection('messages_$doctorUid')
        .add({
      "text": text,
      "sender": widget.role,
      "createdAt": FieldValue.serverTimestamp(),
      "seen": false,
      if (replyData != null) ...{
        'replyToText': replyData['text'],
        'replyToSender': replyData['sender'],
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final map = widget.data.data();
    final name = map['name'] ?? "Patient";

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xff121212) : const Color(0xffF7F8FA);
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          // 🔝 HEADER
          SafeArea(
            child: Container(
              color: cardBg,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: textColor),
                  ),
                  const CircleAvatar(
                    radius: 20,
                    child: Icon(Icons.person),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_sweep, color: Colors.red),
                    tooltip: "Clear Chat",
                    onPressed: _clearChat,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),

          Divider(
            height: 1,
            color: isDark ? Colors.grey[800] : const Color(0xffE2E8F0),
          ),

          // 🔥 MESSAGES
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('referrals')
                  .doc(widget.data.id)
                  .collection('messages_${FirebaseAuth.instance.currentUser?.uid ?? "unknown"}')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final msgs = snapshot.data!.docs;

                return ListView.builder(
                  controller: scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(15),
                  itemCount: msgs.length,
                  itemBuilder: (context, index) {
                    final doc = msgs[index];
                    final msg = doc.data() as Map<String, dynamic>;

                    // 🔥 mark seen
                    if (msg['sender'] != widget.role && msg['seen'] == false) {
                      FirebaseFirestore.instance
                          .collection('referrals')
                          .doc(widget.data.id)
                          .collection('messages_${FirebaseAuth.instance.currentUser?.uid ?? "unknown"}')
                          .doc(doc.id)
                          .update({"seen": true});
                    }

                    final messageId = doc.id;

                    return Dismissible(
                      key: Key('reply_$messageId'),
                      direction: DismissDirection.startToEnd,
                      confirmDismiss: (direction) async {
                        setState(() {
                          replyingToMessage = msg;
                        });
                        return false;
                      },
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(Icons.reply, color: Color(0xff2F6FED)),
                      ),
                      child: GestureDetector(
                        onLongPress: () {
                          _showDeleteMessageDialog(doc.reference);
                        },
                        child: messageBubble(msg, name),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 🔥 Typing Indicator
          if (isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 5),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Typing...", style: TextStyle(color: subtextColor)),
              ),
            ),

          // 🔥 INPUT (Column containing preview + input row)
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
                                replyingToMessage!['sender'] == widget.role ? "You" : name,
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
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          textDirection: _getDirection(controller.text),
                          onChanged: (val) {
                            setState(() {
                              isTyping = val.isNotEmpty;
                            });
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
                        child: const CircleAvatar(
                          radius: 26,
                          backgroundColor: Color(0xff2F6FED),
                          child: Icon(Icons.send, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // 🔥 MESSAGE UI
  Widget messageBubble(Map<String, dynamic> msg, String patientName) {
    final isMe = msg['sender'] == widget.role;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bubbleBgOther = isDark ? const Color(0xff2C2C2C) : Colors.white;
    final textBgOther = isDark ? Colors.white : Colors.black87;
    final replyToText = msg['replyToText'];
    final replyToSender = msg['replyToSender'];
    final messageText = msg['text'] ?? "";

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 280,
        ),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xff2F6FED) : bubbleBgOther,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(22),
            topRight: const Radius.circular(22),
            bottomLeft: Radius.circular(
              isMe ? 22 : 6,
            ),
            bottomRight: Radius.circular(
              isMe ? 6 : 22,
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
                  color: isMe
                      ? Colors.black.withValues(alpha: 0.15)
                      : (isDark ? const Color(0xff3A3A3A) : const Color(0xffF1F5F9)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border(
                    left: BorderSide(
                      color: isMe ? Colors.white70 : const Color(0xff2F6FED),
                      width: 3,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      replyToSender == widget.role
                          ? (isMe ? "You" : "Doctor")
                          : (isMe ? patientName : "You"),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: isMe ? Colors.white70 : const Color(0xff2F6FED),
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
                        color: isMe
                            ? Colors.white.withValues(alpha: 0.8)
                            : (isDark ? Colors.grey[300]! : Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Text(
              messageText,
              textDirection: _getDirection(messageText),
              style: TextStyle(
                color: isMe ? Colors.white : textBgOther,
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
                  _formatTimestamp(msg['createdAt']),
                  style: TextStyle(
                    color: isMe
                        ? Colors.white70
                        : (isDark ? Colors.grey[400]! : Colors.grey[500]!),
                    fontSize: 9,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    msg['seen'] == true ? Icons.done_all : Icons.done,
                    size: 13,
                    color: msg['seen'] == true ? Colors.blue[300]! : Colors.white70,
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}