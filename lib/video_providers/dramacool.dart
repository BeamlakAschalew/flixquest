import 'common.dart';

/// Dramacool provider

/// Dramacool search
class DramacoolSearch extends DCVASearch {
  DramacoolSearch.fromJson(Map<String, dynamic> json) : super.fromJson(json);
}

class DramacoolSearchEntry extends DCVASearchEntry {
  DramacoolSearchEntry.fromJson(Map<String, dynamic> json)
      : super.fromJson(json);
}

class DramacoolInfo extends DCVAInfo {
  DramacoolInfo.fromJson(Map<String, dynamic> json) : super.fromJson(json);
}

class DramacoolInfoEntries extends DCVAInfoEntries {
  DramacoolInfoEntries.fromJson(Map<String, dynamic> json)
      : super.fromJson(json);
}

class DramacoolStreamSources extends DCVAStreamSources {
  DramacoolStreamSources.fromJson(Map<String, dynamic> json)
      : super.fromJson(json);
}

class DramacoolVideoLinks extends RegularVideoLinks {
  DramacoolVideoLinks.fromJson(Map<String, dynamic> json)
      : super.fromJson(json);
}

class DramacoolSubLinks extends RegularSubtitleLinks {
  DramacoolSubLinks.fromJson(Map<String, dynamic> json) : super.fromJson(json);
}
