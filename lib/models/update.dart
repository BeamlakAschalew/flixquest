class UpdateChecker {
  String? versionNumber;
  String? downloadLink;
  String? changeLog;
  UpdateChecker({this.changeLog, this.downloadLink, this.versionNumber});

  UpdateChecker.fromJson(Map<String, dynamic> json) {
    changeLog = json['changelog'];
    downloadLink = json['downloadlink'];
    versionNumber = json['versionnumber'];
  }
}
