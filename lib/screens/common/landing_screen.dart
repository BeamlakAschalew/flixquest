import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../functions/function.dart';
import '../../provider/settings_provider.dart';
import '../../services/globle_method.dart';
import '../../services/flixquest_auth_service.dart';
import '../user/login_screen.dart';
import '../user/signup_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _authService = FlixQuestAuthService();
  bool _loadingAnonymous = false;

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/grid_final.jpg', fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x66000000), Color(0xF0000000)],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 760;
                      const intro = _Intro();
                      final actions = _actionsCard(settings);
                      return Flex(
                        direction: wide ? Axis.horizontal : Axis.vertical,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (wide) Expanded(child: intro) else intro,
                          SizedBox(width: wide ? 56 : 0, height: wide ? 0 : 36),
                          if (wide)
                            SizedBox(width: 390, child: actions)
                          else
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 460),
                              child: actions,
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionsCard(SettingsProvider settings) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.surface.withValues(alpha: .96),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(tr('login_signup'),
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              tr('unlimited_on_cinemax'),
              style: TextStyle(color: colors.onSurfaceVariant, height: 1.4),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => _push(const LoginScreen()),
              child: Text(tr('log_in')),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _push(const SignupScreen()),
              child: Text(tr('sign_up')),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loadingAnonymous
                  ? null
                  : () => _continueAnonymously(settings),
              child: _loadingAnonymous
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(tr('continue_anonymously')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _continueAnonymously(SettingsProvider settings) async {
    setState(() => _loadingAnonymous = true);
    try {
      if (!await checkConnection()) {
        if (mounted) _showError(tr('check_connection'));
        return;
      }
      await _authService.signInAnonymously();
      settings.analytics.trackLogin('anonymous');
      // UserState's auth stream owns the handheld/TV destination.
    } catch (error) {
      if (mounted) _showError(error.toString());
    } finally {
      if (mounted) setState(() => _loadingAnonymous = false);
    }
  }

  void _showError(String message) {
    GlobalMethods.showCustomScaffoldMessage(
      SnackBar(content: Text(message, maxLines: 3)),
      context,
    );
  }

  void _push(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 92,
          height: 92,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Hero(
            tag: 'logo_shadow',
            child: Image.asset('assets/images/logo.png'),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          tr('thousands_of'),
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'FigtreeBold',
            fontSize: 40,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${tr('trending_movies')} • ${tr('popular_tv_shows')}',
          style: const TextStyle(color: Colors.white70, fontSize: 17),
        ),
      ],
    );
  }
}
