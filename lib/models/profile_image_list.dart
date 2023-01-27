class Profile {
  Profile({required this.index});
  final int index;
}

class ProfileImages {
  List<Profile> profile() {
    List<Profile> profileImages = [];
    for (int i = 0; i <= 80; i++) {
      profileImages.add(Profile(index: i));
    }
    return profileImages;
  }
}
