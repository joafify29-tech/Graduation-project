import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Future<void> sendMessage() async {

    if (messageController.text
        .trim()
        .isEmpty) {
      return;
    }

    await FirebaseFirestore.instance
        .collection('referrals')
        .doc(uid)
        .collection('messages')
        .add({
      'text':
          messageController.text.trim(),
      'sender': 'patient',
      'seen': false,
      'createdAt':
          Timestamp.now(),
    });

    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffF7F8FA),

      body: SafeArea(
        child: Column(
          children: [

            /// HEADER
            Container(
              padding:
                  const EdgeInsets.all(
                      16),

              child: Row(
                children: [

                  IconButton(
                    onPressed: () {
                      Navigator.pop(
                          context);
                    },
                    icon: const Icon(
                      Icons
                          .arrow_back_ios,
                    ),
                  ),

                  const CircleAvatar(
                    radius: 24,
                    child: Icon(
                      Icons.person,
                    ),
                  ),

                  const SizedBox(
                      width: 12),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [

                        Text(
                          "Dr. test",
                          style:
                              TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,
                            fontSize:
                                16,
                          ),
                        ),

                        Text(
                          "Online",
                          style:
                              TextStyle(
                            color: Colors
                                .green,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.red,
                      borderRadius:
                          BorderRadius
                              .circular(
                                  20),
                    ),
                    child:
                        const Text(
                      "SOS",
                      style:
                          TextStyle(
                        color: Colors
                            .white,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(
              height: 1,
            ),
            Expanded(
  child: StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('referrals')
        .doc(uid)
        .collection('messages')
        .orderBy(
          'createdAt',
          descending: false,
        )
        .snapshots(),
    builder: (context, snapshot) {

      if (!snapshot.hasData) {
        return const Center(
          child:
              CircularProgressIndicator(),
        );
      }

      final messages =
          snapshot.data!.docs;

      if (messages.isEmpty) {
        return const Center(
          child: Text(
            "No messages yet",
          ),
        );
      }

      return ListView.builder(
        controller:
            scrollController,
        padding:
            const EdgeInsets.all(
                16),
        itemCount:
            messages.length,
        itemBuilder:
            (context, index) {

          final data =
              messages[index].data()
                  as Map<String,
                      dynamic>;

          final isPatient =
              data['sender'] ==
                  'patient';

          return messageBubble(
            message:
                data['text'] ?? '',
            isPatient:
                isPatient,
          );
        },
      );
    },
  ),
),

/// INPUT BAR

Container(
  padding:
      const EdgeInsets.all(12),
  decoration:
      const BoxDecoration(
    color: Colors.white,
  ),
  child: Row(
    children: [

      Expanded(
        child: TextField(
          controller:
              messageController,
          decoration:
              InputDecoration(
            hintText:
                "Type a message...",
            filled: true,
            fillColor:
                const Color(
                    0xffF4F6FA),
            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius
                      .circular(
                          30),
              borderSide:
                  BorderSide.none,
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
          decoration:
              const BoxDecoration(
            color:
                Color(0xff2F6FED),
            shape:
                BoxShape.circle,
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
    );
  }
  Widget messageBubble({
  required String message,
  required bool isPatient,
}) {
  return Align(
    alignment: isPatient
        ? Alignment.centerRight
        : Alignment.centerLeft,

    child: Container(
      constraints: const BoxConstraints(
        maxWidth: 280,
      ),

      margin: const EdgeInsets.only(
        bottom: 14,
      ),

      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),

      decoration: BoxDecoration(
        color: isPatient
            ? const Color(0xff2F6FED)
            : Colors.white,

        borderRadius: BorderRadius.only(
          topLeft:
              const Radius.circular(22),
          topRight:
              const Radius.circular(22),
          bottomLeft: Radius.circular(
            isPatient ? 22 : 6,
          ),
          bottomRight: Radius.circular(
            isPatient ? 6 : 22,
          ),
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.04,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Text(
        message,
        style: TextStyle(
          color: isPatient
              ? Colors.white
              : Colors.black87,
          fontSize: 15,
          height: 1.4,
        ),
      ),
    ),
  );

}
}