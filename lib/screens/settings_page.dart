import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isNotificationsEnabled = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadParentData();
    _loadNotificationPreference();
  }

  Future<void> _loadParentData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final uid = user.uid;
      final ref = FirebaseDatabase.instance.ref('parents/$uid');
      final snapshot = await ref.get();

      _emailController.text = user.email ?? '';

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        _nameController.text = data['fullName'] ?? '';
      }
    }
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isNotificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _saveNotificationPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
  }

  Future<void> _onSave() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final uid = user.uid;

      if (_nameController.text.trim().isNotEmpty) {
        await user.updateDisplayName(_nameController.text.trim());
      }

      if (_emailController.text.trim().isNotEmpty &&
          _emailController.text.trim() != user.email) {
        // ignore: deprecated_member_use
        await user.updateEmail(_emailController.text.trim());
      }

      final newPassword = _passwordController.text.trim();
      if (newPassword.isNotEmpty) {
        if (newPassword.length < 6) {
          _showErrorDialog("Password must be at least 6 characters.");
          setState(() => _isLoading = false);
          return;
        }

        final passwordRegex =
            RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).+$');
        if (!passwordRegex.hasMatch(newPassword)) {
          _showErrorDialog(
              "Password must include: A, a, 0-9, and a symbol like !@#%");
          setState(() => _isLoading = false);
          return;
        }

        await user.updatePassword(newPassword);
      }

      await FirebaseDatabase.instance.ref('parents/$uid').update({
        'fullName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
      });

      await _saveNotificationPreference(_isNotificationsEnabled);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings updated successfully')),
      );
    } catch (e) {
      _showErrorDialog("Error: ${e.toString()}");
    }

    setState(() => _isLoading = false);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
    TextInputType type = TextInputType.text,
    String? helper,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: type,
      style: GoogleFonts.poppins(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        labelStyle: GoogleFonts.poppins(color: Colors.white),
        filled: true,
        // ignore: deprecated_member_use
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8EA7B5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8EA7B5),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Parent Settings",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            _buildTextField("Full Name", _nameController),
            const SizedBox(height: 16),
            _buildTextField("Email", _emailController,
                type: TextInputType.emailAddress),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              style: GoogleFonts.poppins(color: Colors.black),
              decoration: InputDecoration(
                labelText: "Password",
                helperText: 'Leave blank if no change',
                labelStyle: GoogleFonts.poppins(color: Colors.white),
                filled: true,
                // ignore: deprecated_member_use
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: Text(
                'Enable Notifications',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              value: _isNotificationsEnabled,
              onChanged: (val) {
                setState(() => _isNotificationsEnabled = val);
                _saveNotificationPreference(val);
              },
              activeColor: Colors.white,
              // ignore: deprecated_member_use
              tileColor: Colors.white.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Color(0xFF8EA7B5))
                  : Text(
                      'Save Settings',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF8EA7B5),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Logout"),
                    content: const Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          await FirebaseAuth.instance.signOut();
                          if (!context.mounted) return;
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login', (route) => false);
                        },
                        child: const Text("Logout"),
                      ),
                    ],
                  ),
                );
              },
              child: Text(
                "Logout",
                style: GoogleFonts.poppins(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
