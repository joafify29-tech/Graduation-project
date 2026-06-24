import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminActivityLogsScreen extends StatefulWidget {
  const AdminActivityLogsScreen({super.key});

  @override
  State<AdminActivityLogsScreen> createState() => _AdminActivityLogsScreenState();
}

class _AdminActivityLogsScreenState extends State<AdminActivityLogsScreen> {
  String searchQuery = "";
  String filterEvent = "All Events";
  final List<String> filters = ["All Events", "Errors", "Warnings", "System"];

  late Stream<QuerySnapshot> _logsStream;

  @override
  void initState() {
    super.initState();
    _refreshStream();
  }

  void _refreshStream() {
    _logsStream = FirebaseFirestore.instance
        .collection('activity_logs')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _refreshStream();
    });
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xff121212) : const Color(0xffF8FAFC);
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final subtextColor = isDark ? Colors.grey[400]! : const Color(0xff64748B);
    final borderCol = isDark ? Colors.grey[800]! : const Color(0xffE2E8F0);
    final infoTextColor = isDark ? Colors.grey[500]! : const Color(0xff94A3B8);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Activity Logs",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.blue,
            height: 2,
          ),
        ),
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  searchQuery = val.toLowerCase();
                });
              },
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "Search logs or filter by ID...",
                hintStyle: TextStyle(color: infoTextColor, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: infoTextColor),
                suffixIcon: Icon(Icons.filter_list, color: infoTextColor),
                filled: true,
                fillColor: cardBg,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: borderCol),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ),

          // FILTER TABS
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isSelected = filterEvent == filter;
                
                // Color dots for specific filters
                Widget? dot;
                if (filter == "Errors") dot = _dot(const Color(0xffEF4444));
                if (filter == "Warnings") dot = _dot(const Color(0xffEAB308));
                if (filter == "System") dot = _dot(const Color(0xff3B82F6));

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      filterEvent = filter;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xff3B82F6) : cardBg,
                      border: isSelected ? null : Border.all(color: borderCol),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        if (dot != null) ...[dot, const SizedBox(width: 6)],
                        Text(
                          filter,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : (isDark ? Colors.grey[300]! : const Color(0xff475569)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: StreamBuilder<QuerySnapshot>(
                stream: _logsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history, color: isDark ? Colors.grey[800]! : const Color(0xffCBD5E1), size: 48),
                              const SizedBox(height: 16),
                              Text("No activity logs found.", style: TextStyle(color: subtextColor, fontSize: 16)),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  final docs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final type = (data['type'] ?? "").toString().toLowerCase();
                    final title = (data['title'] ?? "").toString().toLowerCase();

                    if (filterEvent == "Errors" && type != "error") return false;
                    if (filterEvent == "Warnings" && type != "warning") return false;
                    if (filterEvent == "System" && type != "system") return false;

                    if (searchQuery.isNotEmpty && !title.contains(searchQuery)) return false;

                    return true;
                  }).toList();

                  if (docs.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                        Center(
                          child: Text("No logs found.", style: TextStyle(color: subtextColor)),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      
                      // Format timestamp dynamically with seconds
                      String displayTime = "Just now";
                      final ts = data['timestamp'] as Timestamp?;
                      if (ts != null) {
                        final dt = ts.toDate();
                        final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
                        final minute = dt.minute.toString().padLeft(2, '0');
                        final second = dt.second.toString().padLeft(2, '0');
                        final ampm = dt.hour >= 12 ? 'PM' : 'AM';
                        displayTime = "$hour:$minute:$second $ampm";
                      } else if (data['time'] != null) {
                        displayTime = data['time'];
                      }

                      return _logCard(
                        context: context,
                        title: data['title'] ?? "Unknown",
                        subtitle: data['subtitle'] ?? "",
                        time: displayTime,
                        type: data['type'] ?? "system",
                        isLast: index == docs.length - 1,
                      );
                    },
                  );
                },
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextButton(
              onPressed: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("View Older Logs", style: TextStyle(color: Colors.blue[300] ?? Colors.blue, fontSize: 13)),
                  Icon(Icons.keyboard_arrow_down, color: Colors.blue[300] ?? Colors.blue, size: 16)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _logCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String time,
    required String type,
    required bool isLast,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final subtextColor = isDark ? Colors.grey[400]! : const Color(0xff64748B);
    final borderCol = isDark ? Colors.grey[800]! : const Color(0xffE2E8F0);
    final infoTextColor = isDark ? Colors.grey[500]! : const Color(0xff94A3B8);

    IconData icon;
    Color iconColor;
    Color iconBg;
    String badgeText = "";
    Color badgeColor = Colors.transparent;
    Color badgeBg = Colors.transparent;

    switch (type.toLowerCase()) {
      case 'error':
        icon = Icons.close;
        iconColor = const Color(0xffEF4444);
        iconBg = isDark ? const Color(0xff450a0a) : const Color(0xffFEF2F2);
        badgeText = "Critical";
        badgeColor = isDark ? const Color(0xffF87171) : const Color(0xffEF4444);
        badgeBg = isDark ? const Color(0xff450a0a) : const Color(0xffFEF2F2);
        break;
      case 'warning':
        icon = Icons.priority_high;
        iconColor = const Color(0xffEAB308);
        iconBg = isDark ? const Color(0xff422006) : const Color(0xffFEF9C3);
        break;
      case 'success':
        icon = Icons.check;
        iconColor = const Color(0xff22C55E);
        iconBg = isDark ? const Color(0xff062f17) : const Color(0xffDCFCE7);
        badgeText = "Success";
        badgeColor = isDark ? const Color(0xff4ADE80) : const Color(0xff22C55E);
        badgeBg = isDark ? const Color(0xff062f17) : const Color(0xffDCFCE7);
        break;
      default:
        icon = Icons.person_outline;
        iconColor = const Color(0xff3B82F6);
        iconBg = isDark ? const Color(0xff1A2A4A) : const Color(0xffEFF6FF);
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline indicator
          SizedBox(
            width: 40,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                if (!isLast)
                  Positioned(
                    top: 20,
                    bottom: -20,
                    child: Container(
                      width: 1,
                      color: borderCol,
                    ),
                  ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          // Card content
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor),
                        ),
                      ),
                      if (badgeText.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(12)),
                          child: Text(badgeText, style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold)),
                        )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: subtextColor),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: infoTextColor),
                      const SizedBox(width: 4),
                      Text(time, style: TextStyle(fontSize: 11, color: infoTextColor)),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
