class WatchProviders {
  List<Buy>? buy;
  List<FlatRate>? flatRate;
  List<Rent>? rent;
  List<ADS>? ads;
  WatchProviders({this.buy, this.flatRate, this.rent, this.ads});

  WatchProviders.fromJson(Map<String, dynamic> json) {
    if (json['results']['US'] == null) {
      buy = null;
      rent = null;
      flatRate = null;
      ads = null;
    } else {
      if (json['results']['US']['buy'] != null) {
        buy = [];
        json['results']['US']['buy'].forEach((v) {
          buy?.add(Buy.fromJson(v));
        });
      }
      if (json['results']['US']['flatrate'] != null) {
        flatRate = [];
        json['results']['US']['flatrate'].forEach((v) {
          flatRate?.add(FlatRate.fromJson(v));
        });
      }
      if (json['results']['US']['rent'] != null) {
        rent = [];
        json['results']['US']['rent'].forEach((v) {
          rent?.add(Rent.fromJson(v));
        });
      }
      if (json['results']['US']['ads'] != null) {
        ads = [];
        json['results']['US']['ads'].forEach((v) {
          ads?.add(ADS.fromJson(v));
        });
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (buy != null) {
      data['results']['US']['buy'] = buy?.map((v) => v.toJson()).toList();
    }
    if (flatRate != null) {
      data['results']['US']['flatrate'] =
          flatRate?.map((v) => v.toJson()).toList();
    }
    if (rent != null) {
      data['results']['US']['rent'] = rent?.map((v) => v.toJson()).toList();
    }
    if (rent != null) {
      data['results']['US']['ads'] = ads?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Buy {
  String? logoPath;
  String? providerName;
  int? providerId;
  Buy({this.logoPath, this.providerId, this.providerName});
  Buy.fromJson(Map<String, dynamic> json) {
    logoPath = json['logo_path'];
    providerName = json['provider_name'];
    providerId = json['provider_id'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['logo_path'] = logoPath;
    data['provider_name'] = providerName;
    data['provider_id'] = providerId;
    return data;
  }
}

class FlatRate {
  String? logoPath;
  String? providerName;
  int? providerId;
  FlatRate({this.logoPath, this.providerId, this.providerName});
  FlatRate.fromJson(Map<String, dynamic> json) {
    logoPath = json['logo_path'];
    providerName = json['provider_name'];
    providerId = json['provider_id'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['logo_path'] = logoPath;
    data['provider_name'] = providerName;
    data['provider_id'] = providerId;
    return data;
  }
}

class Rent {
  String? logoPath;
  String? providerName;
  int? providerId;
  Rent({this.logoPath, this.providerId, this.providerName});
  Rent.fromJson(Map<String, dynamic> json) {
    logoPath = json['logo_path'];
    providerName = json['provider_name'];
    providerId = json['provider_id'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['logo_path'] = logoPath;
    data['provider_name'] = providerName;
    data['provider_id'] = providerId;
    return data;
  }
}

class ADS {
  String? logoPath;
  String? providerName;
  int? providerId;
  ADS({this.logoPath, this.providerId, this.providerName});
  ADS.fromJson(Map<String, dynamic> json) {
    logoPath = json['logo_path'];
    providerName = json['provider_name'];
    providerId = json['provider_id'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['logo_path'] = logoPath;
    data['provider_name'] = providerName;
    data['provider_id'] = providerId;
    return data;
  }
}
