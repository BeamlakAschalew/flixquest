import 'package:flixquest/video_providers/common.dart';

/// FlixAPI Multi-provider response model
/// Used by: vixsrc, pstream, showbox
///
/// Endpoint format:
/// - Movies: {baseUrl}/{provider}/stream-movie?tmdbId={id}
/// - TV: {baseUrl}/{provider}/stream-tv?tmdbId={id}&episode={ep}&season={sn}

class FlixAPIMultiResponse {
  late bool success;
  String? provider;
  FlixAPIMultiMedia? media;
  List<FlixAPIMultiLink>? links;

  FlixAPIMultiResponse({
    this.success = false,
    this.provider,
    this.media,
    this.links,
  });

  FlixAPIMultiResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    provider = json['provider'];
    media = json['media'] != null
        ? FlixAPIMultiMedia.fromJson(json['media'])
        : null;
    if (json['links'] != null) {
      links = [];
      json['links'].forEach((v) {
        links!.add(FlixAPIMultiLink.fromJson(v));
      });
    }
  }
}

class FlixAPIMultiMedia {
  String? type;
  String? title;
  int? releaseYear;
  String? tmdbId;

  FlixAPIMultiMedia({
    this.type,
    this.title,
    this.releaseYear,
    this.tmdbId,
  });

  FlixAPIMultiMedia.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    title = json['title'];
    releaseYear = json['releaseYear'];
    tmdbId = json['tmdbId']?.toString();
  }
}

class FlixAPIMultiLink {
  String? server;
  String? url;
  bool? isM3U8;
  String? quality;
  List<FlixAPIMultiSubtitle>? subtitles;

  FlixAPIMultiLink({
    this.server,
    this.url,
    this.isM3U8,
    this.quality,
    this.subtitles,
  });

  FlixAPIMultiLink.fromJson(Map<String, dynamic> json) {
    server = json['server'];
    url = json['url'];
    isM3U8 = json['isM3U8'];
    quality = json['quality'];
    if (json['subtitles'] != null) {
      subtitles = [];
      json['subtitles'].forEach((v) {
        subtitles!.add(FlixAPIMultiSubtitle.fromJson(v));
      });
    }
  }
}

class FlixAPIMultiSubtitle {
  String? file;
  String? label;
  String? kind;
  bool? isDefault;

  FlixAPIMultiSubtitle({
    this.file,
    this.label,
    this.kind,
    this.isDefault,
  });

  FlixAPIMultiSubtitle.fromJson(Map<String, dynamic> json) {
    file = json['file'];
    label = json['label'];
    kind = json['kind'];
    isDefault = json['default'] ?? false;
  }
}

/// Extension to convert FlixAPIMultiLink to RegularVideoLinks
class FlixAPIMultiVideoLinks extends RegularVideoLinks {
  String? server;

  FlixAPIMultiVideoLinks({
    super.url,
    super.isM3U8,
    super.quality,
    this.server,
  });

  FlixAPIMultiVideoLinks.fromLink(FlixAPIMultiLink link)
      : server = link.server,
        super(url: link.url, isM3U8: link.isM3U8, quality: link.quality);
}

/// Extension to convert FlixAPIMultiSubtitle to RegularSubtitleLinks
class FlixAPIMultiSubtitleLinks extends RegularSubtitleLinks {
  String? kind;
  bool? isDefault;

  FlixAPIMultiSubtitleLinks({
    super.url,
    super.language,
    this.kind,
    this.isDefault,
  });

  FlixAPIMultiSubtitleLinks.fromSubtitle(FlixAPIMultiSubtitle subtitle)
      : kind = subtitle.kind,
        isDefault = subtitle.isDefault,
        super(url: subtitle.file, language: subtitle.label);
}
