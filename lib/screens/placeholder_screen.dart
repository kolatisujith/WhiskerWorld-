import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app/theme.dart';
import '../widgets/footer.dart';
import '../widgets/navbar.dart';
import '../widgets/responsive_layout.dart';

/// Clean placeholder screen for secondary routes
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String? subtitle;

  const PlaceholderScreen({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WhiskerNavBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 80.0),
              child: ResponsiveContentWrapper(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: AppTheme.pureWhite,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.borderSubtle),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.charcoal.withValues(alpha: 0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryCoral.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.pets_rounded,
                            size: 40,
                            color: AppTheme.primaryCoral,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          subtitle ??
                              'This section is part of the Whisker World roadmap and will be fully implemented in upcoming phases.',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () => context.go('/'),
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: const Text('Back to Home'),
                        ),
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
}
