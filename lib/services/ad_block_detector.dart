import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/adsterra_playback_ads_config.dart';
import '../models/banner_ads_config.dart';
import '../provider/app_dependency_provider.dart';

/// Resolves a host with the device's own DNS, the path every ad request takes.
typedef HostLookup = Future<List<InternetAddress>> Function(String host);

/// Whether a host exists in public DNS; null when no public resolver answered.
typedef PublicHostLookup = Future<bool?> Function(String host);

/// Detects DNS-level ad blocking: Private DNS (AdGuard DNS, NextDNS), local
/// VPN blockers (AdGuard, Blokada, RethinkDNS), hosts files (AdAway) and
/// network filters such as Pi-hole. Apps have no browser extensions, so this
/// is how Android users block FlixQuest's ads.
///
/// A blocker is reported only on positive evidence, so a slow, captive or
/// offline network never stops playback:
/// - an ad host answers with a sinkhole address (`0.0.0.0`, `::`, loopback);
/// - or the device cannot resolve an ad host, twice, while public DNS over
///   HTTPS finds it. Reaching the public resolver by name proves the device's
///   DNS works, and a retired ad domain fails publicly too.
class AdBlockDetector {
  AdBlockDetector({
    HostLookup? lookup,
    PublicHostLookup? publicLookup,
    http.Client? client,
    this.timeout = const Duration(seconds: 6),
  })  : _lookup = lookup ?? InternetAddress.lookup,
        _publicLookup = publicLookup ?? _dnsOverHttps(client ?? http.Client());

  final HostLookup _lookup;
  final PublicHostLookup _publicLookup;

  /// Past this, the check gives up and reports no blocker.
  final Duration timeout;

  static const _publicResolvers = [
    'https://cloudflare-dns.com/dns-query',
    'https://dns.google/resolve',
  ];

  /// The hosts that serve the ads FlixQuest currently shows: the live banner
  /// catalog and Adsterra's playback placements. FlixQuest-hosted pages are
  /// not ad hosts.
  static Set<String> adHosts(AppDependencyProvider provider) {
    final playback = provider.adsterraPlaybackAds;
    final placements = <PlaybackAdPlacement?>[
      if (playback.enabled) ...[
        playback.interstitial,
        playback.popunder,
        playback.tvPopunder,
        ...playback.triggerPlacements.values,
        ...?playback.streamFoundExperiment?.variants
            .map((variant) => variant.placement),
      ],
    ];
    return {
      for (final unit
          in provider.activeBannerAds?.units.values ?? const <BannerAdUnit>[])
        unit.scriptUrl.host,
      for (final placement in placements) ...[
        if (placement?.scriptUrl != null) placement!.scriptUrl!.host,
        if (placement?.smartlinkUrl != null) placement!.smartlinkUrl!.host,
      ],
    }..removeWhere((host) => host.isEmpty);
  }

  /// What blockers answer instead of a real address.
  @visibleForTesting
  static bool isSinkhole(InternetAddress address) =>
      address.isLoopback || address.rawAddress.every((byte) => byte == 0);

  Future<bool> isBlocking(Set<String> hosts) async {
    if (hosts.isEmpty) return false;
    try {
      return await _detect(hosts).timeout(timeout);
    } on TimeoutException {
      debugPrint('[AdBlockDetector] timed out; assuming no blocker');
      return false;
    }
  }

  Future<bool> _detect(Set<String> hosts) async {
    final results = await Future.wait(hosts.map(_resolveLocally));
    if (results.contains(_LocalAnswer.sinkhole)) {
      debugPrint('[AdBlockDetector] sinkholed ad host');
      return true;
    }
    final unresolved = [
      for (final (index, host) in hosts.indexed)
        if (results[index] == _LocalAnswer.none) host,
    ];
    if (unresolved.isEmpty) return false;
    final public = await Future.wait(unresolved.map(_publicLookup));
    for (final (index, host) in unresolved.indexed) {
      if (public[index] != true) continue;
      // Rule out a one-off resolver failure before blaming a blocker.
      final again = await _resolveLocally(host);
      if (again != _LocalAnswer.address) {
        debugPrint('[AdBlockDetector] $host resolves publicly but not here');
        return true;
      }
    }
    return false;
  }

  Future<_LocalAnswer> _resolveLocally(String host) async {
    try {
      final addresses = await _lookup(host);
      if (addresses.isEmpty) return _LocalAnswer.none;
      return addresses.every(isSinkhole)
          ? _LocalAnswer.sinkhole
          : _LocalAnswer.address;
    } on SocketException {
      return _LocalAnswer.none;
    }
  }

  /// JSON DNS over HTTPS. NXDOMAIN, or no real A record, means the host does
  /// not exist publicly; anything unreadable tries the next resolver.
  static PublicHostLookup _dnsOverHttps(http.Client client) => (host) async {
        for (final resolver in _publicResolvers) {
          try {
            final response = await client.get(
              Uri.parse(resolver)
                  .replace(queryParameters: {'name': host, 'type': 'A'}),
              headers: const {'accept': 'application/dns-json'},
            ).timeout(const Duration(seconds: 3));
            if (response.statusCode != 200) continue;
            final json = jsonDecode(response.body);
            if (json is! Map) continue;
            if (json['Status'] == 3) return false;
            if (json['Status'] != 0) continue;
            final answers = json['Answer'];
            return answers is List &&
                answers.any((answer) {
                  if (answer is! Map || answer['type'] != 1) return false;
                  final data = answer['data'];
                  final address =
                      data is String ? InternetAddress.tryParse(data) : null;
                  return address != null && !isSinkhole(address);
                });
          } catch (error) {
            debugPrint('[AdBlockDetector] $resolver unavailable ($error)');
          }
        }
        return null;
      };
}

enum _LocalAnswer { address, sinkhole, none }
