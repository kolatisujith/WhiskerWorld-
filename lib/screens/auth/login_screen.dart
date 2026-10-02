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

/// Whisker World Login Screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (success && mounted) {
      final role = authProvider.userRole;
      if (role == UserRole.petOwner) {
        context.go('/owner/dashboard');
      } else {
        context.go('/adopter/dashboard');
      }
    }
  }

  void _showForgotPasswordDialog() {
    final emailResetController = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.pureWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.lock_reset_rounded, color: AppTheme.primaryCoral),
            const SizedBox(width: 8),
            const Text('Reset Password', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your registered email address and we will send you instructions to reset your password.',
              style: TextStyle(fontSize: 14, color: AppTheme.charcoalLight),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailResetController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                hintText: 'you@example.com',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Password reset instructions sent to ${emailResetController.text.trim().isEmpty ? "your email" : emailResetController.text.trim()}!',
                  ),
                  backgroundColor: AppTheme.naturalSageGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isMobile = ResponsiveLayout.isMobile(context);
    final isDark = AppTheme.isDark(context);
    final cardBg = AppTheme.cardBackground(context);
    final border = AppTheme.border(context);
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);

    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      appBar: const WhiskerNavBar(),
      body: Stack(
        children: [
          // 1. Photographic Companion Background with Soft Opacity
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

          // 2. Gentle Blur & Gradient Scrim
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
              left: 80,
              top: 140,
              child: FloatingWidget(
                verticalDistance: 14,
                maxRotation: 0.1,
                duration: const Duration(milliseconds: 3800),
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
                      Text('5,000+ Happy Adoptions', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 90,
              top: 180,
              child: FloatingWidget(
                verticalDistance: 12,
                phaseOffset: 0.5,
                maxRotation: -0.12,
                duration: const Duration(milliseconds: 3400),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: (isDark ? const Color(0xFF1E293B) : Colors.white).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded, color: Color(0xFF0D9488), size: 18),
                      SizedBox(width: 8),
                      Text('Verified Pet Stores & Owners', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
          ],

          // 4. Main Scrollable Form Content
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 32.0 : 64.0,
                    horizontal: 16.0,
                  ),
                  child: ResponsiveContentWrapper(
                    maxWidth: 480,
                    child: ScrollFadeSlide(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: EdgeInsets.all(isMobile ? 24.0 : 36.0),
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
                          'Welcome Back',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sign in to access your pets, adoption requests, and account.',
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
                          const SizedBox(height: 20),
                        ],

                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            hintText: 'you@example.com',
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

                        // Password Field
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
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),

                        // Forgot password link
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _showForgotPasswordDialog,
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primaryDarkCoral,
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Login Button
                        ElevatedButton(
                          onPressed: authProvider.isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Sign In', style: TextStyle(fontSize: 16)),
                        ),
                        const SizedBox(height: 24),

                        // Register Link
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(color: AppTheme.charcoalLight, fontSize: 14),
                            ),
                            InkWell(
                              onTap: () {
                                authProvider.clearError();
                                context.go('/register');
                              },
                              child: const Text(
                                'Register here',
                                style: TextStyle(
                                  color: AppTheme.primaryCoral,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),

                        // Demo Accounts Quick Fill (Phase 8 Requirement 14)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.darkSurface : AppTheme.warmCream,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.badge_outlined, size: 18, color: AppTheme.primaryCoral),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Demo Credentials (Testing)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: textPrim,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Click below to fill evaluation credentials:',
                                style: TextStyle(fontSize: 12, color: textSec),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                ),
                                onPressed: () {
                                  _emailController.text = 'owner@example.com';
                                  _passwordController.text = 'Owner@123';
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.storefront_outlined, size: 16, color: AppTheme.primaryCoral),
                                    SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'Demo Owner (owner@example.com)',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                ),
                                onPressed: () {
                                  _emailController.text = 'adopter@example.com';
                                  _passwordController.text = 'Adopter@123';
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.favorite_border, size: 16, color: AppTheme.naturalSageGreen),
                                    SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'Demo Adopter (adopter@example.com)',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
}
