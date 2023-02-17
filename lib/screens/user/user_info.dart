import '/screens/user/edit_profile.dart';
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
  bool? userAnonymous;
  DocumentSnapshot? userDoc;
  String? month;
  int? year;

  @override
  void initState() {
    getData();
    rtData();
    super.initState();
  }

  void getData() async {
    User? user = _auth.currentUser;
    uid = user!.uid;

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
        });
      }
    }
  }

  void rtData() {
    // FirebaseFirestore.instance
    //     .collection('Users')
    //     .doc(uid)
    //     .snapshots()
    //     .listen((DocumentSnapshot documentSnapshot) {
    //   Map<String, dynamic> firestoreInfo =
    //       documentSnapshot as Map<String, dynamic>;

    //   setState(() {
    //     String money = firestoreInfo['earnings'];
    //     print(money);
    //   });
    // }).onError((e) => print(e));
  }

  @override
  Widget build(BuildContext context) {
    return userAnonymous == null
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
            : StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    const Center(
                      child: Text('Error occured :('),
                    );
                  }
                  return Container(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(80),
                                  child: snapshot.data!['profileId'] == null
                                      ? Image.asset(
                                          'assets/images/profiles/0.png',
                                          width: 80,
                                          height: 80,
                                        )
                                      : Image.asset(
                                          'assets/images/profiles/${snapshot.data!['profileId']}.png',
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
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          snapshot.data!['name'] ?? 'N/A',
                                          style: kTextHeaderStyle,
                                        ),
                                        Visibility(
                                            visible:
                                                snapshot.data!['verified'] ??
                                                    false,
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
                                  Text(
                                      '@${snapshot.data!['username'] ?? 'username'}')
                                ],
                              )
                            ],
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 15.0, bottom: 10),
                            child: ElevatedButton(
                                style: const ButtonStyle(
                                    minimumSize: MaterialStatePropertyAll(
                                        Size(250, 45))),
                                onPressed: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return const ProfileEdit();
                                  }));
                                },
                                child: const Text('Edit profile')),
                          ),
                          const Divider(
                            thickness: 1,
                            color: Colors.grey,
                          ),
                          userListTile('Email', snapshot.data!['email'] ?? '',
                              0, context),
                          userListTile(
                              'Joined',
                              '${DateFormat('MMMM').format(DateTime(0, DateTime.parse(snapshot.data!['joinedAt']).month))} ${DateTime.parse(snapshot.data!['joinedAt']).year}',
                              3,
                              context),
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
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                ((context) {
                                                      return const LandingScreen();
                                                    })));
                                                  });
                                                },
                                                child: const Text(
                                                  'Ok',
                                                  style: TextStyle(
                                                      color: Colors.red),
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
                },
              );
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
