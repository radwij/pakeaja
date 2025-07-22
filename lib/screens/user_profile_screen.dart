import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // --- Core logic and state management remain unchanged ---
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isEditing = false;
  bool _isLoading = false;
  String? _lastUserId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel;
    if (user == null && authProvider.firebaseUser != null) {
      authProvider.fetchUserProfile();
    } else if (user != null && user.id != _lastUserId) {
      _lastUserId = user.id;
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber;
      _addressController.text = user.address;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.updateUserProfile(
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );
    setState(() {
      _isLoading = false;
      _isEditing = false;
    });
    if (result != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  // --- Helper method for consistent input styling from your reference theme ---
  InputDecoration _inputDecoration(String label, IconData icon) {
    const primaryColor = Color(0xFF0B57D0);
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryColor),
      labelStyle: const TextStyle(color: primaryColor),
      floatingLabelStyle: const TextStyle(
        color: primaryColor,
        fontWeight: FontWeight.bold,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      // Add error and focusedError borders for a complete look
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade700, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade700, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).userModel;

    // Loading state
    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6F8FC),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0B57D0)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0B57D0)),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Color(0xFF0B57D0),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          // Show Edit button only when not editing
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit Profile',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Profile Header ---
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0x1F0B57D0), // Lighter background
                  child: Icon(Icons.person, size: 60, color: Color(0xFF0B57D0)),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    user.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    user.email,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),

                // --- Form Fields ---
                TextFormField(
                  controller: _nameController,
                  readOnly: !_isEditing,
                  decoration: _inputDecoration(
                    'Full Name',
                    Icons.person_outline,
                  ),
                  validator:
                      (value) => value!.isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  readOnly: true, // Email is never editable
                  decoration: _inputDecoration('Email', Icons.email_outlined),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  readOnly: !_isEditing,
                  decoration: _inputDecoration(
                    'Phone Number',
                    Icons.phone_outlined,
                  ),
                  keyboardType: TextInputType.phone,
                  validator:
                      (value) => value!.isEmpty ? 'Enter phone number' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  readOnly: !_isEditing,
                  decoration: _inputDecoration(
                    'Address',
                    Icons.location_on_outlined,
                  ),
                  validator: (value) => value!.isEmpty ? 'Enter address' : null,
                ),
                const SizedBox(height: 30),

                // --- Action Buttons / Loader ---
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0B57D0)),
                  )
                else if (_isEditing)
                  _buildEditingButtons(user),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper widget for Save/Cancel buttons to keep build method clean ---
  Widget _buildEditingButtons(dynamic user) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B57D0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _isEditing = false;
                // Reset fields to original data
                _nameController.text = user.name;
                _phoneController.text = user.phoneNumber;
                _addressController.text = user.address;
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0B57D0),
              side: const BorderSide(color: Color(0xFF0B57D0), width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
