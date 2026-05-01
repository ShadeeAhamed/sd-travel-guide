import 'package:flutter/material.dart';

import '../models/auth_models.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'auth_welcome_screen.dart';
import 'onboarding_screen.dart';
import 'travel_shell_screen.dart';

class AppBootstrapScreen extends StatelessWidget {
  const AppBootstrapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppLaunchState>(
      future: AuthService.instance.loadLaunchState(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _BootstrapSplash();
        }

        final state = snapshot.data;
        if (state == null || state.user == null) {
          return const AuthWelcomeScreen();
        }

        if (state.needsOnboarding) {
          return OnboardingScreen(user: state.user!);
        }

        return TravelShellScreen(user: state.user!);
      },
    );
  }
}

class _BootstrapSplash extends StatelessWidget {
  const _BootstrapSplash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.midnight, AppColors.obsidian, Color(0xFF1B1325)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 128,
                height: 128,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 32,
                      color: AppColors.gold.withAlpha(70),
                    ),
                  ],
                  image: const DecorationImage(
                    image: AssetImage('assets/branding/sd_travel_guide_icon.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'SD Travel Guide',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.6,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
