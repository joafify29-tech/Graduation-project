import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xff121212) : const Color(0xffF3F4F6);
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final subtextColor = isDark ? Colors.grey[400]! : const Color(0xff64748B);
    final fieldBg = isDark ? const Color(0xff2A2A2A) : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              // 🔝 Top
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Referral History",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.language, color: textColor),
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
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: "Search patient name...",
                  hintStyle: TextStyle(color: subtextColor),
                  prefixIcon: Icon(Icons.search, color: subtextColor),
                  filled: true,
                  fillColor: fieldBg,
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
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          "No referrals yet",
                          style: TextStyle(color: subtextColor),
                        ),
                      );
                    }

                    final currentUid = FirebaseAuth.instance.currentUser?.uid;
                    var docs = snapshot.data!.docs;

                    // Filter by referralId in memory
                    var filteredDocs = docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['referralId'] == currentUid;
                    }).toList();

                    // Sort by createdAt descending in memory
                    filteredDocs.sort((a, b) {
                      final aTime = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                      final bTime = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                      if (aTime == null && bTime == null) return 0;
                      if (aTime == null) return 1;
                      if (bTime == null) return -1;
                      return bTime.compareTo(aTime);
                    });

                    // 🔍 Search + status filter in memory
                    filteredDocs = filteredDocs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      String name = (data['name'] ?? "").toString().toLowerCase();
                      String status = (data['status'] ?? "ACTIVE").toString().toUpperCase();

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          color: isSelected ? Colors.blue : (isDark ? const Color(0xff2A2A2A) : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : (isDark ? Colors.grey[400]! : Colors.black),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final subtextColor = isDark ? Colors.grey[400]! : const Color(0xff64748B);

    Color badgeColor;
    if (status == "ACTIVE") {
      badgeColor = isDark ? Colors.greenAccent : Colors.green;
    } else if (status == "PENDING") {
      badgeColor = isDark ? Colors.orangeAccent : Colors.orange;
    } else {
      badgeColor = isDark ? Colors.redAccent : Colors.red;
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
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: isDark ? const Color(0xff2A2A2A) : const Color(0xffEDEFF2),
              child: Icon(Icons.person, color: isDark ? Colors.white54 : Colors.black54),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    type,
                    style: const TextStyle(color: Color(0xff2F6FED)),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    "Referral sent: $date",
                    style: TextStyle(
                      color: subtextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            )
          ],
        ),
      ),
    );
  }
}