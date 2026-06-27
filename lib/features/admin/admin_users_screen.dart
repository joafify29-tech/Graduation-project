import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:math';
import 'admin_user_details_screen.dart';
import 'admin_user_created_screen.dart';
import '../../core/auth_credentials.dart';

class UserItem {
  final String id;
  final Map<String, dynamic> data;
  UserItem({required this.id, required this.data});
}

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String searchQuery = "";
  String filterRole = "All Users";

  final List<String> filters = ["All Users", "Patients", "Doctors", "Pending"];

  late Stream<QuerySnapshot> _usersStream;
  late Stream<QuerySnapshot> _referralsStream;

  @override
  void initState() {
    super.initState();
    _refreshStreams();
  }

  void _refreshStreams() {
    _usersStream = FirebaseFirestore.instance.collection('users').snapshots();
    _referralsStream = FirebaseFirestore.instance.collection('referrals').snapshots();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _refreshStreams();
    });
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xff121212) : const Color(0xffF5F7F8);
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final subtextColor = isDark ? Colors.grey[400]! : const Color(0xff64748B);
    final borderCol = isDark ? Colors.grey[800]! : const Color(0xffE2E8F0);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          "User Management",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.blue, size: 28),
            onPressed: () => _showAddUserDialog(context),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (context, usersSnapshot) {
          return StreamBuilder<QuerySnapshot>(
            stream: _referralsStream,
            builder: (context, referralsSnapshot) {
              if (!usersSnapshot.hasData || !referralsSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final Map<String, Map<String, dynamic>> usersMap = {
                for (var doc in usersSnapshot.data!.docs) doc.id: doc.data() as Map<String, dynamic>
              };
              final Map<String, Map<String, dynamic>> referralsMap = {
                for (var doc in referralsSnapshot.data!.docs) doc.id: doc.data() as Map<String, dynamic>
              };

              final List<UserItem> allUsers = [];

              // First, add all doctors, admins, referrals from users collection
              usersMap.forEach((id, userData) {
                final role = (userData['role'] ?? "").toString().toLowerCase().trim();
                if (role != 'patient') {
                  allUsers.add(UserItem(id: id, data: userData));
                }
              });

              // Add patients ONLY if they exist in BOTH collections
              referralsMap.forEach((id, referralData) {
                if (usersMap.containsKey(id)) {
                  final mergedData = {
                    ...usersMap[id]!,
                    ...referralData,
                  };
                  allUsers.add(UserItem(id: id, data: mergedData));
                }
              });

              int allCount = allUsers.length;
              int patientCount = 0;
              int doctorCount = 0;
              int pendingCount = 0;

              for (var user in allUsers) {
                final data = user.data;
                final role = (data['role'] ?? "").toString().toLowerCase().trim();
                final status = (data['status'] ?? "").toString().toLowerCase().trim();
                
                if (role == 'patient') patientCount++;
                if (role == 'doctor') doctorCount++;
                if (status == 'pending') pendingCount++;
              }

              return Column(
                children: [
                  // SEARCH BAR
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          searchQuery = val.toLowerCase();
                        });
                      },
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: "Search users by name or ID",
                        hintStyle: TextStyle(color: subtextColor, fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: subtextColor),
                        suffixIcon: Icon(Icons.tune, color: subtextColor),
                        filled: true,
                        fillColor: cardBg,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderCol),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                  ),

                  // FILTER TABS
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filters.length,
                      itemBuilder: (context, index) {
                        final filter = filters[index];
                        final isSelected = filterRole == filter;
                        
                        String label = filter;
                        if (filter == "All Users") label = "All Users ($allCount)";
                        if (filter == "Patients") label = "Patients ($patientCount)";
                        if (filter == "Doctors") label = "Doctors ($doctorCount)";
                        if (filter == "Pending") label = "Pending ($pendingCount)";

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              filterRole = filter;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xff2B82F6) : cardBg,
                              border: isSelected ? null : Border.all(color: borderCol),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xff2B82F6).withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? Colors.white : subtextColor,
                                ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // USER LIST
                  Expanded(
                    child: Builder(
                      builder: (context) {

                        final docs = allUsers.where((user) {
                          final data = user.data;
                          final role = (data['role'] ?? "").toString().toLowerCase().trim();
                          final name = (data['name'] ?? "").toString().toLowerCase().trim();
                          final status = (data['status'] ?? "").toString().toLowerCase().trim();

                          // Role Filter
                          if (filterRole == "Patients" && role != "patient") return false;
                          if (filterRole == "Doctors" && role != "doctor") return false;
                          if (filterRole == "Pending" && status != "pending") return false;

                          // Search Query
                          if (searchQuery.isNotEmpty && !name.contains(searchQuery)) return false;

                          return true;
                        }).toList();

                        if (docs.isEmpty) {
                          return RefreshIndicator(
                            onRefresh: _handleRefresh,
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                                Center(
                                  child: Text("No users found", style: TextStyle(color: subtextColor)),
                                ),
                              ],
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: _handleRefresh,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final user = docs[index];
                              return _userCard(context, user.id, user.data);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _userCard(BuildContext context, String id, Map<String, dynamic> data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final subtextColor = isDark ? Colors.grey[400]! : const Color(0xff64748B);
    final borderCol = isDark ? Colors.grey[800]! : const Color(0xffF1F5F9);
    final avatarBg = isDark ? const Color(0xff1A2A4A) : const Color(0xffEFF6FF);
    final avatarTextCol = isDark ? Colors.blue[300]! : Colors.blue;
    final infoTextColor = isDark ? Colors.grey[500]! : const Color(0xff94A3B8);

    final name = data['name'] ?? "Unknown";
    final role = data['role'] ?? "Patient";
    
    // We mock "Active" or "Suspended" status if it doesn't exist.
    final status = data['status'] ?? "Active"; 
    final isSuspended = status.toString().toLowerCase() == "suspended";

    final shortId = id.length > 4 ? id.substring(id.length - 4) : id;

    final statusBg = isSuspended
        ? (isDark ? const Color(0xff450a0a) : const Color(0xffFEF2F2))
        : (isDark ? const Color(0xff062f17) : const Color(0xffF0FDF4));
    final statusTextCol = isSuspended
        ? (isDark ? const Color(0xffF87171) : const Color(0xffB91C1C))
        : (isDark ? const Color(0xff4ADE80) : const Color(0xff15803D));

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminUserDetailsScreen(userId: id, userData: data),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderCol),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: avatarBg,
                  child: Text(
                    name.toString().isNotEmpty ? name[0].toUpperCase() : "?",
                    style: TextStyle(color: avatarTextCol, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: isSuspended ? const Color(0xffEF4444) : const Color(0xff22C55E),
                      shape: BoxShape.circle,
                      border: Border.all(color: cardBg, width: 2),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      if (role.toString().toLowerCase() == 'doctor') ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.verified, color: Colors.blue, size: 14),
                      ]
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${role[0].toUpperCase()}${role.substring(1)} • ID: #$shortId",
                    style: TextStyle(
                      fontSize: 14,
                      color: subtextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusTextCol,
                          ),
                        ),
                      ),
                      if (isSuspended) ...[
                        const SizedBox(width: 8),
                        Text(
                          "• Non-compliance",
                          style: TextStyle(fontSize: 12, color: infoTextColor),
                        )
                      ] else ...[
                        const SizedBox(width: 8),
                        Text(
                          "• Last visit: 2d ago", // Mocked
                          style: TextStyle(fontSize: 12, color: infoTextColor),
                        )
                      ]
                    ],
                  )
                ],
              ),
            ),
            Icon(Icons.more_horiz, color: infoTextColor),
          ],
        ),
      ),
    );
  }

  String _generatePassword() {
    const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    Random rand = Random();
    return List.generate(10, (index) {
      return chars[rand.nextInt(chars.length)];
    }).join();
  }

  Future<String> _generateEmail(String name) async {
    String base = name.toLowerCase().replaceAll(" ", "");
    String email = "$base@app.com";
    int counter = 1;

    while (true) {
      var query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (query.docs.isEmpty) {
        return email;
      } else {
        email = "$base$counter@app.com";
        counter++;
      }
    }
  }

  void _showAddUserDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController ageController = TextEditingController();
    String selectedRole = 'Doctor';
    bool isLoading = false;
    final Set<String> selectedPatientIds = {};

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final fieldBg = isDark ? const Color(0xff2A2A2A) : Colors.grey.shade100;
    final labelColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: dialogBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text("Add New User", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      enabled: !isLoading,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: "Name",
                        labelStyle: TextStyle(color: labelColor),
                        filled: true,
                        fillColor: fieldBg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: ageController,
                      enabled: !isLoading,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: "Age",
                        labelStyle: TextStyle(color: labelColor),
                        filled: true,
                        fillColor: fieldBg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      dropdownColor: dialogBg,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: "Role",
                        labelStyle: TextStyle(color: labelColor),
                        filled: true,
                        fillColor: fieldBg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      items: ['Doctor', 'Admin', 'Referral']
                          .map((role) => DropdownMenuItem(
                                value: role,
                                child: Text(role, style: TextStyle(color: textColor)),
                              ))
                          .toList(),
                      onChanged: isLoading
                          ? null
                          : (val) {
                              if (val != null) {
                                setDialogState(() => selectedRole = val);
                              }
                            },
                    ),
                    if (selectedRole == 'Doctor') ...[
                      const SizedBox(height: 16),
                      Text(
                        "Assign Patients",
                        style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance.collection('referrals').get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          if (snapshot.hasError) {
                            return Text("Error loading patients", style: TextStyle(color: Colors.red));
                          }
                          final docs = snapshot.data?.docs ?? [];
                          if (docs.isEmpty) {
                            return Text("No patients available", style: TextStyle(color: labelColor));
                          }
                          return Container(
                            height: 150,
                            decoration: BoxDecoration(
                              color: fieldBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                final doc = docs[index];
                                final patientData = doc.data() as Map<String, dynamic>;
                                final patientId = doc.id;
                                final patientName = patientData['name'] ?? 'Unknown';
                                final currentDoctor = patientData['doctorName'] ?? 'None';
                                final isChecked = selectedPatientIds.contains(patientId);

                                return CheckboxListTile(
                                  title: Text(patientName, style: TextStyle(color: textColor, fontSize: 14)),
                                  subtitle: Text("Assigned Doctor: $currentDoctor", style: TextStyle(color: labelColor, fontSize: 11)),
                                  value: isChecked,
                                  activeColor: const Color(0xff2B82F6),
                                  onChanged: (bool? val) {
                                    setDialogState(() {
                                      if (val == true) {
                                        selectedPatientIds.add(patientId);
                                      } else {
                                        selectedPatientIds.remove(patientId);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2B82F6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (nameController.text.trim().isEmpty) return;

                          setDialogState(() => isLoading = true);

                          try {
                            final name = nameController.text.trim();
                            final age = ageController.text.trim();
                            final role = selectedRole.toLowerCase().trim();

                            final email = await _generateEmail(name);
                            final password = _generatePassword();

                            final secondaryApp = await Firebase.initializeApp(
                              name: 'adminUserCreator',
                              options: Firebase.app().options,
                            );

                            final secondaryAuth = FirebaseAuth.instanceFor(
                              app: secondaryApp,
                            );

                            UserCredential userCredential =
                                await secondaryAuth.createUserWithEmailAndPassword(
                              email: email,
                              password: password,
                            );

                            String uid = userCredential.user!.uid;

                            final userData = {
                              'name': name,
                              'age': age,
                              'role': role,
                              'status': 'Active',
                              'email': email,
                              'tempPassword': password,
                              'createdAt': FieldValue.serverTimestamp(),
                            };

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .set(userData);

                            if (role == 'doctor' && selectedPatientIds.isNotEmpty) {
                              for (var pId in selectedPatientIds) {
                                await FirebaseFirestore.instance
                                    .collection('referrals')
                                    .doc(pId)
                                    .update({
                                  'doctorId': uid,
                                  'doctorName': name,
                                });

                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(pId)
                                    .update({
                                  'doctorId': uid,
                                  'doctorName': name,
                                });
                              }
                            }

                            await secondaryAuth.signOut();
                            await secondaryApp.delete();

                            // Restore admin user session to default FirebaseAuth instance only if signed out
                             final currentUser = FirebaseAuth.instance.currentUser;
                             if (currentUser == null || currentUser.email != AuthCredentials.email) {
                               if (AuthCredentials.email != null && AuthCredentials.password != null) {
                                 await FirebaseAuth.instance.signInWithEmailAndPassword(
                                   email: AuthCredentials.email!,
                                   password: AuthCredentials.password!,
                                 );
                               }
                             }

                            if (context.mounted) {
                              Navigator.pop(context); // Close dialog
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AdminUserCreatedScreen(
                                    name: name,
                                    email: email,
                                    password: password,
                                    role: role,
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              setDialogState(() => isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: ${e.toString()}")),
                              );
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text("Add User", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
