import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _isLoading = true;
  bool _isSending = false;
  String _name = "User";
  String _role = "patient";
  String _email = "";
  String? _uid;

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisibleCurrent = false;
  bool _isPasswordVisibleNew = false;
  bool _isPasswordVisibleConfirm = false;
  bool _isChanging = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _uid = user.uid;
        _email = user.email ?? "";

        // First attempt: read from 'users' collection
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _name = data['name'] ?? "User";
            _role = (data['role'] ?? "patient").toString().toLowerCase();
            if (data['email'] != null && data['email'].toString().isNotEmpty) {
              _email = data['email'];
            }
            _isLoading = false;
          });
          return;
        }

        // Second attempt: fallback/read from 'referrals' collection
        final referralDoc = await FirebaseFirestore.instance
            .collection('referrals')
            .doc(user.uid)
            .get();

        if (referralDoc.exists) {
          final data = referralDoc.data() as Map<String, dynamic>;
          setState(() {
            _name = data['name'] ?? "User";
            _role = (data['role'] ?? "patient").toString().toLowerCase();
            if (data['email'] != null && data['email'].toString().isNotEmpty) {
              _email = data['email'];
            }
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint("Error loading user info: $e");
    }
    setState(() => _isLoading = false);
  }

  Future<void> _sendResetRequest() async {
    if (_uid == null) return;
    setState(() => _isSending = true);

    try {
      // Check if there is already a pending request
      final existing = await FirebaseFirestore.instance
          .collection('password_reset_requests')
          .where('uid', isEqualTo: _uid)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existing.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("A pending request already exists."),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() => _isSending = false);
        return;
      }

      await FirebaseFirestore.instance.collection('password_reset_requests').add({
        'uid': _uid,
        'name': _name,
        'role': _role,
        'email': _email,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password reset request sent successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _deleteRequest(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('password_reset_requests')
          .doc(docId)
          .delete();
    } catch (e) {
      debugPrint("Error deleting request: $e");
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePasswordDirectly() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("All fields are required."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("New passwords do not match."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must be at least 6 characters."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isChanging = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        // Reauthenticate
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        
        await user.reauthenticateWithCredential(credential);
        
        // Update password
        await user.updatePassword(newPassword);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Password changed successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        String errMsg = e.toString();
        if (errMsg.contains("wrong-password") || errMsg.contains("invalid-credential")) {
          errMsg = "Incorrect current password.";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errMsg),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isChanging = false);
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: onToggleVisibility,
          ),
        ),
      ),
    }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xff121212) : const Color(0xffF7F8FA);
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          "Change Password",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xff2F6FED)))
          : _role == 'admin'
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        "Change Admin Password",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Enter your current password and your new password to update it directly.",
                        style: TextStyle(color: subtextColor, fontSize: 14),
                      ),
                      const SizedBox(height: 30),
                      _buildTextField(
                        controller: _currentPasswordController,
                        label: "Current Password",
                        isVisible: _isPasswordVisibleCurrent,
                        onToggleVisibility: () => setState(() => _isPasswordVisibleCurrent = !_isPasswordVisibleCurrent),
                      ),
                      _buildTextField(
                        controller: _newPasswordController,
                        label: "New Password",
                        isVisible: _isPasswordVisibleNew,
                        onToggleVisibility: () => setState(() => _isPasswordVisibleNew = !_isPasswordVisibleNew),
                      ),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: "Confirm New Password",
                        isVisible: _isPasswordVisibleConfirm,
                        onToggleVisibility: () => setState(() => _isPasswordVisibleConfirm = !_isPasswordVisibleConfirm),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff2F6FED),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _isChanging ? null : _changePasswordDirectly,
                          child: _isChanging
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Update Password",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                )
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('password_reset_requests')
                      .where('uid', isEqualTo: _uid)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xff2F6FED)));
                }

                DocumentSnapshot? latestRequest;
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  final docs = snapshot.data!.docs;
                  // Sort in memory by timestamp desc to get the latest
                  docs.sort((a, b) {
                    final aTime = (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
                    final bTime = (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
                    if (aTime == null) return 1;
                    if (bTime == null) return -1;
                    return bTime.compareTo(aTime);
                  });
                  latestRequest = docs.first;
                }

                final requestData = latestRequest?.data() as Map<String, dynamic>?;
                final status = requestData?['status'] ?? 'none';
                final docId = latestRequest?.id;

                if (status == 'pending') {
                  return _buildStatusView(
                    context: context,
                    icon: Icons.hourglass_empty,
                    iconColor: Colors.orange,
                    title: "Reset Request Sent",
                    subtitle: "Your password reset request is pending review by the system administrator.\n\nWe will notify you here once the administrator sends a secure link to your email address:\n$_email",
                    buttonText: "Awaiting Approval...",
                    onButtonPressed: null,
                  );
                } else if (status == 'sent') {
                  return _buildStatusView(
                    context: context,
                    icon: Icons.check_circle_outline,
                    iconColor: Colors.green,
                    title: "Reset Link Sent!",
                    subtitle: "The administrator has approved your request and sent a password reset link to your email address:\n\n$_email\n\nPlease check your inbox and spam folder to proceed.",
                    buttonText: "Close Screen",
                    onButtonPressed: () => Navigator.pop(context),
                    extraWidget: TextButton(
                      onPressed: () {
                        if (docId != null) {
                          _deleteRequest(docId);
                        }
                      },
                      child: const Text("Need to send another request?"),
                    ),
                  );
                } else if (status == 'dismissed') {
                  return _buildStatusView(
                    context: context,
                    icon: Icons.warning_amber_rounded,
                    iconColor: Colors.red,
                    title: "Request Dismissed",
                    subtitle: "Your password reset request was dismissed by the administrator.\n\nIf you still need to change your password, you can submit a new request.",
                    buttonText: "Submit New Request",
                    onButtonPressed: () {
                      if (docId != null) {
                        _deleteRequest(docId);
                      }
                      _sendResetRequest();
                    },
                  );
                }

                // Default view (no request sent yet)
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          color: Color(0xffEEF4FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          size: 55,
                          color: Color(0xff2F6FED),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        "Request Password Reset",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "To change your password, send a request to the system administrator. They will review it and send a secure reset link to your registered email address:\n\n$_email",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: subtextColor,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff2F6FED),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _isSending ? null : _sendResetRequest,
                          child: _isSending
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Send Password Reset Request",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatusView({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback? onButtonPressed,
    Widget? extraWidget,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 55,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: subtextColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          if (onButtonPressed != null)
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                onPressed: onButtonPressed,
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 55,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(25),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.withAlpha(50)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
            ),
          if (extraWidget != null) ...[
            const SizedBox(height: 20),
            extraWidget,
          ],
        ],
      ),
    );
  }
}
