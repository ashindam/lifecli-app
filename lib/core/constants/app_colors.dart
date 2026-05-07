import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary — Deep Indigo
  static const Color primary = Color(0xFF3730A3);
  static const Color primaryLight = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF1E1B4B);
  static const Color primaryContainer = Color(0xFFE0E7FF);

  // Accent — Amber
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentLight = Color(0xFFFBBF24);
  static const Color accentDark = Color(0xFFD97706);
  static const Color accentContainer = Color(0xFFFEF3C7);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoContainer = Color(0xFFDBEAFE);

  // Priority colors
  static const Color priorityCritical = Color(0xFFEF4444);
  static const Color priorityHigh = Color(0xFFF97316);
  static const Color priorityMedium = Color(0xFFFBBF24);
  static const Color priorityLow = Color(0xFF22C55E);
  static const Color prioritySomeday = Color(0xFF9CA3AF);

  // Status colors
  static const Color statusPending = Color(0xFF3B82F6);
  static const Color statusInProgress = Color(0xFF8B5CF6);
  static const Color statusOnHold = Color(0xFF6B7280);
  static const Color statusCompleted = Color(0xFF10B981);
  static const Color statusCancelled = Color(0xFFEF4444);

  // Tag type colors
  static const Color typeAcademic = Color(0xFF6366F1);
  static const Color typeTuition = Color(0xFF0EA5E9);
  static const Color typeFinance = Color(0xFF10B981);
  static const Color typePersonal = Color(0xFFF97316);
  static const Color typeHealth = Color(0xFFEF4444);
  static const Color typeSocial = Color(0xFFEC4899);

  // Deadline strip
  static const Color deadlineUrgent = Color(0xFFEF4444);
  static const Color deadlineSoon = Color(0xFFF97316);
  static const Color deadlineLater = Color(0xFF10B981);

  // Note color labels
  static const List<Color> noteLabels = [
    Color(0xFF6366F1),
    Color(0xFFEC4899),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFF3B82F6),
    Color(0xFFF97316),
  ];

  // Surface shades (light)
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color dividerLight = Color(0xFFE2E8F0);

  // Surface shades (dark)
  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color dividerDark = Color(0xFF334155);

  // BDT accent
  static const Color bdtColor = Color(0xFF059669);
}
