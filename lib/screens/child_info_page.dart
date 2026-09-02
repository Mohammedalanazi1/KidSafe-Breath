import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

class ChildInfoPage extends StatefulWidget {
  const ChildInfoPage({super.key});

  @override
  State<ChildInfoPage> createState() => _ChildInfoPageState();
}

class _ChildInfoPageState extends State<ChildInfoPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String? _selectedGender;
  bool _isEditMode = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChildData();
  }

  Future<void> _loadChildData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final ref = FirebaseDatabase.instance.ref('parents/$uid/child');
    final snapshot = await ref.get();

    if (!mounted || !snapshot.exists) return;

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    setState(() {
      _nameController.text = data['fullName'] ?? '';
      _ageController.text = data['age']?.toString() ?? '';
      _heightController.text = data['height']?.toString() ?? '';
      _weightController.text = data['weight']?.toString() ?? '';
      _selectedGender = data['gender'] ?? '';
    });
  }

  Future<void> _saveData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseDatabase.instance.ref('parents/$uid/child').update({
        'fullName': _nameController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()) ?? 0,
        'height': double.tryParse(_heightController.text.trim()) ?? 0.0,
        'weight': double.tryParse(_weightController.text.trim()) ?? 0.0,
        'gender': _selectedGender ?? '',
      });

      if (!mounted) return;

      setState(() => _isEditMode = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Child info updated successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }

    setState(() => _isLoading = false);
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: type,
      enabled: _isEditMode,
      style: GoogleFonts.poppins(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.black),
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: "Gender",
        labelStyle: GoogleFonts.poppins(color: Colors.black),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: const [
        DropdownMenuItem(value: "Male", child: Text("Male")),
        DropdownMenuItem(value: "Female", child: Text("Female")),
      ],
      onChanged: _isEditMode ? (val) => setState(() => _selectedGender = val) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8EA7B5),
      appBar: AppBar(
        title: Text("Child Info", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF8EA7B5),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.save : Icons.edit),
            onPressed: _isLoading
                ? null
                : () {
                    if (_isEditMode) {
                      _saveData();
                    } else {
                      setState(() => _isEditMode = true);
                    }
                  },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            _buildTextField("Full Name", _nameController),
            const SizedBox(height: 16),
            _buildTextField("Age", _ageController, type: TextInputType.number),
            const SizedBox(height: 16),
            _buildTextField("Height (cm)", _heightController, type: TextInputType.number),
            const SizedBox(height: 16),
            _buildTextField("Weight (kg)", _weightController, type: TextInputType.number),
            const SizedBox(height: 16),
            _buildGenderDropdown(),
            const SizedBox(height: 30),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
