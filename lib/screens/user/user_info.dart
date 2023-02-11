import '/constants/app_constants.dart';
import '/screens/common/landing_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class UserInfo extends StatefulWidget {
  const UserInfo({Key? key}) : super(key: key);

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? uid;
  String? name;
  String? email;
  String? joinedAt;
  bool? isVerified;
  int? profileId;
  bool? userAnonymous;
  String? username;
  String? month;
  int? year;

  @override
  void initState() {
    getData();
    super.initState();
  }

  void getData() async {
    User? user = _auth.currentUser;
    uid = user!.uid;

    DocumentSnapshot? userDoc;

    if (user.isAnonymous) {
      if (mounted) {
        setState(() {
          userAnonymous = true;
        });
      }
    } else {
      userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (mounted) {
        setState(() {
          userAnonymous = false;
          name = userDoc!.get('name');
          email = user.email;
          joinedAt = userDoc.get('joinedAt');
          month = DateFormat('MMMM')
              .format(DateTime(0, DateTime.parse(joinedAt!).month));
          year = DateTime.parse(joinedAt!).year;
          isVerified = userDoc.get('verified');
          profileId = userDoc.get('profileId');
          username = userDoc.get('username');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8),
        child: userAnonymous == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : userAnonymous == true
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'This current account is anonymous, signup or login to access this page',
                          textAlign: TextAlign.center,
                        ),
                        ElevatedButton(
                            onPressed: () async {
                              await _auth.signOut().then((value) {
                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: ((context) {
                                  return const LandingScreen();
                                })));
                              });
                            },
                            child: const Text('Login/Signup'))
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(80),
                              child: Image.asset(
                                'assets/images/profiles/$profileId.png',
                                width: 80,
                                height: 80,
                              )),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                  spacing: 5,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      name!,
                                      style: kTextHeaderStyle,
                                    ),
                                    Visibility(
                                        visible: isVerified!,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: SvgPicture.asset(
                                            'assets/images/checkmark.svg',
                                            width: 20,
                                            height: 20,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ))
                                  ]),
                              Text('@$username')
                            ],
                          )
                        ],
                      ),
                      const Divider(
                        thickness: 1,
                        color: Colors.grey,
                      ),
                      userListTile('Email', email ?? '', 0, context),
                      userListTile('Joined', '$month $year', 3, context),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Theme.of(context).splashColor,
                          child: ListTile(
                            onTap: () async {
                              // Navigator.canPop(context)? Navigator.pop(context):null;
                              showDialog(
                                  context: context,
                                  builder: (BuildContext ctx) {
                                    return AlertDialog(
                                      title: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('Sign out'),
                                      ),
                                      content: const Text(
                                          'Do you want to Sign out?'),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Cancel')),
                                        TextButton(
                                            onPressed: () async {
                                              await _auth
                                                  .signOut()
                                                  .then((value) {
                                                Navigator.pushReplacement(
                                                    context, MaterialPageRoute(
                                                        builder: ((context) {
                                                  return const LandingScreen();
                                                })));
                                              });
                                            },
                                            child: const Text(
                                              'Ok',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ))
                                      ],
                                    );
                                  });
                            },
                            title: const Text('Logout'),
                            leading: Icon(
                              Icons.exit_to_app_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ));
  }

  final List<IconData> _userTileIcons = [
    Icons.email,
    Icons.phone,
    Icons.local_shipping,
    Icons.watch_later,
    Icons.exit_to_app_rounded
  ];

  Widget userListTile(
      String title, String subTitle, int index, BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Theme.of(context).splashColor,
        child: ListTile(
          onTap: () {},
          title: Text(title),
          subtitle: Text(subTitle),
          leading: Icon(
            _userTileIcons[index],
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget userTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
      ),
    );
  }
}
