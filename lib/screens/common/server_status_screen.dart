// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../provider/app_dependency_provider.dart';
import '../../ui_components/app_ui_components.dart';
import '../../video_providers/names.dart';
import '../../video_providers/provider_loader.dart';
import '../../video_providers/scraper_api.dart';

class ServerStatusScreen extends StatefulWidget {
  const ServerStatusScreen({super.key});

  @override
  State<ServerStatusScreen> createState() => _ServerStatusScreenState();
}

class _ServerStatusScreenState extends State<ServerStatusScreen> {
  bool _checking = true;
  String? _discoveryError;
  List<_ProviderStatus> _providers = const [];

  @override
  void initState() {
    super.initState();
    _checkServer();
  }

  Future<void> _checkServer() async {
    final scraperApiUrl = context.read<AppDependencyProvider>().flixquestAPIURL;
    if (mounted) {
      setState(() {
        _checking = true;
        _discoveryError = null;
      });
    }

    final providers = <VideoProvider>[];
    String? discoveryError;
    try {
      providers.addAll(await ScraperApi(scraperApiUrl).getProviders());
    } catch (error) {
      discoveryError = error.toString();
    }
    providers.add(VideoProvider.directVixSrc);

    if (!mounted) return;
    setState(() {
      _providers = providers.map(_ProviderStatus.checking).toList();
      _discoveryError = discoveryError;
    });

    final results = await Future.wait(
      providers.map(
        (provider) => _checkProvider(provider, scraperApiUrl),
      ),
    );
    if (!mounted) return;
    setState(() {
      _checking = false;
      _providers = results;
    });
  }

  Future<_ProviderStatus> _checkProvider(
    VideoProvider provider,
    String scraperApiUrl,
  ) async {
    final stopwatch = Stopwatch()..start();
    final result = await ProviderLoader.loadMovieFromProvider(
      provider: provider,
      movieId: 884605,
      scraperApiUrl: scraperApiUrl,
    );
    stopwatch.stop();
    return _ProviderStatus(
      provider: provider,
      checking: false,
      working: result.success && (result.videoLinks?.isNotEmpty ?? false),
      latency: stopwatch.elapsed,
      error: result.errorMessage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(tr('check_server'))),
      body: AppResponsiveContent(
        maxWidth: 680,
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        child: Column(
          children: [
            if (_discoveryError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _discoveryError!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ),
            Expanded(
              child: ListView.separated(
                itemCount: _providers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) =>
                    _buildProviderCard(_providers[index], colors),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _checking ? null : _checkServer,
              icon: Icon(PhosphorIcons.arrowsClockwise()),
              label: Text(tr('check_server')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderCard(_ProviderStatus status, ColorScheme colors) {
    final color = status.checking
        ? colors.primary
        : status.working
            ? colors.tertiary
            : colors.error;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: status.checking
                  ? const Padding(
                      padding: EdgeInsets.all(15),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      status.working
                          ? PhosphorIcons.checkCircle()
                          : PhosphorIcons.warningCircle(),
                      color: color,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The API alias is the user-facing name everywhere.
                  Text(
                    status.provider.displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status.checking
                        ? tr('checking_server')
                        : status.working
                            ? tr('server_working')
                            : tr('server_down'),
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  if (!status.checking && status.latency != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${status.latency!.inMilliseconds} ms',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (!status.checking &&
                      !status.working &&
                      status.error != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      status.error!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.error,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderStatus {
  const _ProviderStatus({
    required this.provider,
    required this.checking,
    this.working = false,
    this.latency,
    this.error,
  });

  factory _ProviderStatus.checking(VideoProvider provider) {
    return _ProviderStatus(provider: provider, checking: true);
  }

  final VideoProvider provider;
  final bool checking;
  final bool working;
  final Duration? latency;
  final String? error;
}
