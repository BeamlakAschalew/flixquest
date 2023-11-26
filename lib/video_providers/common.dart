class RegularVideoLinks {
  String? url;
  String? quality;
  bool? isM3U8;

  RegularVideoLinks.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    quality = json['quality'];
    isM3U8 = json['isM3U8'];
  }
}

class RegularSubtitleLinks {
  String? url;
  String? language;

  RegularSubtitleLinks.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    language = json['lang'];
  }
}

class SuperstreamVideoSources extends RegularVideoLinks {
  SuperstreamVideoSources.fromJson(Map<String, dynamic> json)
      : super.fromJson(json);
}

class SuperstreamSubtitleSources extends RegularSubtitleLinks {
  SuperstreamSubtitleSources.fromJson(Map<String, dynamic> json)
      : super.fromJson(json);
}
