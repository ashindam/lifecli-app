import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  final String label;
  final Color color;
  final String? emoji;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final bool isSelected;
  final bool compact;

  const TagChip({
    super.key,
    required this.label,
    required this.color,
    this.emoji,
    this.onTap,
    this.onDismiss,
    this.isSelected = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? color.withOpacity(0.18) : color.withOpacity(0.10);
    final border = isSelected ? color.withOpacity(0.5) : color.withOpacity(0.2);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 8,
          vertical: compact ? 2 : 4,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: TextStyle(fontSize: compact ? 10 : 12)),
              const SizedBox(width: 3),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: compact ? 10 : 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            if (onDismiss != null) ...[
              const SizedBox(width: 3),
              GestureDetector(
                onTap: onDismiss,
                child: Icon(Icons.close, size: compact ? 10 : 12, color: color),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
