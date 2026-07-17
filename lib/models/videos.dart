class Videos {
  List<Results>? result;

  Videos({
    this.result,
  });

  Videos.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      result = [];
      json['results'].forEach((v) {
        result?.add(Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (result != null) {
      data['results'] = result?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Results {
  String? name;
  String? videoLink;
  Results({this.name, this.videoLink});
  Results.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    videoLink = json['key'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['key'] = videoLink;
    return data;
  }
}
