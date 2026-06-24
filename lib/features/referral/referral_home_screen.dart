import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'referral_details_screen.dart';
import '../../core/main_screen.dart';

class ReferralHomeScreen extends StatefulWidget {
  const ReferralHomeScreen({super.key});

  @override
  State<ReferralHomeScreen> createState() => _ReferralHomeScreenState();
}

class _ReferralHomeScreenState extends State<ReferralHomeScreen> {
  TextEditingController searchController = TextEditingController();
  String searchText = "";

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xff121212) : const Color(0xffF7F8FA);
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final subtextColor = isDark ? Colors.grey[400]! : const Color(0xff64748B);
    final inputBg = isDark ? const Color(0xff2A2A2A) : const Color(0xffF0F2F5);

    return Scaffold(
      backgroundColor: bg,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 🔝 HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Referral Center",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),

                  Row(
                    children: [
                      Icon(Icons.language, size: 20, color: textColor),
                      const SizedBox(width: 12),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: isDark ? const Color(0xff4A2D0B) : Colors.orange.shade100,
                        child: const Icon(Icons.person, size: 18, color: Colors.orange),
                      ),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 20),

              // 🔍 SEARCH
              TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchText = value.toLowerCase();
                  });
                },
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: "Search patients...",
                  hintStyle: TextStyle(color: subtextColor),
                  prefixIcon: Icon(Icons.search, color: subtextColor),
                  filled: true,
                  fillColor: inputBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // 🧾 HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "RECENT REFERRALS",
                    style: TextStyle(
                      fontSize: 12,
                      color: subtextColor,
                      letterSpacing: 1,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      final mainState =
                          context.findAncestorStateOfType<MainScreenState>();
                      mainState?.changeTab(2);
                    },
                    child: const Text(
                      "View All",
                      style: TextStyle(
                        color: Color(0xff2F6FED),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // 🔥 LIST
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('referrals')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {

                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var docs = snapshot.data!.docs;

                    var filteredDocs = docs.where((doc) {
                      String name =
                          doc['name'].toString().toLowerCase();
                      return name.contains(searchText);
                    }).toList();

                    return ListView.builder(
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {

                        var data = filteredDocs[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReferralDetailsScreen(
                                  data: data,
                                  docId: data.id,
                                ),
                              ),
                            );
                          },
                          child: ReferralCard(
                            name: data['name'],
                            age:
                                "${data['age']} yrs • ${data['gender']}",
                            type: data['addiction'],
                            status: data['status'],
                          ),
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
}

// 🔥 CARD (Pixel Perfect)
class ReferralCard extends StatelessWidget {
  final String name;
  final String age;
  final String type;
  final String status;

  const ReferralCard({
    super.key,
    required this.name,
    required this.age,
    required this.type,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final subtextColor = isDark ? Colors.grey[400]! : const Color(0xff64748B);
    final shadowColor = isDark ? Colors.black.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.05);
    final avatarBg = isDark ? const Color(0xff2A2A2A) : Colors.grey.shade200;
    final avatarIconColor = isDark ? Colors.grey[400] : Colors.grey;

    final isActive = status == "ACTIVE";
    final statusBg = isActive
        ? (isDark ? const Color(0xff062f17) : const Color(0xffE6F4EA))
        : (isDark ? const Color(0xff452A0F) : const Color(0xffFFF4E5));
    final statusTextCol = isActive
        ? (isDark ? const Color(0xff4ADE80) : const Color(0xff34A853))
        : (isDark ? const Color(0xffFBBF24) : const Color(0xffF59E0B));

    final typeBg = isDark ? const Color(0xff1A2A4A) : const Color(0xffEAF2FF);
    final typeTextCol = isDark ? Colors.blue[300]! : const Color(0xff2F6FED);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [

          CircleAvatar(
            radius: 28,
            backgroundColor: avatarBg,
            child: Icon(Icons.person, color: avatarIconColor),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: textColor,
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusTextCol,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  age,
                  style: TextStyle(
                    color: subtextColor,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: typeBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    type.toUpperCase(),
                    style: TextStyle(
                      color: typeTextCol,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Last update: 2 hours ago",
                      style: TextStyle(
                        color: subtextColor,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      "Details >",
                      style: TextStyle(
                        color: typeTextCol,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}