import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/ai_chat_service.dart';

class PatientAiChatScreen extends StatefulWidget {
  final String sessionId;
  final String? initialMessage;
  
  const PatientAiChatScreen({super.key, required this.sessionId, this.initialMessage});

  @override
  State<PatientAiChatScreen> createState() => _PatientAiChatScreenState();
}

class _PatientAiChatScreenState extends State<PatientAiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AiChatService _aiService = AiChatService();
  
  bool _isTyping = false;
  late String _patientId;

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

  @override
  void initState() {
    super.initState();
    _patientId = FirebaseAuth.instance.currentUser?.uid ?? 'test_patient_id';
    _checkDailyGreeting();
  }

  Future<void> _checkDailyGreeting() async {
    final messagesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(_patientId)
        .collection('sessions')
        .doc(widget.sessionId)
        .collection('messages');
        
    final recentMessages = await messagesRef
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();
        
    if (recentMessages.docs.isEmpty) {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(_patientId)
          .collection('sessions')
          .doc(widget.sessionId)
          .set({
        'title': 'New Conversation',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
        _messageController.text = widget.initialMessage!;
        sendMessage();
      } else {
        await messagesRef.add({
          'text': "Hi there! I'm here to listen. What's on your mind today?",
          'isUser': false,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } else if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      _messageController.text = widget.initialMessage!;
      sendMessage();
    }
  }

  Future<void> sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    final messagesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(_patientId)
        .collection('sessions')
        .doc(widget.sessionId)
        .collection('messages');

    // 1. Save user message to Firestore
    await messagesRef.add({
      'text': text,
      'isUser': true,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 2. Fetch recent history for context
    final historySnapshot = await messagesRef
        .orderBy('timestamp', descending: true)
        .limit(5)
        .get();
        
    List<Map<String, dynamic>> history = [];
    for (var doc in historySnapshot.docs.reversed) {
      history.add({
        'text': doc.data()['text'] ?? '',
        'isUser': doc.data()['isUser'] ?? false,
      });
    }

    setState(() {
      _isTyping = true;
    });

    _scrollToBottom();

    // 3. Call AI Service (it handles setting the session title on first user msg)
    await _aiService.sendMessage(
      patientId: _patientId,
      sessionId: widget.sessionId,
      messageText: text,
      messageHistory: history,
    );

    if (mounted) {
      setState(() {
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  void quickPrompt(String text) {
    _messageController.text = text;
    sendMessage();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
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

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Container(
              color: cardBg,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back, color: textColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "AI Recovery",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Always here for you",
                          style: TextStyle(color: subtextColor),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _showSosBottomSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xff3A1A1A) : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "SOS",
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// CHAT
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(_patientId)
                    .collection('sessions')
                    .doc(widget.sessionId)
                    .collection('messages')
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (docs.isNotEmpty) _scrollToBottom();
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: docs.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      
                      if (index == docs.length && _isTyping) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "AI is typing...",
                              style: TextStyle(color: textColor),
                            ),
                          ),
                        );
                      }

                      final message = docs[index].data() as Map<String, dynamic>;
                      final isUser = message["isUser"] ?? false;
                      final text = message["text"] ?? "";

                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          constraints: const BoxConstraints(maxWidth: 280),
                          decoration: BoxDecoration(
                            color: isUser ? const Color(0xff2F6FED) : cardBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            text,
                            textDirection: _getDirection(text),
                            style: TextStyle(
                              color: isUser ? Colors.white : textColor,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            /// QUICK ACTIONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: actionButton(
                      context,
                      "Start breathing\nexercise",
                      () => quickPrompt("Help me start a breathing exercise"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: actionButton(
                      context,
                      "Talk about\ncravings",
                      () => quickPrompt("I want to talk about cravings"),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            /// INPUT
            Container(
              color: cardBg,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.attach_file, color: subtextColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textDirection: _getDirection(_messageController.text),
                      onChanged: (val) {
                        setState(() {});
                      },
                      style: TextStyle(color: textColor),
                      onSubmitted: (_) => sendMessage(),
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: TextStyle(color: subtextColor),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: sendMessage,
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: const BoxDecoration(
                        color: Color(0xff2F6FED),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_upward, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget actionButton(BuildContext context, String text, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xff1A2A4A) : const Color(0xffEAF1FF),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? Colors.blue.shade300 : const Color(0xff2F6FED), 
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}