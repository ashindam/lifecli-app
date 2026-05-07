import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lifecli_app/core/constants/app_colors.dart';
import 'package:lifecli_app/core/data/university_data.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedUniversity;
  String? _selectedBloodGroup;
  bool _obscurePassword = true;

  static const List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  void _onSignUp() {
    // Validate all fields
    if (_firstNameController.text.trim().isEmpty) {
      _showError('Please enter your first name.');
      return;
    }
    if (_lastNameController.text.trim().isEmpty) {
      _showError('Please enter your last name.');
      return;
    }
    if (_selectedUniversity == null) {
      _showError('Please select your university.');
      return;
    }
    if (_studentIdController.text.trim().isEmpty) {
      _showError('Please enter your student ID.');
      return;
    }
    if (_selectedBloodGroup == null) {
      _showError('Please select your blood group.');
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      _showError('Please enter your email.');
      return;
    }
    if (!_isValidEmail(_emailController.text.trim())) {
      _showError('Please enter a valid email address.');
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showError('Please enter a password.');
      return;
    }
    if (_passwordController.text.length < 8) {
      _showError('Password must be at least 8 characters.');
      return;
    }

    final data = <String, dynamic>{
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'university': _selectedUniversity!,
      'student_id': _studentIdController.text.trim(),
      'blood_group': _selectedBloodGroup!,
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
    };

    context.push('/signup/photo', extra: data);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(fontSize: 14)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openUniversityPicker() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _UniversityPickerSheet(
        selected: _selectedUniversity,
        onSelected: (name) {
          setState(() => _selectedUniversity = name);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF0F172A)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Create Account',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE2E8F0)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // First Name
              _FieldLabel(label: 'First name'),
              const SizedBox(height: 6),
              TextField(
                controller: _firstNameController,
                style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF0F172A)),
                decoration: _inputDecoration(hint: 'Enter your first name'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Last Name
              _FieldLabel(label: 'Last name'),
              const SizedBox(height: 6),
              TextField(
                controller: _lastNameController,
                style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF0F172A)),
                decoration: _inputDecoration(hint: 'Enter your last name'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // University
              _FieldLabel(label: 'University'),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _openUniversityPicker,
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedUniversity ?? 'Select your university',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: _selectedUniversity != null
                                ? const Color(0xFF0F172A)
                                : const Color(0xFF94A3B8),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF94A3B8), size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Student ID
              _FieldLabel(label: 'Student ID'),
              const SizedBox(height: 6),
              TextField(
                controller: _studentIdController,
                style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF0F172A)),
                decoration: _inputDecoration(hint: 'Enter your student ID'),
                keyboardType: TextInputType.visiblePassword,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]'))],
              ),
              const SizedBox(height: 16),

              // Blood Group
              _FieldLabel(label: 'Blood Group'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _bloodGroups.map((group) {
                  final isSelected = _selectedBloodGroup == group;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedBloodGroup = group),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        group,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Email
              _FieldLabel(label: 'Email (Gmail)'),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF0F172A)),
                decoration: _inputDecoration(hint: 'you@gmail.com'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Password
              _FieldLabel(label: 'Password'),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF0F172A)),
                decoration: _inputDecoration(hint: '••••••••').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                      color: const Color(0xFF94A3B8),
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'At least 8 characters',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 32),

              // Sign Up button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _onSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Sign Up',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF94A3B8)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}

// ─── Field Label ───────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF0F172A),
      ),
    );
  }
}

// ─── University Picker Bottom Sheet ────────────────────────────────────────

class _UniversityPickerSheet extends StatefulWidget {
  const _UniversityPickerSheet({
    required this.selected,
    required this.onSelected,
  });

  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  State<_UniversityPickerSheet> createState() => _UniversityPickerSheetState();
}

class _UniversityPickerSheetState extends State<_UniversityPickerSheet> {
  final _searchController = TextEditingController();
  List<BdUniversity> _filtered = bangladeshiUniversities;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _filtered = bangladeshiUniversities
          .where((u) => u.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Select University',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearch,
                style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF0F172A)),
                decoration: InputDecoration(
                  hintText: 'Search universities...',
                  hintStyle: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                itemBuilder: (_, i) {
                  final uni = _filtered[i];
                  final isSelected = widget.selected == uni.name;
                  return ListTile(
                    onTap: () => widget.onSelected(uni.name),
                    title: Text(
                      uni.name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? AppColors.primary : const Color(0xFF0F172A),
                      ),
                    ),
                    subtitle: Text(
                      '${uni.type} · ${uni.location}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded,
                            color: AppColors.primary, size: 20)
                        : null,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
