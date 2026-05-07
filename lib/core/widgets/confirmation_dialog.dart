import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final bool isDanger;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    required this.onConfirm,
    this.isDanger = false,
  });

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Delete',
    bool isDanger = true,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        isDanger: isDanger,
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      content: Text(message, style: GoogleFonts.inter(fontSize: 14)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop(true);
          },
          style: isDanger
              ? FilledButton.styleFrom(backgroundColor: AppColors.error)
              : null,
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
