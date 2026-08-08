import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../provider/app_dependency_provider.dart';
import '../../provider/settings_provider.dart';
import '../../ui_components/app_ui_components.dart';
import '../common/about.dart';
import '../common/landing_screen.dart';
import '../common/live_tv_screen.dart';
import '../common/server_status_screen.dart';
import '../common/settings.dart' as app_settings;
import '../common/update_screen.dart';
import 'edit_profile.dart';

class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? uid;
  bool? userAnonymous;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    final user = _auth.currentUser;
    uid = user?.uid;
    userAnonymous = user?.isAnonymous ?? true;
  }

  @override
  Widget build(BuildContext context) {
    if (userAnonymous == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (userAnonymous!) return _anonymousProfile();
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return AppEmptyState(
            title: tr('error_occured'),
            message: tr('not_available'),
            icon: PhosphorIcons.userMinus(),
          );
        }
        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        return _profile(data);
      },
    );
  }

  Widget _anonymousProfile() {
    return SafeArea(
      bottom: false,
      child: AppResponsiveContent(
        padding: EdgeInsets.zero,
        maxWidth: 760,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppUI.pagePadding(context),
            20,
            AppUI.pagePadding(context),
            30,
          ),
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset('assets/images/logo.png',
                      width: 34, height: 34),
                ),
                const SizedBox(width: 12),
                Text(tr('profile'),
                    style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 30),
            Center(
              child: Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: .12),
                ),
                child: Icon(
                  PhosphorIcons.user(),
                  size: 54,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              tr('current_account_anonymous'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              tr('bookmark_feature_notice'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: FilledButton.icon(
                onPressed: _leaveAnonymousSession,
                icon: Icon(PhosphorIcons.signIn()),
                label: Text(tr('login_signup')),
              ),
            ),
            const SizedBox(height: 28),
            _profileActions(authenticated: false),
          ],
        ),
      ),
    );
  }

  Widget _profile(Map<String, dynamic> data) {
    final colors = Theme.of(context).colorScheme;
    final profileId = data['profileId'] ?? 0;
    final name = data['name']?.toString() ?? tr('not_available');
    final username = data['username']?.toString() ?? 'username';
    final email = data['email']?.toString() ?? '';
    return SafeArea(
      bottom: false,
      child: AppResponsiveContent(
        padding: EdgeInsets.zero,
        maxWidth: 760,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
              AppUI.pagePadding(context), 20, AppUI.pagePadding(context), 30),
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset('assets/images/logo.png',
                      width: 34, height: 34),
                ),
                const SizedBox(width: 12),
                Text(tr('profile'),
                    style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 28),
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: colors.primary.withValues(alpha: .28),
                          width: 2),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/profiles/$profileId.png',
                        width: 112,
                        height: 112,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/profiles/0.png',
                          width: 112,
                          height: 112,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: 2,
                    child: IconButton.filled(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _push(const ProfileEdit()),
                      icon: Icon(PhosphorIcons.pencilSimple(), size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              email,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              '@$username',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
            // const SizedBox(height: 24),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            //   decoration: BoxDecoration(
            //     border: Border.all(color: colors.primary, width: 1.6),
            //     borderRadius: BorderRadius.circular(24),
            //   ),
            //   child: Row(
            //     children: [
            //       Container(
            //         width: 48,
            //         height: 48,
            //         decoration: BoxDecoration(
            //           color: colors.primary.withValues(alpha: .12),
            //           borderRadius: BorderRadius.circular(16),
            //         ),
            //         child:
            //             Icon(Icons.auto_awesome_rounded, color: colors.primary),
            //       ),
            //       // const SizedBox(width: 15),
            //       // Expanded(
            //       //   child: Column(
            //       //     crossAxisAlignment: CrossAxisAlignment.start,
            //       //     children: [
            //       //       Text('FlixQuest',
            //       //           style: Theme.of(context)
            //       //               .textTheme
            //       //               .titleMedium
            //       //               ?.copyWith(color: colors.primary)),
            //       //       const SizedBox(height: 3),
            //       //       Text('${tr('joined')} $joined',
            //       //           style: Theme.of(context).textTheme.bodySmall),
            //       //     ],
            //       //   ),
            //       // ),
            //     ],
            //   ),
            // ),
            const SizedBox(height: 10),
            _profileActions(authenticated: true),
          ],
        ),
      ),
    );
  }

  Future<void> _leaveAnonymousSession() async {
    await _auth.currentUser?.delete();
    await _auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LandingScreen()),
    );
  }

  Widget _profileActions({required bool authenticated}) {
    final showLiveTV =
        context.watch<AppDependencyProvider>().displayOTTDrawer;
    final actions = <Widget>[
      if (authenticated)
        _ProfileAction(
          icon: PhosphorIcons.user(),
          title: tr('edit_profile'),
          onTap: () => _push(const ProfileEdit()),
        ),
      if (showLiveTV)
        _ProfileAction(
          icon: PhosphorIcons.television(),
          title: tr('live_tv'),
          onTap: () => _push(const ChannelList()),
        ),
      _ProfileAction(
        icon: PhosphorIcons.sliders(),
        title: tr('settings'),
        onTap: () => _push(const app_settings.Settings()),
      ),
      _ProfileAction(
        icon: PhosphorIcons.database(),
        title: tr('check_server'),
        onTap: () => _push(const ServerStatusScreen()),
      ),
      _ProfileAction(
        icon: PhosphorIcons.arrowsDownUp(),
        title: tr('check_for_update'),
        onTap: () => _push(const UpdateScreen(isForced: false)),
      ),
      _ProfileAction(
        icon: PhosphorIcons.shareNetwork(),
        title: tr('shared_the_app'),
        onTap: _shareApp,
      ),
      _ProfileAction(
        icon: PhosphorIcons.info(),
        title: tr('about'),
        onTap: () => _push(const AboutPage()),
      ),
      if (authenticated)
        _ProfileAction(
          icon: PhosphorIcons.signOut(),
          title: tr('logout'),
          destructive: true,
          onTap: _confirmSignOut,
        ),
    ];
    return Card(
      color: Colors.transparent,
      child: Column(
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            actions[i],
            if (i != actions.length - 1) const Divider(indent: 58),
          ],
        ],
      ),
    );
  }

  Future<void> _shareApp() async {
    context.read<SettingsProvider>().analytics.trackShare(
          shareType: 'App',
        );
    await Share.share(tr('share_text'));
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('sign_out')),
        content: Text(tr('want_to_sign_out')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(tr('cancel'))),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(tr('ok'))),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    context.read<SettingsProvider>().analytics.trackSignOut();
    context.read<SettingsProvider>().analytics.resetUser();
    await _auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LandingScreen()),
    );
  }

  void _push(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({
    required this.icon,
    required this.title,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurface;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: Icon(PhosphorIcons.caretRight()),
    );
  }
}
