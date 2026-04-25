import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_button.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).restoreSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    // Session restored with a user → GoRouter redirect handles navigation.
    // While checking (not initialized) show a centered loader.
    if (!auth.initialized) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryBlue,
            strokeWidth: 3,
          ),
        ),
      );
    }

    // No stored session — show welcome screen.
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.blueTint,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: const Text('🧸🩺💙', style: TextStyle(fontSize: 72)),
              ),
              const SizedBox(height: 36),
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.favorite_rounded,
                              color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'NaiviSense',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      AppConstants.tagline,
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Connect. Track. Grow.\nA complete therapy platform for Therapists and Parents.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5),
                  ),
                ),
              ),
              const Spacer(),
              AppButton(
                label: 'Get Started',
                onPressed: () => context.go('/role'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/role'),
                child: const Text(
                  'Login',
                  style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
