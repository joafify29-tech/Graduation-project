import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  Widget build(BuildContext context) {
    final map = widget.data.data();
    final name = map['name'] ?? "";

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),

      body: Column(
        children: [

          // 🔝 HEADER
          SafeArea(
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                Text(name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 🔥 MESSAGES
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('referrals')
                  .doc(widget.data.id)
                  .collection('messages')
                  .orderBy('createdAt')
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final msgs = snapshot.data!.docs;

                // 🔥 Auto Scroll
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  scrollController.jumpTo(
                    scrollController.position.maxScrollExtent,
                  );
                });

                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(15),
                  children: msgs.map((doc) {
                    final msg = doc.data() as Map<String, dynamic>;

                    // 🔥 mark seen
                    if (msg['sender'] != widget.role && msg['seen'] == false) {
                      FirebaseFirestore.instance
                          .collection('referrals')
                          .doc(widget.data.id)
                          .collection('messages')
                          .doc(doc.id)
                          .update({"seen": true});
                    }

                    return messageBubble(msg);
                  }).toList(),
                );
              },
            ),
          ),

          // 🔥 Typing Indicator
          if (isTyping)
            const Padding(
              padding: EdgeInsets.only(left: 20, bottom: 5),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Typing...",
                    style: TextStyle(color: Colors.grey)),
              ),
            ),

          // 🔥 INPUT
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: (val) {
                      setState(() {
                        isTyping = val.isNotEmpty;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: Colors.white,
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
                    backgroundColor: Color(0xff2F6FED),
                    child: Icon(Icons.send, color: Colors.white),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // 🔥 MESSAGE UI
  Widget messageBubble(Map<String, dynamic> msg) {
    final isMe = msg['sender'] == widget.role;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [

          Container(
            margin: const EdgeInsets.only(bottom: 5),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xff2F6FED) : Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              msg['text'] ?? "",
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
          ),

          // 🔥 Seen Indicator
          if (isMe)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  msg['seen'] == true
                      ? Icons.done_all
                      : Icons.check,
                  size: 14,
                  color: msg['seen'] == true
                      ? Colors.blue
                      : Colors.grey,
                ),
              ],
            ),

          const SizedBox(height: 5),
        ],
      ),
    );
  }

  // 🔥 SEND
  Future<void> sendMessage() async {
    if (controller.text.trim().isEmpty) return;

    await FirebaseFirestore.instance
        .collection('referrals')
        .doc(widget.data.id)
        .collection('messages')
        .add({
      "text": controller.text.trim(),
      "sender": widget.role,
      "createdAt": Timestamp.now(),
      "seen": false, // 🔥 مهم
    });

    controller.clear();

    setState(() {
      isTyping = false;
    });
  }
}