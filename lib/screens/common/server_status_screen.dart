// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../ui_components/app_ui_components.dart';
import '../../video_providers/vixsrc.dart';

class ServerStatusScreen extends StatefulWidget {
  const ServerStatusScreen({super.key});

  @override
  State<ServerStatusScreen> createState() => _ServerStatusScreenState();
}

class _ServerStatusScreenState extends State<ServerStatusScreen> {
  bool _checking = true;
  bool _working = false;
  Duration? _latency;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkServer();
  }

  Future<void> _checkServer() async {
    setState(() {
      _checking = true;
      _error = null;
    });
    final stopwatch = Stopwatch()..start();
    final result = await VixSrc.loadMovie(884605);
    stopwatch.stop();
    if (!mounted) return;
    setState(() {
      _checking = false;
      _working = result.success && (result.videoLinks?.isNotEmpty ?? false);
      _latency = stopwatch.elapsed;
      _error = result.errorMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(tr('check_server'))),
      body: AppResponsiveContent(
        maxWidth: 680,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: (_checking
                                ? colors.primary
                                : _working
                                    ? colors.tertiary
                                    : colors.error)
                            .withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _checking
                          ? const Padding(
                              padding: EdgeInsets.all(15),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              _working
                                  ? PhosphorIcons.checkCircle()
                                  : PhosphorIcons.warningCircle(),
                              color: _working ? colors.tertiary : colors.error,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VixSrc',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _checking
                                ? tr('checking_server')
                                : _working
                                    ? tr('server_working')
                                    : tr('server_down'),
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          if (!_checking && _latency != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${_latency!.inMilliseconds} ms',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!_checking && !_working && _error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.onSurfaceVariant),
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
}
