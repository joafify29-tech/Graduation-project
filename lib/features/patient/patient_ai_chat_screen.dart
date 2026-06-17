import 'package:flutter/material.dart';

class PatientAiChatScreen extends StatefulWidget {
  const PatientAiChatScreen({super.key});

  @override
  State<PatientAiChatScreen> createState() =>
      _PatientAiChatScreenState();
}

class _PatientAiChatScreenState
    extends State<PatientAiChatScreen> {

  final TextEditingController messageController =
      TextEditingController();

  final List<Map<String, dynamic>> messages = [
    {
      "text":
          "Remember, your strength is greater than your struggle. How are you feeling right now?",
      "isUser": false,
    },
  ];

  void sendMessage() {

    if (messageController.text.trim().isEmpty) {
      return;
    }

    final message = messageController.text.trim();

    setState(() {
      messages.add({
        "text": message,
        "isUser": true,
      });
    });

    messageController.clear();

    Future.delayed(
      const Duration(seconds: 1),
      () {
        setState(() {
          messages.add({
            "text":
                "I'm here with you. Tell me more about what you're feeling.",
            "isUser": false,
          });
        });
      },
    );
  }

  void quickPrompt(String text) {

    setState(() {
      messages.add({
        "text": text,
        "isUser": true,
      });
    });

    Future.delayed(
      const Duration(seconds: 1),
      () {
        setState(() {
          messages.add({
            "text":
                "Let's work through that together.",
            "isUser": false,
          });
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),

      body: SafeArea(
        child: Column(
          children: [

            /// HEADER

            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),

              child: Row(
                children: [

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Text(
                          "AI Recovery",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          "Always here for you",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "SOS",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// CHAT

            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.all(20),
                itemCount: messages.length,
                itemBuilder: (context, index) {

                  final message =
                      messages[index];

                  final isUser =
                      message["isUser"];

                  return Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,

                    child: Container(
                      margin:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),

                      padding:
                          const EdgeInsets.all(
                        16,
                      ),

                      constraints:
                          const BoxConstraints(
                        maxWidth: 280,
                      ),

                      decoration:
                          BoxDecoration(
                        color: isUser
                            ? const Color(
                                0xff2F6FED)
                            : Colors.white,

                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),

                      child: Text(
                        message["text"],
                        style: TextStyle(
                          color: isUser
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            /// QUICK ACTIONS

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              child: Row(
                children: [

                  Expanded(
                    child: actionButton(
                      "Start breathing\nexercise",
                      () {
                        quickPrompt(
                          "Help me start a breathing exercise",
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: actionButton(
                      "Talk about\ncravings",
                      () {
                        quickPrompt(
                          "I want to talk about cravings",
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// INPUT

            Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.all(12),

              child: Row(
                children: [

                  const Icon(
                    Icons.attach_file,
                    color: Colors.grey,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: TextField(
                      controller:
                          messageController,
                      decoration:
                          const InputDecoration(
                        hintText:
                            "Type a message...",
                        border:
                            InputBorder.none,
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: sendMessage,
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration:
                          const BoxDecoration(
                        color:
                            Color(0xff2F6FED),
                        shape:
                            BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_upward,
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
    );
  }

  Widget actionButton(
    String text,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color:
              const Color(0xffEAF1FF),
          borderRadius:
              BorderRadius.circular(18),
        ),

        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xff2F6FED),
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}