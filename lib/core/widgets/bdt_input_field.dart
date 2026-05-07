import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class BdtInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  const BdtInputField({
    super.key,
    required this.controller,
    this.label,
    this.hint = '0',
    this.validator,
    this.onChanged,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      validator: validator,
      onChanged: onChanged,
      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: '৳ ',
        prefixStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.bdtColor,
        ),
      ),
    );
  }
}
