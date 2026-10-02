import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../models/enums.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/footer.dart';
import '../../widgets/navbar.dart';
import '../../widgets/responsive_layout.dart';

/// Profile Screen allowing Pet Owners and Pet Adopters to manage their details
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _bioController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _locationController = TextEditingController(text: user?.location ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updateProfile(
      name: _nameController.text,
      phone: _phoneController.text,
      location: _locationController.text,
      bio: _bioController.text,
    );

    if (success && mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppTheme.naturalSageGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final isMobile = ResponsiveLayout.isMobile(context);

    if (user == null) {
      return const Scaffold(
        appBar: WhiskerNavBar(),
        body: Center(child: Text('No active profile found.')),
      );
    }

    return Scaffold(
      appBar: const WhiskerNavBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 24.0 : 48.0,
                horizontal: 16.0,
              ),
              child: ResponsiveContentWrapper(
                maxWidth: 680,
                child: Container(
                  padding: EdgeInsets.all(isMobile ? 24.0 : 36.0),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground(context),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.border(context)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: AppTheme.isDark(context) ? 0.25 : 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header & Avatar Row
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: AppTheme.primaryCoral.withValues(alpha: 0.15),
                              child: Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : '🐾',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryCoral,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          user.name,
                                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: user.role == UserRole.petOwner
                                              ? AppTheme.primaryCoral.withValues(alpha: 0.12)
                                              : AppTheme.naturalSageGreen.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          user.role.displayName,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: user.role == UserRole.petOwner
                                                ? AppTheme.primaryDarkCoral
                                                : AppTheme.naturalSageGreen,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.email,
                                    style: const TextStyle(color: AppTheme.charcoalLight, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            IconButton.filledTonal(
                              icon: Icon(_isEditing ? Icons.close : Icons.edit_outlined),
                              onPressed: () {
                                setState(() {
                                  if (_isEditing) {
                                    // Reset controllers
                                    _nameController.text = user.name;
                                    _phoneController.text = user.phone ?? '';
                                    _locationController.text = user.location ?? '';
                                    _bioController.text = user.bio ?? '';
                                  }
                                  _isEditing = !_isEditing;
                                });
                              },
                              tooltip: _isEditing ? 'Cancel Edit' : 'Edit Profile',
                            ),
                          ],
                        ),
                        const Divider(height: 40),

                        // Error Banner
                        if (authProvider.errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFFCDD2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Color(0xFFD32F2F), size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    authProvider.errorMessage!,
                                    style: const TextStyle(color: Color(0xFFD32F2F), fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Fields
                        _buildField(
                          label: 'Full Name',
                          controller: _nameController,
                          enabled: _isEditing,
                          icon: Icons.person_outline,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Name required' : null,
                        ),
                        const SizedBox(height: 18),

                        _buildField(
                          label: 'Email Address (Account ID)',
                          controller: TextEditingController(text: user.email),
                          enabled: false,
                          icon: Icons.email_outlined,
                          helperText: 'Email cannot be changed directly.',
                        ),
                        const SizedBox(height: 18),

                        _buildField(
                          label: 'Phone Number',
                          controller: _phoneController,
                          enabled: _isEditing,
                          icon: Icons.phone_outlined,
                        ),
                        const SizedBox(height: 18),

                        _buildField(
                          label: 'Location / City',
                          controller: _locationController,
                          enabled: _isEditing,
                          icon: Icons.location_on_outlined,
                          hintText: 'e.g. Austin, TX',
                        ),
                        const SizedBox(height: 18),

                        _buildField(
                          label: 'Bio / About Me',
                          controller: _bioController,
                          enabled: _isEditing,
                          icon: Icons.chat_bubble_outline_rounded,
                          maxLines: 3,
                          hintText: 'Share a little about yourself and your passion for pets...',
                        ),

                        if (_isEditing) ...[
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  setState(() => _isEditing = false);
                                },
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: authProvider.isLoading ? null : _handleSave,
                                icon: authProvider.isLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Icon(Icons.save_outlined, size: 18),
                                label: const Text('Save Changes'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const WhiskerFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    required IconData icon,
    String? hintText,
    String? helperText,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.charcoal),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperText,
            prefixIcon: maxLines == 1 ? Icon(icon, size: 20) : null,
            filled: !enabled,
            fillColor: enabled ? AppTheme.pureWhite : const Color(0xFFF9F9F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
