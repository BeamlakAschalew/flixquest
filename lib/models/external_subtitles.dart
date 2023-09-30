class ExternalSubtitle {
  ExternalSubtitle({required this.data});
  List<SubtitleData>? data;

  ExternalSubtitle.fromJson(Map<String, dynamic> json) {
    data = json['data'];
  }
}

class SubtitleData {
  SubtitleData({required this.attr});

  SubtitleAttr? attr;

  SubtitleData.fromJson(Map<String, dynamic> json) {
    attr = json['attributes'];
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
