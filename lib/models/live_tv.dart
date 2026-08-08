class Channels {
  const Channels({required this.channels});

  factory Channels.fromJson(Map<String, dynamic> json) {
    final items = json['channels'] as List<dynamic>? ?? const <dynamic>[];
    return Channels(
      channels: items
          .whereType<Map<String, dynamic>>()
          .map(Channel.fromJson)
          .toList(growable: false),
    );
  }

  final List<Channel> channels;
}

class Channel {
  const Channel({
    required this.id,
    required this.name,
    this.letter,
    this.watchUrl,
    this.playerUrl,
    this.categories = const <String>[],
  });

  factory Channel.fromJson(Map<String, dynamic> json) => Channel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Unknown channel',
        letter: json['letter']?.toString(),
        watchUrl: json['watchUrl']?.toString(),
        playerUrl: json['playerUrl']?.toString(),
        categories: (json['categories'] as List<dynamic>? ?? const <dynamic>[])
            .map((item) => item.toString())
            .toList(growable: false),
      );

  final String id;
  final String name;
  final String? letter;
  final String? watchUrl;
  final String? playerUrl;
  final List<String> categories;

  Channel copyWith({List<String>? categories}) => Channel(
        id: id,
        name: name,
        letter: letter,
        watchUrl: watchUrl,
        playerUrl: playerUrl,
        categories: categories ?? this.categories,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        if (letter != null) 'letter': letter,
        if (watchUrl != null) 'watchUrl': watchUrl,
        if (playerUrl != null) 'playerUrl': playerUrl,
        'categories': categories,
      };
}

class DaddyLiveStream {
  const DaddyLiveStream({
    required this.url,
    required this.headers,
    required this.embedUrl,
    this.expiresAt,
  });

  factory DaddyLiveStream.fromJson(Map<String, dynamic> json) {
    final stream = json['stream'] as Map<String, dynamic>? ?? json;
    final rawHeaders =
        stream['headers'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    return DaddyLiveStream(
      url: stream['url']?.toString() ?? '',
      headers: rawHeaders.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
      embedUrl: stream['embedUrl']?.toString() ?? '',
      expiresAt: DateTime.tryParse(stream['expiresAt']?.toString() ?? ''),
    );
  }

  final String url;
  final Map<String, String> headers;
  final String embedUrl;
  final DateTime? expiresAt;
}

class DaddyLiveEpg {
  const DaddyLiveEpg({required this.timezone, required this.days});

  factory DaddyLiveEpg.fromJson(Map<String, dynamic> json) => DaddyLiveEpg(
        timezone: json['timezone']?.toString() ?? '',
        days: (json['days'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(DaddyLiveEpgDay.fromJson)
            .toList(growable: false),
      );

  final String timezone;
  final List<DaddyLiveEpgDay> days;
}

class DaddyLiveEpgDay {
  const DaddyLiveEpgDay({required this.label, required this.categories});

  factory DaddyLiveEpgDay.fromJson(Map<String, dynamic> json) =>
      DaddyLiveEpgDay(
        label: json['label']?.toString() ?? '',
        categories: (json['categories'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(DaddyLiveEpgCategory.fromJson)
            .toList(growable: false),
      );

  final String label;
  final List<DaddyLiveEpgCategory> categories;
}

class DaddyLiveEpgCategory {
  const DaddyLiveEpgCategory({required this.name, required this.events});

  factory DaddyLiveEpgCategory.fromJson(Map<String, dynamic> json) =>
      DaddyLiveEpgCategory(
        name: json['name']?.toString() ?? 'Other',
        events: (json['events'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(DaddyLiveEpgEvent.fromJson)
            .toList(growable: false),
      );

  final String name;
  final List<DaddyLiveEpgEvent> events;
}

class DaddyLiveEpgEvent {
  const DaddyLiveEpgEvent({
    required this.time,
    required this.title,
    required this.channels,
    this.startsAt,
  });

  factory DaddyLiveEpgEvent.fromJson(Map<String, dynamic> json) =>
      DaddyLiveEpgEvent(
        time: json['time']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        startsAt: DateTime.tryParse(json['startsAt']?.toString() ?? ''),
        channels: (json['channels'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(Channel.fromJson)
            .toList(growable: false),
      );

  final String time;
  final String title;
  final DateTime? startsAt;
  final List<Channel> channels;
}
