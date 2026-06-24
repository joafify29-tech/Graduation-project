import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_users_screen.dart';
import 'admin_activity_logs_screen.dart';
import 'admin_settings_screen.dart';
import '../doctor/notifications_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  final Function(int)? onNavigate;

  const AdminDashboardScreen({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xff121212) : const Color(0xffF8FAFC);
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final subtextColor = isDark ? Colors.grey[400]! : const Color(0xff64748B);
    final borderCol = isDark ? Colors.grey[800]! : const Color(0xffF1F5F9);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "System Administration",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: isDark ? const Color(0xff1A2A4A) : Colors.blue.shade100,
                        child: const Icon(Icons.admin_panel_settings, color: Colors.blue),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xff22C55E),
                            shape: BoxShape.circle,
                            border: Border.all(color: isDark ? const Color(0xff1E1E1E) : Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 24),

              // STATS CARDS
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, usersSnapshot) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('referrals').snapshots(),
                    builder: (context, referralsSnapshot) {
                      final Map<String, Map<String, dynamic>> usersMap = {};
                      if (usersSnapshot.hasData) {
                        for (var doc in usersSnapshot.data!.docs) {
                          usersMap[doc.id] = doc.data() as Map<String, dynamic>;
                        }
                      }

                      final Map<String, Map<String, dynamic>> referralsMap = {};
                      if (referralsSnapshot.hasData) {
                        for (var doc in referralsSnapshot.data!.docs) {
                          referralsMap[doc.id] = doc.data() as Map<String, dynamic>;
                        }
                      }

                      int patientCount = 0;
                      int doctorCount = 0;
                      int referralCount = 0;

                      // Count doctors and referrals from users
                      usersMap.forEach((id, userData) {
                        final role = (userData['role'] ?? "").toString().toLowerCase().trim();
                        if (role == 'doctor') {
                          doctorCount++;
                        } else if (role == 'referral') {
                          referralCount++;
                        }
                      });

                      // Count patients ONLY if they exist in both users and referrals collections
                      referralsMap.forEach((id, referralData) {
                        if (usersMap.containsKey(id)) {
                          patientCount++;
                        }
                      });

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _statCard(context, "PATIENTS", patientCount.toString(), Icons.people),
                          _statCard(context, "DOCTORS", doctorCount.toString(), Icons.medical_services),
                          _statCard(context, "REFERRALS", referralCount.toString(), Icons.business),
                        ],
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "PRIORITY ALERTS",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey[400] : const Color(0xff94A3B8),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('password_reset_requests')
                    .where('status', isEqualTo: 'pending')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderCol),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Color(0xff2B82F6)),
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderCol),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle_outline, color: Color(0xff94A3B8), size: 32),
                          const SizedBox(height: 8),
                          Text(
                            "No priority alerts at this time.",
                            style: TextStyle(color: subtextColor, fontSize: 13),
                          )
                        ],
                      ),
                    );
                  }

                  // Sort in memory by timestamp desc to ensure latest requests are on top
                  final sortedDocs = List<QueryDocumentSnapshot>.from(docs);
                  sortedDocs.sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;
                    final aTime = aData['timestamp'] as Timestamp?;
                    final bTime = bData['timestamp'] as Timestamp?;
                    if (aTime == null) return 1;
                    if (bTime == null) return -1;
                    return bTime.compareTo(aTime);
                  });

                  return Column(
                    children: sortedDocs.map((doc) => PasswordResetAlertCard(doc: doc)).toList(),
                  );
                },
              ),

              const SizedBox(height: 32),

              // MANAGEMENT LINKS
              Text(
                "MANAGEMENT",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: subtextColor,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(height: 12),

              _managementLink(
                context,
                "User Management",
                Icons.manage_accounts,
                onTap: () {
                  if (onNavigate != null) {
                    onNavigate!(1); // Index 1 is the Users tab
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              _managementLink(
                context,
                "Activity Logs",
                Icons.history,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminActivityLogsScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
              _managementLink(context, "System Settings", Icons.settings, onTap: () {
                if (onNavigate != null) {
                  onNavigate!(3); // Index 3 is the Settings tab
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminSettingsScreen()),
                  );
                }
              }),
              const SizedBox(height: 12),
              _managementLink(context, "App Notifications", Icons.notifications, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                );
              }),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(BuildContext context, String label, String count, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final subtextColor = isDark ? Colors.grey[400]! : const Color(0xff64748B);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: isDark ? const Color(0xff1A2A4A) : const Color(0xffEFF6FF),
              child: Icon(icon, color: const Color(0xff2B82F6), size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: subtextColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _managementLink(BuildContext context, String title, IconData icon, {required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xff1A2A4A) : const Color(0xffEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xff2B82F6), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xffCBD5E1)),
          ],
        ),
      ),
    );
  }
}

class PasswordResetAlertCard extends StatefulWidget {
  final QueryDocumentSnapshot doc;
  const PasswordResetAlertCard({super.key, required this.doc});

  @override
  State<PasswordResetAlertCard> createState() => _PasswordResetAlertCardState();
}

class _PasswordResetAlertCardState extends State<PasswordResetAlertCard> {
  bool _isProcessing = false;

  Future<void> _sendLink(String email, String docId) async {
    setState(() => _isProcessing = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      await FirebaseFirestore.instance
          .collection('password_reset_requests')
          .doc(docId)
          .update({'status': 'sent'});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Reset link successfully sent to $email"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to send link: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _dismissRequest(String docId) async {
    setState(() => _isProcessing = true);
    try {
      await FirebaseFirestore.instance
          .collection('password_reset_requests')
          .doc(docId)
          .update({'status': 'dismissed'});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Request dismissed"),
            backgroundColor: Colors.grey,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to dismiss: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.doc.data() as Map<String, dynamic>;
    final name = data['name'] ?? 'Unknown';
    final rawRole = data['role'] ?? 'patient';
    final role = rawRole.toString().toLowerCase() == 'doctor' ? 'Doctor' : 'Patient';
    final email = data['email'] ?? '';
    final docId = widget.doc.id;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Aesthetic orange palette matching Action Required
    final cardBg = isDark ? const Color(0xff2A1E17) : const Color(0xffFFF8F2);
    final borderCol = isDark ? const Color(0xff4B321D) : const Color(0xffFFE5D3);
    final titleColor = isDark ? Colors.orange[300]! : const Color(0xffD97706);
    final subtitleColor = isDark ? Colors.grey[300]! : const Color(0xff1E293B);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lock_reset,
                    color: titleColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Password Reset Requested",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: titleColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xff451A03) : const Color(0xffFFEDD5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "Action Required",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.orange[200] : const Color(0xffC2410C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "$role ($name) requested to change his password",
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: subtitleColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Email: $email",
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey[400]! : const Color(0xff64748B),
            ),
          ),
          const SizedBox(height: 14),
          _isProcessing
              ? const SizedBox(
                  height: 36,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    ),
                  ),
                )
              : Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffF97316),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      onPressed: () => _sendLink(email, docId),
                      child: const Text(
                        "Send Link",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? Colors.grey[400] : const Color(0xff64748B),
                        side: BorderSide(
                          color: isDark ? Colors.grey[800]! : const Color(0xffE2E8F0),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      onPressed: () => _dismissRequest(docId),
                      child: const Text(
                        "Dismiss",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
