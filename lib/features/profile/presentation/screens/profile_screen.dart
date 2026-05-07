import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/sync_provider.dart';
import '../../../../core/widgets/confirmation_dialog.dart';

// Provider that manages the local profile photo path
final _profilePhotoProvider = StateNotifierProvider<_ProfilePhotoNotifier, String?>((ref) {
  return _ProfilePhotoNotifier();
});

class _ProfilePhotoNotifier extends StateNotifier<String?> {
  _ProfilePhotoNotifier() : super(null) {
    _load();
  }

  static const _key = 'profile_photo_path';

  Future<void> _load() async {
    if (kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_key);
  }

  Future<void> setPath(String? path) async {
    state = path;
    if (kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    if (path == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, path);
    }
  }
}

// Web-only in-memory photo bytes holder
XFile? _webPhotoFile;

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(source: source, imageQuality: 85);
      if (file == null) return;
      if (kIsWeb) {
        setState(() => _webPhotoFile = file);
      } else {
        await ref.read(_profilePhotoProvider.notifier).setPath(file.path);
      }
    } catch (_) {
      // Permission denied or not available on platform
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          Text('Change Profile Photo', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          ListTile(
            leading: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
            ),
            title: Text('Take Photo', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            subtitle: Text('Use your camera', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onTap: () {
              Navigator.pop(ctx);
              _pickImage(ImageSource.camera);
            },
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: AppColors.accentContainer, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.photo_library_outlined, color: AppColors.accent),
            ),
            title: Text('Choose from Gallery', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            subtitle: Text('Pick an existing photo', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onTap: () {
              Navigator.pop(ctx);
              _pickImage(ImageSource.gallery);
            },
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final sync = ref.watch(syncProvider);
    final localPhotoPath = ref.watch(_profilePhotoProvider);

    ImageProvider? localPhoto;
    if (kIsWeb && _webPhotoFile != null) {
      // On web, use network URL from XFile
      localPhoto = NetworkImage(_webPhotoFile!.path);
    } else if (!kIsWeb && localPhotoPath != null) {
      final file = File(localPhotoPath);
      if (file.existsSync()) localPhoto = FileImage(file);
    }

    // Decide what avatar to show: local photo > network photo > initial letter
    final networkPhoto = auth.user?.photoUrl != null ? NetworkImage(auth.user!.photoUrl!) : null;
    final displayPhoto = localPhoto ?? networkPhoto;
    final displayName = auth.user?.displayName ?? 'U';
    final initialLetter = displayName[0].toUpperCase();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const SizedBox(height: 20),
                    // Avatar with edit overlay
                    GestureDetector(
                      onTap: _showPhotoOptions,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundImage: displayPhoto,
                            backgroundColor: AppColors.primaryContainer,
                            child: displayPhoto == null
                                ? Text(initialLetter, style: GoogleFonts.inter(
                                    fontSize: 34, fontWeight: FontWeight.w700, color: AppColors.primary,
                                  ))
                                : null,
                          ),
                          // Green edit badge
                          Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(displayName,
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                    Text(auth.user?.email ?? '',
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                  ]),
                ),
              ),
            ),
            title: const Text('Profile'),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),
              // Sync status card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(color: AppColors.successContainer, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.cloud_done_outlined, color: AppColors.success),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Google Drive Sync', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(sync.isSyncing ? 'Syncing...' : 'Last synced: ${sync.lastSyncedText}',
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                    ])),
                    if (sync.isSyncing)
                      const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    else
                      IconButton(
                        icon: const Icon(Icons.sync, color: AppColors.primary),
                        onPressed: () => ref.read(syncProvider.notifier).sync(),
                      ),
                  ]),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Your data is backed up to your Google Drive. Switch devices by signing in.',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
              ),
              const SizedBox(height: 20),
              const Divider(indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings'),
              ),
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Notification Preferences'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings'),
              ),
              ListTile(
                leading: const Icon(Icons.school_outlined),
                title: const Text('University Settings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings'),
              ),
              const Divider(indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: Text('Sign Out', style: GoogleFonts.inter(color: AppColors.error, fontWeight: FontWeight.w600)),
                onTap: () async {
                  final confirm = await ConfirmationDialog.show(
                    context, title: 'Sign Out', message: 'Are you sure you want to sign out?',
                    confirmLabel: 'Sign Out', isDanger: true,
                  );
                  if (confirm && context.mounted) {
                    await ref.read(authProvider.notifier).signOut();
                    context.go('/login');
                  }
                },
              ),
              const SizedBox(height: 40),
            ]),
          ),
        ],
      ),
    );
  }
}
