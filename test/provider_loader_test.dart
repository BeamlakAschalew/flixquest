import 'dart:async';

import 'package:flixquest/video_providers/common.dart';
import 'package:flixquest/video_providers/names.dart';
import 'package:flixquest/video_providers/provider_loader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('concurrent results are selected in configured provider order',
      () async {
    final slowResult = Completer<ProviderLoadResult>();
    final fastResult = Completer<ProviderLoadResult>();
    final providers = [
      VideoProvider.scraper(id: 'slow', name: 'Slow'),
      VideoProvider.scraper(id: 'fast', name: 'Fast'),
    ];
    final completedProviders = <String>[];

    final selectionFuture = ProviderLoader.loadFirstSuccessful(
      providers: providers,
      load: (provider) =>
          provider.apiId == 'slow' ? slowResult.future : fastResult.future,
      onResult: (_, provider, __) => completedProviders.add(provider.apiId!),
    );

    fastResult.complete(
      ProviderLoadResult(
        success: true,
        videoLinks: [RegularVideoLinks(url: 'https://example.com/video.m3u8')],
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(completedProviders, ['fast']);

    // The fast second provider is stored, but cannot be selected until the
    // first provider has resolved and failed.
    slowResult.complete(
      const ProviderLoadResult(errorMessage: 'No sources'),
    );
    final selection = await selectionFuture;

    expect(selection?.provider.apiId, 'fast');
    expect(
      selection?.batchResults.keys,
      unorderedEquals(['scraper:slow', 'scraper:fast']),
    );
    expect(completedProviders, ['fast', 'slow']);
  });

  test('limits concurrent provider loading to batches of three', () async {
    final results = List.generate(5, (_) => Completer<ProviderLoadResult>());
    final providers = List.generate(
      5,
      (index) => VideoProvider.scraper(id: '$index', name: 'Provider $index'),
    );
    final startedProviders = <String>[];

    final selectionFuture = ProviderLoader.loadFirstSuccessful(
      providers: providers,
      load: (provider) {
        startedProviders.add(provider.apiId!);
        return results[int.parse(provider.apiId!)].future;
      },
    );
    await Future<void>.delayed(Duration.zero);
    expect(startedProviders, ['0', '1', '2']);

    for (var index = 0; index < 3; index++) {
      results[index].complete(const ProviderLoadResult(errorMessage: 'Failed'));
    }
    await Future<void>.delayed(Duration.zero);
    expect(startedProviders, ['0', '1', '2', '3', '4']);

    results[3].complete(
      ProviderLoadResult(
        success: true,
        videoLinks: [RegularVideoLinks(url: 'https://example.com/video.m3u8')],
      ),
    );
    expect((await selectionFuture)?.provider.apiId, '3');
    results[4].complete(const ProviderLoadResult(errorMessage: 'Failed'));
  });
}
