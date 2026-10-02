import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../models/enums.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/animations/floating_widget.dart';
import '../../widgets/animations/scroll_fade_slide.dart';
import '../../widgets/footer.dart';
import '../../widgets/navbar.dart';
import '../../widgets/responsive_layout.dart';

/// Whisker World Registration Screen
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  UserRole _selectedRole = UserRole.petAdopter;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
      role: _selectedRole,
      location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
    );

    if (success && mounted) {
      if (_selectedRole == UserRole.petOwner) {
        context.go('/owner/dashboard');
      } else {
        context.go('/adopter/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isMobile = ResponsiveLayout.isMobile(context);

    final isDark = AppTheme.isDark(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final cardBg = AppTheme.cardBackground(context);
    final border = AppTheme.border(context);

    return Scaffold(
      appBar: const WhiskerNavBar(),
      body: Stack(
        children: [
          // 1. Photographic Background
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.20 : 0.18,
              child: Image.asset(
                'assets/images/auth_companion_bg.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ),

          // 2. Gradient Scrim
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.background(context).withValues(alpha: isDark ? 0.88 : 0.85),
                    AppTheme.background(context).withValues(alpha: isDark ? 0.80 : 0.75),
                    AppTheme.background(context),
                  ],
                ),
              ),
            ),
          ),

          // 3. Floating Ambient Badges on Desktop
          if (isDesktop) ...[
            Positioned(
              left: 60,
              top: 140,
              child: FloatingWidget(
                verticalDistance: 14,
                duration: const Duration(milliseconds: 3600),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: (isDark ? const Color(0xFF1E293B) : Colors.white).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryCoral.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryCoral.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🐾', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text('Join 5,000+ Caregivers', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 60,
              top: 180,
              child: FloatingWidget(
                verticalDistance: 12,
                phaseOffset: 0.5,
                duration: const Duration(milliseconds: 3200),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: (isDark ? const Color(0xFF1E293B) : Colors.white).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 18),
                      SizedBox(width: 8),
                      Text('100% Verified Sanctuaries', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
          ],

          // 4. Main Scrollable Form
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 32.0 : 64.0,
                    horizontal: 16.0,
                  ),
                  child: ResponsiveContentWrapper(
                    maxWidth: 580,
                    child: ScrollFadeSlide(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: EdgeInsets.all(isMobile ? 24.0 : 40.0),
                            decoration: BoxDecoration(
                              color: cardBg.withValues(alpha: isDark ? 0.85 : 0.90),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: border),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark ? Colors.black.withValues(alpha: 0.35) : AppTheme.charcoal.withValues(alpha: 0.08),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                        // Icon & Header
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryCoral.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Text('🐾', style: TextStyle(fontSize: 32)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Join Whisker World',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Select your role and start your pet journey today.',
                          style: TextStyle(color: AppTheme.charcoalLight, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),

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
                                    style: const TextStyle(
                                      color: Color(0xFFD32F2F),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Role Selector Header
                        const Text(
                          'I am joining as a:',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        const SizedBox(height: 12),

                        // Role Selection Cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildRoleCard(
                                role: UserRole.petAdopter,
                                title: 'Pet Adopter',
                                subtitle: 'Looking for a furry companion',
                                icon: Icons.favorite_rounded,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildRoleCard(
                                role: UserRole.petOwner,
                                title: 'Pet Owner',
                                subtitle: 'Listing pets / pet store',
                                icon: Icons.storefront_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Full Name
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            hintText: 'Jane Doe',
                            prefixIcon: const Icon(Icons.person_outline_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            hintText: 'jane@example.com',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!val.contains('@') || !val.contains('.')) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Phone Number
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            hintText: '+1 (555) 000-0000',
                            prefixIcon: const Icon(Icons.phone_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Location (Optional)
                        TextFormField(
                          controller: _locationController,
                          decoration: InputDecoration(
                            labelText: 'Location / City (Optional)',
                            hintText: 'Austin, TX',
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (val.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Confirm Password
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock_reset_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () => setState(
                                () => _obscureConfirmPassword = !_obscureConfirmPassword,
                              ),
                            ),
                          ),
                          validator: (val) {
                            if (val != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),

                        // Submit Button
                        ElevatedButton(
                          onPressed: authProvider.isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Create Account', style: TextStyle(fontSize: 16)),
                        ),
                        const SizedBox(height: 24),

                        // Back to Login Link
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              'Already have an account? ',
                              style: TextStyle(color: AppTheme.charcoalLight, fontSize: 14),
                            ),
                            InkWell(
                              onTap: () {
                                authProvider.clearError();
                                context.go('/login');
                              },
                              child: const Text(
                                'Sign in',
                                style: TextStyle(
                                  color: AppTheme.primaryCoral,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const WhiskerFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;

    return InkWell(
      onTap: () => setState(() => _selectedRole = role),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryCoral.withValues(alpha: 0.08) : AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryCoral : AppTheme.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? AppTheme.primaryCoral : AppTheme.charcoalLight,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: isSelected ? AppTheme.primaryCoral : AppTheme.charcoal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: AppTheme.charcoalLight),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
