class ExternalSubtitle {
  final String id;
  final String url;
  final String flagUrl;
  final String format;
  final String encoding;
  final String display;
  final String language;
  final String media;
  final bool isHearingImpaired;
  final String source;

  ExternalSubtitle({
    required this.id,
    required this.url,
    required this.flagUrl,
    required this.format,
    required this.encoding,
    required this.display,
    required this.language,
    required this.media,
    required this.isHearingImpaired,
    required this.source,
  });

  factory ExternalSubtitle.fromJson(Map<String, dynamic> json) {
    return ExternalSubtitle(
      id: json['id']?.toString() ?? '',
      url: json['url'] ?? '',
      flagUrl: json['flagUrl'] ?? '',
      format: json['format'] ?? 'srt',
      encoding: json['encoding'] ?? 'UTF-8',
      display: json['display'] ?? 'Unknown',
      language: json['language'] ?? 'en',
      media: json['media'] ?? '',
      isHearingImpaired: json['isHearingImpaired'] ?? false,
      source: json['source'] ?? 'opensubtitles',
    );
  }

  String get displayName {
    String name = display;
    if (isHearingImpaired) {
      name += ' (HI)';
    }
    return '$name - $format';
  }
}

// Keep old models for backward compatibility if still used elsewhere
class SubtitleData {
  SubtitleData({required this.attr});

  SubtitleAttr? attr;

  SubtitleData.fromJson(Map<String, dynamic> json) {
    attr = SubtitleAttr.fromJson(json['attributes']);
  }
}

class SubtitleAttr {
  SubtitleAttr({required this.files});
  List<SubtitleFiles>? files;

  SubtitleAttr.fromJson(Map<String, dynamic> json) {
    if (json['files'] != null) {
      files = [];
      json['files'].forEach((v) {
        files!.add(SubtitleFiles.fromJson(v));
      });
    }
  }
}

class SubtitleFiles {
  SubtitleFiles({required this.fileId});
  int? fileId;

  SubtitleFiles.fromJson(Map<String, dynamic> json) {
    fileId = json['file_id'];
  }
}

class SubtitleDownload {
  SubtitleDownload({required this.link});
  String? link;

  SubtitleDownload.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('link')) {
      link = json['link'];
    }
  }
}
