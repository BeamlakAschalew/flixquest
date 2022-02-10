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
