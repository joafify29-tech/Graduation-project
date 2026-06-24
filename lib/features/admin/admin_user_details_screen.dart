import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUserDetailsScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const AdminUserDetailsScreen({super.key, required this.userId, required this.userData});

  @override
  State<AdminUserDetailsScreen> createState() => _AdminUserDetailsScreenState();
}

class _AdminUserDetailsScreenState extends State<AdminUserDetailsScreen> {
  void _showAssignPatientsDialog(BuildContext context, List<QueryDocumentSnapshot> currentlyAssigned) {
    final currentlyAssignedIds = currentlyAssigned.map((doc) => doc.id).toSet();
    final Set<String> selectedIds = Set.from(currentlyAssignedIds);
    bool isSaving = false;

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
              title: Text("Assign Patients", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                          height: 250,
                          width: double.maxFinite,
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
                              final isChecked = selectedIds.contains(patientId);

                              return CheckboxListTile(
                                title: Text(patientName, style: TextStyle(color: textColor, fontSize: 14)),
                                subtitle: Text("Doctor: $currentDoctor", style: TextStyle(color: labelColor, fontSize: 11)),
                                value: isChecked,
                                activeColor: const Color(0xff2B82F6),
                                onChanged: isSaving
                                    ? null
                                    : (bool? val) {
                                        setDialogState(() {
                                          if (val == true) {
                                            selectedIds.add(patientId);
                                          } else {
                                            selectedIds.remove(patientId);
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
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2B82F6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          setDialogState(() => isSaving = true);
                          try {
                            // Find all patients to assign
                            final toAssign = selectedIds.difference(currentlyAssignedIds);
                            // Find all patients to unassign
                            final toUnassign = currentlyAssignedIds.difference(selectedIds);

                            for (var pId in toAssign) {
                              await FirebaseFirestore.instance
                                  .collection('referrals')
                                  .doc(pId)
                                  .update({
                                'doctorId': widget.userId,
                                'doctorName': widget.userData['name'],
                              });
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(pId)
                                  .update({
                                'doctorId': widget.userId,
                                'doctorName': widget.userData['name'],
                              });
                            }

                            for (var pId in toUnassign) {
                              await FirebaseFirestore.instance
                                  .collection('referrals')
                                  .doc(pId)
                                  .update({
                                'doctorId': null,
                                'doctorName': null,
                              });
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(pId)
                                  .update({
                                'doctorId': null,
                                'doctorName': null,
                              });
                            }

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Patient assignments updated successfully"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              setDialogState(() => isSaving = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: ${e.toString()}")),
                              );
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text("Save", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.userData['name'] ?? "Unknown";
    final role = widget.userData['role'] ?? "Patient";
    final email = widget.userData['email'] ?? "N/A";
    final phone = widget.userData['phone'] ?? "N/A";
    
    final status = widget.userData['status'] ?? "Active";
    final isSuspended = status.toString().toLowerCase() == "suspended";
    final shortId = widget.userId.length > 4 ? widget.userId.substring(widget.userId.length - 4) : widget.userId;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xff121212) : const Color(0xffF8FAFC);
    final cardBg = isDark ? const Color(0xff1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final subtextColor = isDark ? Colors.grey[400]! : const Color(0xff64748B);
    final borderCol = isDark ? Colors.grey[800]! : const Color(0xffF1F5F9);
    final avatarBg = isDark ? const Color(0xff1A2A4A) : const Color(0xffEFF6FF);
    final avatarTextCol = isDark ? Colors.blue[300]! : Colors.blue;

    final statusBg = isSuspended
        ? (isDark ? const Color(0xff450a0a) : const Color(0xffFEF2F2))
        : (isDark ? const Color(0xff062f17) : const Color(0xffF0FDF4));
    final statusTextCol = isSuspended
        ? (isDark ? const Color(0xffF87171) : const Color(0xffB91C1C))
        : (isDark ? const Color(0xff4ADE80) : const Color(0xff15803D));

    final deleteBg = isDark ? const Color(0xff450a0a) : const Color(0xffFEF2F2);
    final deleteTextCol = isDark ? const Color(0xffF87171) : const Color(0xffEF4444);

    final isDoctorRole = role.toString().toLowerCase() == 'doctor';

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "User Details",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // USER HEADER
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              ),
              child: Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: avatarBg,
                          child: Text(
                            name.toString().isNotEmpty ? name[0].toUpperCase() : "?",
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: avatarTextCol),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: isSuspended ? const Color(0xffEF4444) : const Color(0xff22C55E),
                              shape: BoxShape.circle,
                              border: Border.all(color: cardBg, width: 3),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${role[0].toUpperCase()}${role.substring(1)} • ID: #$shortId",
                      style: TextStyle(fontSize: 14, color: subtextColor),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20),
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
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // SYSTEM INFORMATION
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "SYSTEM INFORMATION",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subtextColor, letterSpacing: 1.0),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _infoRow(context, "Email", email),
                  Divider(color: borderCol, height: 30),
                  _infoRow(context, "Phone", phone),
                  Divider(color: borderCol, height: 30),
                  _infoRow(
                    context,
                    "Registered",
                    widget.userData['createdAt'] is Timestamp
                        ? "${[
                            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                          ][(widget.userData['createdAt'] as Timestamp).toDate().month - 1]} ${(widget.userData['createdAt'] as Timestamp).toDate().day}, ${(widget.userData['createdAt'] as Timestamp).toDate().year}"
                        : (widget.userData['createdAt']?.toString() ?? "N/A"),
                  ),
                  Divider(color: borderCol, height: 30),
                  _infoRow(context, "Last Login", "Today, 09:41 AM\nIP: 192.168.1.42", isMultiLine: true),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ROLE & ACCESS
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "ROLE & ACCESS",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subtextColor, letterSpacing: 1.0),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _accessRow(context, "System Role", "${role[0].toUpperCase()}${role.substring(1)}"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ASSIGNED PATIENTS SECTION (DOCTORS ONLY)
            if (isDoctorRole)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('referrals')
                    .where('doctorId', isEqualTo: widget.userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox();
                  }
                  final patients = snapshot.data!.docs;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "ASSIGNED PATIENTS (${patients.length})",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subtextColor, letterSpacing: 1.0),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            if (patients.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Text("No patients assigned to this doctor.", style: TextStyle(color: subtextColor, fontSize: 14)),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: patients.length,
                                separatorBuilder: (context, index) => Divider(color: borderCol, height: 20),
                                itemBuilder: (context, index) {
                                  final patientData = patients[index].data() as Map<String, dynamic>;
                                  final patientName = patientData['name'] ?? 'Unknown';
                                  final patientStatus = patientData['status'] ?? 'ACTIVE';
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(patientName, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 14)),
                                      Text(patientStatus, style: TextStyle(color: patientStatus == 'HIGH' ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                                    ],
                                  );
                                },
                              ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff2B82F6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () => _showAssignPatientsDialog(context, patients),
                                child: const Text("Manage Patient Assignments", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),

            // ACTIONS
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {},
                icon: const Icon(Icons.refresh, color: Colors.blue),
                label: const Text(
                  "Send New Password Link",
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            GestureDetector(
              onTap: () {},
              child: Text(
                "Suspend User Account",
                style: TextStyle(color: deleteTextCol, fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
            
            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: deleteBg,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Delete User"),
                      content: const Text("Are you sure you want to delete this user and all their data? This action cannot be undone."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            
                            try {
                              await FirebaseFirestore.instance.collection('users').doc(widget.userId).delete();
                              await FirebaseFirestore.instance.collection('referrals').doc(widget.userId).delete();
                              
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("User deleted successfully"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Error deleting user: $e"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text("Delete", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(Icons.delete_outline, color: deleteTextCol),
                label: Text(
                  "Delete User & Data",
                  style: TextStyle(color: deleteTextCol, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value, {bool isMultiLine = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final subtextColor = isDark ? Colors.grey[400]! : const Color(0xff64748B);

    return Row(
      crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: subtextColor),
        ),
        Text(
          value,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _accessRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final subtextColor = isDark ? Colors.grey[400]! : const Color(0xff64748B);
    final arrowColor = isDark ? Colors.grey[600]! : const Color(0xffCBD5E1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: subtextColor),
        ),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 12, color: arrowColor),
          ],
        )
      ],
    );
  }
}
