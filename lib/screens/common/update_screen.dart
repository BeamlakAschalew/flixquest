import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../constants/api_constants.dart';
import '../../constants/app_constants.dart';
import '../../functions/network.dart';
import '../../models/update.dart';
import '../../provider/app_dependency_provider.dart';
import '../../provider/settings_provider.dart';
import '../../services/globle_method.dart';
import '../../services/app_update_service.dart';
import '../../ui_components/app_ui_components.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key, required this.isForced});

  final bool isForced;

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  final DownloadManager _downloadManager = DownloadManager();
  UpdateChecker? _update;
  String _savedDir = '';
  Object? _error;

  @override
  void initState() {
    super.initState();
    _checkUpdate();
  }

  Future<void> _checkUpdate() async {
    setState(() {
      _error = null;
      _update = null;
    });
    try {
      final values = await Future.wait([
        checkForUpdate(FLIXQUEST_UPDATE_URL),
        getTemporaryDirectory(),
      ]);
      if (!mounted) return;
      setState(() {
        _update = values[0] as UpdateChecker;
        _savedDir = (values[1] as Directory).path;
      });
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
      GlobalMethods.showErrorScaffoldMessengerGeneral(error, context);
    }
  }

  Future<void> _showMustUpdateDialog() {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(PhosphorIcons.warningCircle()),
        title: Text(tr('must_update')),
        actions: [
          TextButton(
            onPressed: SystemNavigator.pop,
            child: Text(
              tr('exit'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('update')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isForced,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && widget.isForced) _showMustUpdateDialog();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(tr('check_for_update'))),
        body: AppResponsiveContent(
          maxWidth: 680,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return AppEmptyState(
        icon: PhosphorIcons.wifiSlash(),
        title: tr('internet_problem'),
        message: tr('check_connection'),
        action: FilledButton.icon(
          onPressed: _checkUpdate,
          icon: Icon(PhosphorIcons.arrowsClockwise()),
          label: Text(tr('retry')),
        ),
      );
    }
    if (_update == null) {
      return AppEmptyState(
        icon: PhosphorIcons.downloadSimple(),
        title: tr('check_for_update'),
        message: tr('loading_video_sources'),
        action: const CircularProgressIndicator(),
      );
    }
    if (_update!.versionNumber == currentAppVersion) {
      return AppEmptyState(
        icon: PhosphorIcons.checkCircle(),
        title: tr('no_update'),
        message: 'FlixQuest v$currentAppVersion',
      );
    }

    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Icon(
              PhosphorIcons.rocketLaunch(PhosphorIconsStyle.fill),
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              tr('update_available'),
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              tr('new_version', namedArgs: {
                'v': _update!.versionNumber!,
              }),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: _showChangelog,
              icon: Icon(PhosphorIcons.listBullets()),
              label: Text(tr('see_changelogs')),
            ),
            const SizedBox(height: 14),
            _DownloadCard(
              appVersion: _update!.versionNumber!,
              url: _update!.downloadLink!,
              task: _downloadManager.getDownload(_update!.downloadLink!),
              onToggle: _toggleDownload,
              onOpen: _openDownload,
              onDelete: _deleteDownload,
            ),
          ],
        ),
      ),
    );
  }

  void _showChangelog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('changelogs')),
        content: SingleChildScrollView(child: Text(_update!.changeLog!)),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('confirm')),
          ),
        ],
      ),
    );
  }

  void _toggleDownload(String url) {
    final task = _downloadManager.getDownload(url);
    if (task == null || task.status.value.isCompleted) {
      _downloadManager.addDownload(
        url,
        '$_savedDir/${_downloadManager.getFileNameFromUrl(url)}',
      );
    } else if (task.status.value == DownloadStatus.downloading) {
      _downloadManager.pauseDownload(url);
    } else if (task.status.value == DownloadStatus.paused) {
      _downloadManager.resumeDownload(url);
    }
    setState(() {});
  }

  void _openDownload(String url) {
    final file = File(
      '$_savedDir/${_downloadManager.getFileNameFromUrl(url)}',
    );
    if (file.existsSync()) OpenFilex.open(file.path);
  }

  void _deleteDownload(String url) {
    final file = File(
      '$_savedDir/${_downloadManager.getFileNameFromUrl(url)}',
    );
    if (file.existsSync()) file.deleteSync();
    setState(() {});
  }
}

class _DownloadCard extends StatelessWidget {
  const _DownloadCard({
    required this.appVersion,
    required this.url,
    required this.task,
    required this.onToggle,
    required this.onOpen,
    required this.onDelete,
  });

  final String appVersion;
  final String url;
  final DownloadTask? task;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onOpen;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  PhosphorIcons.androidLogo(),
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'FlixQuest v$appVersion',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            if (task != null) ...[
              const SizedBox(height: 14),
              ValueListenableBuilder<double>(
                valueListenable: task!.progress,
                builder: (context, progress, _) =>
                    LinearProgressIndicator(value: progress),
              ),
              const SizedBox(height: 8),
            ],
            if (task == null)
              FilledButton.icon(
                onPressed: () {
                  context
                      .read<SettingsProvider>()
                      .analytics
                      .trackAppUpdateDownload(appVersion);
                  onToggle(url);
                },
                icon: Icon(PhosphorIcons.downloadSimple()),
                label: Text(tr('download')),
              )
            else
              ValueListenableBuilder<DownloadStatus>(
                valueListenable: task!.status,
                builder: (context, status, _) {
                  if (status == DownloadStatus.completed) {
                    return Wrap(
                      spacing: 10,
                      children: [
                        FilledButton(
                          onPressed: () => onOpen(url),
                          child: Text(tr('install')),
                        ),
                        OutlinedButton(
                          onPressed: () => onDelete(url),
                          child: Text(tr('delete')),
                        ),
                      ],
                    );
                  }
                  return FilledButton.icon(
                    onPressed: () => onToggle(url),
                    icon: Icon(
                      status == DownloadStatus.downloading
                          ? PhosphorIcons.pause()
                          : PhosphorIcons.play(),
                    ),
                    label: Text(
                      status == DownloadStatus.downloading
                          ? tr('pause')
                          : tr('resume'),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class UpdateBottom extends StatefulWidget {
  const UpdateBottom({super.key});

  @override
  State<UpdateBottom> createState() => _UpdateBottomState();
}

class _UpdateBottomState extends State<UpdateBottom> {
  late final Future<PackageInfo> _packageInfo;
  bool _visible = false;
  String _notificationId = '';

  @override
  void initState() {
    super.initState();
    _packageInfo = PackageInfo.fromPlatform();
  }

  Future<void> _checkVisibility() async {
    final packageInfo = await _packageInfo;
    if (!mounted) return;
    final config = context.read<AppDependencyProvider>();
    final notificationId = AppUpdateService.notificationId(
      remoteVersion: config.latestAppVersion,
      latestBuildNumber: config.latestBuildNumber,
      minimumBuildNumber: config.minimumBuildNumber,
    );
    final ignored = sharedPrefsSingleton.getString('ignore_version') ?? '';

    setState(() {
      _notificationId = notificationId;
      _visible = notificationId.isNotEmpty &&
          ignored != notificationId &&
          AppUpdateService.isAvailable(
            packageInfo: packageInfo,
            remoteVersion: config.latestAppVersion,
            latestBuildNumber: config.latestBuildNumber,
            minimumBuildNumber: config.minimumBuildNumber,
          );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.watch<AppDependencyProvider>();
    _checkVisibility();
  }

  Future<void> _dismiss() async {
    if (_notificationId.isNotEmpty) {
      await sharedPrefsSingleton.setString('ignore_version', _notificationId);
    }
    if (mounted) setState(() => _visible = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    final config = context.watch<AppDependencyProvider>();
    final remoteBuild = AppUpdateService.effectiveBuildNumber(
      latestBuildNumber: config.latestBuildNumber,
      minimumBuildNumber: config.minimumBuildNumber,
    );
    final version = AppUpdateService.displayVersion(
      config.latestAppVersion,
      remoteBuild,
    );
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              colors.primary.withValues(alpha: .20),
              colors.secondary.withValues(alpha: .10),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: colors.primary.withValues(alpha: .28)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  PhosphorIcons.rocketLaunch(PhosphorIconsStyle.fill),
                  color: colors.onPrimary,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('update_available'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tr('new_version', namedArgs: {'v': version}),
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 11),
                    FilledButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UpdateScreen(isForced: false),
                        ),
                      ),
                      icon: Icon(PhosphorIcons.arrowUpRight()),
                      label: Text(tr('update')),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _dismiss,
                tooltip: tr('disable_notification_version'),
                icon: Icon(PhosphorIcons.x(), size: 19),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
