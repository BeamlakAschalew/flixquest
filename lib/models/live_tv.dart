class CatImage {
  CatImage(
      {required this.categoryName,
      required this.imagePath,
      required this.urlKey});
  String categoryName;
  String imagePath;
  String urlKey;
}

class ChannelsList {
  int? channelCount;
  List<Channel>? channels;
  ChannelsList({this.channels, this.channelCount});
  ChannelsList.fromJson(Map<String, dynamic> json) {
    channelCount = json['channel_count'];
    if (json['channels'] != null) {
      channels = [];
      json['channels'].forEach((v) {
        channels!.add(Channel.fromJson(v));
      });
    }
  }
}

class Channel {
  String? channelName;
  String? channelLogo;
  List<ChannelStream>? channelStream;
  Channel({this.channelLogo, this.channelName, this.channelStream});

  Channel.fromJson(Map<String, dynamic> json) {
    channelName = json['channel_name'];
    channelLogo = json['channel_logo'];
    if (json['channel_stream'] != null) {
      channelStream = [];
      json['channel_stream'].forEach((v) {
        channelStream!.add(ChannelStream.fromJson(v));
      });
    }
  }
}

class ChannelStream {
  String? videoQuality;
  String? streamLink;
  ChannelStream({this.streamLink, this.videoQuality});
  ChannelStream.fromJson(Map<String, dynamic> json) {
    videoQuality = json['video_quality'];
    streamLink = json['stream_link'];
  }
}
