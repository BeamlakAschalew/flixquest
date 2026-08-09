import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../services/auth_navigation_service.dart';
import '../app/tv_design.dart';
import '../focus/tv_focusable.dart';
import '../widgets/tv_dialog.dart';

class TvProfileScreen extends StatelessWidget {
  const TvProfileScreen({required this.metrics, super.key});

  final TvShellMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      return _ProfileLayout(
        metrics: metrics,
        name: 'Guest',
        subtitle: 'Local watchlist and browsing session',
        profileId: 0,
        onSignOut: () => _confirmSignOut(context),
      );
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future:
          FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final name = data?['name']?.toString().trim();
        final username = data?['username']?.toString().trim();
        final profileId = data?['profileId'] is int
            ? data!['profileId'] as int
            : int.tryParse(data?['profileId']?.toString() ?? '') ?? 0;
        return _ProfileLayout(
          metrics: metrics,
          name: name == null || name.isEmpty
              ? user.displayName ?? 'FlixQuest member'
              : name,
          subtitle: username == null || username.isEmpty
              ? user.email ?? 'Signed in'
              : '@$username',
          profileId: profileId,
          loading: snapshot.connectionState != ConnectionState.done,
          onSignOut: () => _confirmSignOut(context),
        );
      },
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    await showTvDialog<void>(
      context: context,
      title: 'Sign out?',
      content: const Text(
        'You will return to the FlixQuest TV welcome screen.',
      ),
      actions: <TvDialogAction>[
        TvDialogAction(
          label: 'Cancel',
          autofocus: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TvDialogAction(
          label: 'Sign out',
          isPrimary: true,
          onPressed: () async {
            Navigator.of(context).pop();
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              await AuthNavigationService.returnToSignedOutRoot(context);
            }
          },
        ),
      ],
    );
  }
}

class _ProfileLayout extends StatelessWidget {
  const _ProfileLayout({
    required this.metrics,
    required this.name,
    required this.subtitle,
    required this.profileId,
    required this.onSignOut,
    this.loading = false,
  });

  final TvShellMetrics metrics;
  final String name;
  final String subtitle;
  final int profileId;
  final VoidCallback onSignOut;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.all(metrics.contentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(PhosphorIcons.userCircle(), color: colors.primary, size: 32),
              const SizedBox(width: 13),
              Text(
                'Profile',
                style: TextStyle(
                  color: colors.onSurface,
                  fontFamily: 'FigtreeSB',
                  fontSize: 34,
                ),
              ),
            ],
          ),
          const Spacer(),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: TvDesign.surfaceFor(context, emphasis: 0.025),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.45),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(metrics.compact ? 26 : 38),
                  child: Row(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.asset(
                          'assets/images/profiles/${profileId.clamp(0, 149)}.png',
                          width: metrics.compact ? 110 : 146,
                          height: metrics.compact ? 110 : 146,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: metrics.compact ? 110 : 146,
                            height: metrics.compact ? 110 : 146,
                            color: colors.surfaceContainerHighest,
                            child: Icon(
                              PhosphorIcons.user(),
                              color: colors.onSurfaceVariant,
                              size: 54,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 30),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (loading)
                              const LinearProgressIndicator()
                            else ...<Widget>[
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: colors.onSurface,
                                  fontFamily: 'FigtreeSB',
                                  fontSize: metrics.compact ? 30 : 38,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: metrics.compact ? 18 : 21,
                                ),
                              ),
                            ],
                            const SizedBox(height: 27),
                            TvFocusable(
                              semanticLabel: 'Sign out',
                              onActivate: onSignOut,
                              focusScale: 1.025,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.errorContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(PhosphorIcons.signOut(),
                                        color: colors.onErrorContainer),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Sign out',
                                      style: TextStyle(
                                        color: colors.onErrorContainer,
                                        fontFamily: 'FigtreeSB',
                                        fontSize: 19,
                                      ),
                                    ),
                                  ],
                                ),
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
          const Spacer(),
        ],
      ),
    );
  }
}
