class RegularVideoLinks {
  String? url;
  String? quality;
  bool? isM3U8;

  RegularVideoLinks.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    if (json.containsKey('quality')) {
      quality = json['quality'];
    }
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
