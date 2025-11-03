class Channels {
  List<Channel>? channels;

  Channels({this.channels});

  Channels.fromJson(List<dynamic> json) {
    channels = [];
    for (var v in json) {
      channels!.add(Channel.fromJson(v));
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'channels': channels?.map((v) => v.toJson()).toList(),
    };
  }
}

class Channel {
  String? name;
  int? streamId;
  String? streamIcon;
  String? directSource;
  String? videoUrl;

  Channel({
    this.name,
    this.streamId,
    this.streamIcon,
    this.directSource,
    this.videoUrl,
  });

  Channel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    streamId = json['stream_id'];
    streamIcon = json['stream_icon'];
    directSource = json['direct_source'];
    videoUrl = json['video_url'];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'stream_id': streamId,
      'stream_icon': streamIcon,
      'direct_source': directSource,
      'video_url': videoUrl,
    };
  }

  // For database storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'stream_id': streamId,
      'stream_icon': streamIcon,
      'direct_source': directSource,
      'video_url': videoUrl,
    };
  }

  factory Channel.fromMap(Map<String, dynamic> map) {
    return Channel(
      name: map['name'],
      streamId: map['stream_id'],
      streamIcon: map['stream_icon'],
      directSource: map['direct_source'],
      videoUrl: map['video_url'],
    );
  }
}
