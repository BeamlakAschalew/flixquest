class PersonList {
  int? page;
  int? totalMovies;
  int? totalPages;
  List<Person>? person;

  PersonList({this.page, this.totalMovies, this.totalPages, this.person});

  PersonList.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    totalMovies = json['total_results'];
    totalPages = json['total_pages'];
    if (json['results'] != null) {
      person = [];
      json['results'].forEach((v) {
        person!.add(Person.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = page;
    data['total_results'] = totalMovies;
    data['total_pages'] = totalPages;
    if (person != null) {
      data['results'] = person!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Person {
  String? department;
  String? profilePath;
  String? name;
  int? id;
  List<Cast>? cast;
  List<Crew>? crew;
  Person(
      {this.department,
      this.id,
      this.name,
      this.profilePath,
      this.cast,
      this.crew});

  Person.fromJson(Map<String, dynamic> json) {
    department = json['known_for_department'];
    id = json['id'];
    profilePath = json['profile_path'];
    name = json['name'];
    if (json['cast'] != null) {
      cast = [];
      json['cast'].forEach((v) {
        cast?.add(Cast.fromJson(v));
      });
    }
    if (json['crew'] != null) {
      crew = [];
      json['crew'].forEach((v) {
        crew?.add(Crew.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['known_for_department'] = department;
    data['id'] = id;
    data['name'] = name;
    data['profile_path'] = profilePath;
    if (cast != null) {
      data['cast'] = cast?.map((v) => v.toJson()).toList();
    }
    if (crew != null) {
      data['crew'] = crew?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Cast {
  int? castId;
  String? character;
  String? creditId;
  int? gender;
  int? id;
  String? name;
  int? order;
  String? profilePath;
  String? department;
  List<Roles>? roles;

  Cast(
      {this.castId,
      this.character,
      this.creditId,
      this.gender,
      this.id,
      this.name,
      this.order,
      this.profilePath,
      this.department,
      this.roles});

  Cast.fromJson(Map<String, dynamic> json) {
    castId = json['cast_id'];
    character = json['character'];
    creditId = json['credit_id'];
    gender = json['gender'];
    id = json['id'];
    name = json['name'];
    order = json['order'];
    profilePath = json['profile_path'];
    department = json['known_for_department'];
    if (json['roles'] != null) {
      roles = [];
      json['roles'].forEach((v) {
        roles?.add(Roles.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cast_id'] = castId;
    data['character'] = character;
    data['credit_id'] = creditId;
    data['gender'] = gender;
    data['id'] = id;
    data['name'] = name;
    data['order'] = order;
    data['profile_path'] = profilePath;
    data['known_for_department'] = department;
    if (roles != null) {
      data['roles'] = roles?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Roles {
  String? character;
  int? episodeCount;
  Roles({this.character, this.episodeCount});
  Roles.fromJson(Map<String, dynamic> json) {
    character = json['character'];
    episodeCount = json['episode_count'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['character'] = character;
    data['episode_count'] = episodeCount;
    return data;
  }
}

class Crew {
  String? creditId;
  String? department;
  int? gender;
  int? id;
  String? job;
  String? name;
  String? profilePath;

  Crew(
      {this.creditId,
      this.department,
      this.gender,
      this.id,
      this.job,
      this.name,
      this.profilePath});

  Crew.fromJson(Map<String, dynamic> json) {
    creditId = json['credit_id'];
    department = json['department'];
    gender = json['gender'];
    id = json['id'];
    job = json['job'];
    name = json['name'];
    profilePath = json['profile_path'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['credit_id'] = creditId;
    data['department'] = department;
    data['gender'] = gender;
    data['id'] = id;
    data['job'] = job;
    data['name'] = name;
    data['profile_path'] = profilePath;
    return data;
  }
}

class PersonDetails {
  bool? isAdult;
  String? biography;
  String? birthday;
  int? id;
  String? birthPlace;
  String? profilePath;
  String? department;
  String? name;
  PersonDetails(
      {this.biography,
      this.birthPlace,
      this.birthday,
      this.department,
      this.id,
      this.isAdult,
      this.name,
      this.profilePath});
  PersonDetails.fromJson(Map<String, dynamic> json) {
    isAdult = json['adult'];
    biography = json['biography'];
    birthday = json['birthday'];
    id = json['id'];
    birthPlace = json['place_of_birth'];
    profilePath = json['profile_path'];
    department = json['known_for_department'];
    name = json['name'];
  }
}
