import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String selectedFilter = "All";
  String search = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff2F6FED),
        onPressed: () {},
        child: const Icon(Icons.add),
      ),

      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collectionGroup('reminders')
              .snapshots(),
          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return const Center(child: Text("No reminders yet"));
            }

            List<Widget> todayList = [];
            List<Widget> afternoonList = [];

            for (var doc in docs) {
              final r = doc.data() as Map<String, dynamic>;

              final title = r['title'] ?? "";
              final time = r['time'] ?? "";
              final type = r['type'] ?? "Medication";
              final high = r['high'] ?? false;

              if (search.isNotEmpty &&
                  !title.toLowerCase().contains(search.toLowerCase())) {
                continue;
              }

              if (selectedFilter != "All" && selectedFilter != type) {
                continue;
              }

              final patientId = doc.reference.parent.parent?.id;

              final card = FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('referrals')
                    .doc(patientId)
                    .get(),
                builder: (context, snap) {

                  String name = "Patient";

                  if (snap.hasData && snap.data!.exists) {
                    final d = snap.data!.data() as Map<String, dynamic>;
                    name = d['name'] ?? "Patient";
                  }

                  return reminderCard(name, title, time, type, high);
                },
              );

              if (_isMorning(time)) {
                todayList.add(card);
              } else {
                afternoonList.add(card);
              }
            }

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [

                // 🔝 HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Patient Reminders",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Icon(Icons.language),
                        SizedBox(width: 10),
                        Icon(Icons.dark_mode),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 20),

                // 🔍 SEARCH
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        search = val;
                      });
                    },
                    decoration: const InputDecoration(
                      icon: Icon(Icons.search),
                      hintText: "Search patients or reminders...",
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // 🔵 FILTERS
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      chip("All"),
                      chip("Medication"),
                      chip("Sessions"),
                      chip("Tests"),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                if (todayList.isNotEmpty) ...[
                  section("UPCOMING TODAY"),
                  ...todayList,
                ],

                const SizedBox(height: 20),

                if (afternoonList.isNotEmpty) ...[
                  section("AFTERNOON"),
                  ...afternoonList,
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  bool _isMorning(String time) {
    return time.contains("AM");
  }

  Widget chip(String text) {
    final active = selectedFilter == text;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = text;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xff2F6FED) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget section(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text,
          style: const TextStyle(color: Colors.grey)),
    );
  }

  Widget reminderCard(
      String name, String title, String time, String type, bool high) {

    IconData icon = Icons.medication;

    if (type == "Tests") icon = Icons.science;
    if (type == "Sessions") icon = Icons.psychology;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          CircleAvatar(
            backgroundColor: high
                ? Colors.red.shade100
                : const Color(0xffE8F0FE),
            child: Icon(icon,
                color: high ? Colors.red : const Color(0xff2F6FED)),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(name,
                    style:
                        const TextStyle(fontWeight: FontWeight.bold)),

                Text(title,
                    style: const TextStyle(color: Colors.grey)),

                const SizedBox(height: 5),

                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    tag(type.toUpperCase()),
                    tag(high ? "HIGH PRIORITY" : "ROUTINE"),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(width: 8),

          Text(
            time,
            style: const TextStyle(fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }

  Widget tag(String text) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xffE8F0FE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10),
      ),
    );
  }
}