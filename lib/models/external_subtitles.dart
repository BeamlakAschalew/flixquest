class ExternalSubtitle {
  ExternalSubtitle({required this.data});
  List<SubtitleData>? data;

  ExternalSubtitle.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(SubtitleData.fromJson(v));
      });
    }
  }
}

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
  late int fileId;

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
