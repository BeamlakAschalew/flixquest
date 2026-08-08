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
    this.eventTitles = const <String>[],
    this.nowPlaying,
    this.nextUp,
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
        eventTitles:
            (json['eventTitles'] as List<dynamic>? ?? const <dynamic>[])
                .map((item) => item.toString())
                .toList(growable: false),
        nowPlaying: json['nowPlaying']?.toString(),
        nextUp: json['nextUp']?.toString(),
      );

  final String id;
  final String name;
  final String? letter;
  final String? watchUrl;
  final String? playerUrl;
  final List<String> categories;

  /// Event titles airing on this channel (used for searching by teams etc.).
  final List<String> eventTitles;

  /// Title of the event currently airing on this channel, when known.
  final String? nowPlaying;

  /// Title of the next upcoming event on this channel, when known.
  final String? nextUp;

  Channel copyWith({
    List<String>? categories,
    List<String>? eventTitles,
    String? nowPlaying,
    String? nextUp,
  }) =>
      Channel(
        id: id,
        name: name,
        letter: letter,
        watchUrl: watchUrl,
        playerUrl: playerUrl,
        categories: categories ?? this.categories,
        eventTitles: eventTitles ?? this.eventTitles,
        nowPlaying: nowPlaying ?? this.nowPlaying,
        nextUp: nextUp ?? this.nextUp,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        if (letter != null) 'letter': letter,
        if (watchUrl != null) 'watchUrl': watchUrl,
        if (playerUrl != null) 'playerUrl': playerUrl,
        'categories': categories,
        if (eventTitles.isNotEmpty) 'eventTitles': eventTitles,
        if (nowPlaying != null) 'nowPlaying': nowPlaying,
        if (nextUp != null) 'nextUp': nextUp,
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

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (timezone.isNotEmpty) 'timezone': timezone,
        'days': days.map((day) => day.toJson()).toList(growable: false),
      };
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

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (label.isNotEmpty) 'label': label,
        'categories': categories.map((category) => category.toJson()).toList(),
      };
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

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (name.isNotEmpty) 'name': name,
        'events': events.map((event) => event.toJson()).toList(),
      };
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

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (time.isNotEmpty) 'time': time,
        'title': title,
        if (startsAt != null) 'startsAt': startsAt!.toIso8601String(),
        'channels': channels.map((channel) => channel.toJson()).toList(),
      };
}
