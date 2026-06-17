import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'referral_details_screen.dart';

class ReferralHistoryScreen extends StatefulWidget {
  const ReferralHistoryScreen({super.key});

  @override
  State<ReferralHistoryScreen> createState() =>
      _ReferralHistoryScreenState();
}

class _ReferralHistoryScreenState extends State<ReferralHistoryScreen> {
  String selectedFilter = "All";
  String searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F4F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              // 🔝 Top
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Referral History",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: const [
                      Icon(Icons.language),
                      SizedBox(width: 10),
                      Icon(Icons.dark_mode),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 20),

              // 🔍 Search
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchText = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search patient name...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // 🟣 Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    filterButton("All"),
                    filterButton("Active"),
                    filterButton("Pending"),
                    filterButton("Rejected"),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // 🔥 Firebase Data
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('referrals')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text("No referrals yet"),
                      );
                    }

                    var docs = snapshot.data!.docs;

                    // 🔍 Filter + Search
                    var filteredDocs = docs.where((doc) {
                      String name =
                          doc['name'].toString().toLowerCase();
                      String status =
                          doc['status'].toString().toUpperCase();

                      bool matchesSearch = name.contains(searchText);

                      bool matchesFilter = selectedFilter == "All"
                          ? true
                          : status == selectedFilter.toUpperCase();

                      return matchesSearch && matchesFilter;
                    }).toList();

                    return ListView.builder(
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        var data = filteredDocs[index];

                        String name = data['name'] ?? "";
                        String type = data['addiction'] ?? "";
                        String status = data['status'] ?? "ACTIVE";

                        Timestamp? timestamp = data['createdAt'];
                        String date = timestamp != null
                            ? "${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}"
                            : "Unknown";

                        return HistoryCard(
                          name: name,
                          type: type,
                          status: status,
                          date: date,
                          data: data,
                          docId: data.id,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 Filter Button
  Widget filterButton(String title) {
    final isSelected = selectedFilter == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = title;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

// 🔥 Card
class HistoryCard extends StatelessWidget {
  final String name;
  final String type;
  final String status;
  final String date;
  final dynamic data;
  final String docId;

  const HistoryCard({
    super.key,
    required this.name,
    required this.type,
    required this.status,
    required this.date,
    required this.data,
    required this.docId,
  });

  @override
  Widget build(BuildContext context) {
    Color color;

    if (status == "ACTIVE") {
      color = Colors.green;
    } else if (status == "PENDING") {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReferralDetailsScreen(
              data: data,
              docId: docId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const CircleAvatar(radius: 25),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),

                  const SizedBox(height: 5),

                  Text(type,
                      style: const TextStyle(color: Colors.blue)),

                  const SizedBox(height: 5),

                  Text(
                    "Referral sent: $date",
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(color: color, fontSize: 12),
              ),
            )
          ],
        ),
      ),
    );
  }
}