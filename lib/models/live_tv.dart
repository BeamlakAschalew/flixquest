class Channels {
  String? baseUrl;
  String? trailingUrl;
  String? referrer;
  String? userAgent;
  List<Channel>? channels;
  Channels.fromJson(Map<String, dynamic> json) {
    baseUrl = json['base_url'];
    trailingUrl = json['trailing_url'];
    referrer = json['referrer'];
    userAgent = json['user_agent'];
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
  int? channelId;
  Channel({this.channelId, this.channelName});

  Channel.fromJson(Map<String, dynamic> json) {
    channelName = json['channel_name'];
    channelId = json['id'];
  }
}
