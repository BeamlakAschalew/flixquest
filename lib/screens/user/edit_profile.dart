import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '/provider/settings_provider.dart';
import '/screens/user/delete_account.dart';
import '/screens/user/email_change.dart';
import '/screens/user/password_change.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../models/profile_image_list.dart';
import '../../services/globle_method.dart';

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({Key? key}) : super(key: key);

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firebaseInstance = FirebaseFirestore.instance;
  String? uid;
  String? userId;
  String? userEmail;
  bool? isVerified;
  String? name;
  String? email;
  String? joinedAt;
  Timestamp? createdAt;
  int? profileId;
  bool? userAnonymous;
  String? username;
  String? month;
  int? year;
  int? selectedProfile;
  String _fullName = '';
  String _userName = '';
  final ProfileImages profileImages = ProfileImages();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final GlobalMethods _globalMethods = GlobalMethods();
  DocumentSnapshot? userDoc;

  void getData() async {
    User? user = _auth.currentUser;
    uid = user!.uid;

    if (user.isAnonymous) {
      setState(() {
        userAnonymous = true;
      });
    } else {
      userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      setState(() {
        userAnonymous = false;
        name = userDoc!.get('name');
        email = user.email;
        joinedAt = userDoc!.get('joinedAt');
        month = DateFormat('MMMM')
            .format(DateTime(0, DateTime.parse(joinedAt!).month));
        year = DateTime.parse(joinedAt!).year;
        isVerified = userDoc!.get('verified');
        profileId = userDoc!.get('profileId');
        username = userDoc!.get('username');
        createdAt = userDoc!.get('createdAt');
        userEmail = userDoc!.get('email');
        userId = userDoc!.get('id');
      });
    }
  }

  void updateProfile() async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
      try {
        setState(() {
          _isLoading = true;
        });

        /// Check If Document Exists
        Future<bool> checkIfDocExists(String docId) async {
          try {
            // Get reference to Firestore collection
            var collectionRef =
                FirebaseFirestore.instance.collection('usernames');

            var doc = await collectionRef.doc(docId).get();
            return doc.exists;
          } catch (e) {
            rethrow;
          }
        }

        if (username == _userName) {
          await FirebaseFirestore.instance.collection('users').doc(uid).update({
            'createdAt': createdAt,
            'email': userEmail,
            'id': userId,
            'joinedAt': joinedAt,
            'name': _fullName,
            'profileId': profileId,
            'username': username!.trim().toLowerCase(),
            'verified': isVerified
          }).then((value) {
            Navigator.pop(context);
          });
        } else if (username != _userName) {
          if (await checkIfDocExists(_userName) == true) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    tr("username_exists"),
                    maxLines: 3,
                    style: kTextSmallBodyStyle,
                  ),
                  duration: const Duration(seconds: 4),
                ),
              );
            }
            setState(() {
              username = userDoc!.get('username');
            });
            return;
          }
          await firebaseInstance
              .collection('usernames')
              .doc(username)
              .get()
              .then((value) {
            if (value.exists) {
              firebaseInstance
                  .collection('usernames')
                  .doc(_userName)
                  .set({'uid': uid, 'uname': _userName}).then((value) {
                firebaseInstance.collection('usernames').doc(username).delete();
              });
            }
          });
          await FirebaseFirestore.instance.collection('users').doc(uid).update({
            'createdAt': createdAt,
            'email': userEmail,
            'id': userId,
            'joinedAt': joinedAt,
            'name': _fullName,
            'profileId': profileId,
            'username': _userName.trim().toLowerCase(),
            'verified': isVerified
          }).then((value) {
            Navigator.pop(context);
          });
        }
      } catch (e) {
        if (mounted) {
          _globalMethods.authErrorHandle(e.toString(), context);
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF171717) : const Color(0xFFdedede),
      appBar: AppBar(
        title: Text(tr("edit_profile")),
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        child: userAnonymous == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr("profile_picture"),
                            style: const TextStyle(
                              fontFamily: 'PoppinsSB',
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 100,
                            child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: profileImages
                                    .profile()
                                    .map((Profile profile) => ChoiceChip(
                                          backgroundColor: Colors.transparent,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(150))),
                                          selectedColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          label: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(200),
                                            child: Container(
                                              // margin: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: Colors.black,
                                              ),
                                              height: 60,
                                              width: 60,
                                              child: Image.asset(
                                                  'assets/images/profiles/${profile.index}.png',
                                                  fit: BoxFit.cover),
                                            ),
                                          ),
                                          selected: profileId == profile.index,
                                          onSelected: (bool selected) {
                                            setState(() {
                                              profileId = (selected
                                                  ? profile.index
                                                  : null)!;
                                              selectedProfile = profile.index;
                                            });
                                          },
                                        ))
                                    .toList()),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextFormField(
                              initialValue: name,
                              key: const ValueKey('name'),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return tr("name_empty");
                                } else if (value.length > 40 ||
                                    value.length < 2) {
                                  return tr("name_short_long");
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.next,
                              // onEditingComplete: () => FocusScope.of(context)
                              //     .requestFocus(_emailFocusNode),
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                errorMaxLines: 3,
                                border: const UnderlineInputBorder(),
                                filled: true,
                                prefixIcon: const Icon(FontAwesomeIcons.user),
                                labelText: tr("full_name"),
                                fillColor:
                                    Theme.of(context).colorScheme.background,
                              ),
                              onSaved: (value) {
                                _fullName = value!;
                              },
                              onChanged: (value) {
                                _fullName = value;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextFormField(
                              initialValue: username,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp('^[a-zA-Z0-9_]*')),
                              ],
                              key: const ValueKey('username'),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return tr("username_empty");
                                } else if (value.length < 5 ||
                                    value.length > 30) {
                                  return tr("username_short_long");
                                } else if (!value
                                    .contains(RegExp('^[a-zA-Z0-9_]*'))) {
                                  return tr("invalid_username");
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                  errorMaxLines: 3,
                                  border: const UnderlineInputBorder(),
                                  filled: true,
                                  prefixIcon: const Icon(FontAwesomeIcons.at),
                                  labelText: tr("username"),
                                  fillColor:
                                      Theme.of(context).colorScheme.background),
                              onSaved: (value) {
                                _userName = value!;
                              },
                              onChanged: (value) {
                                _userName = value;
                              },
                            ),
                          ),
                        ],
                      ),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              style: const ButtonStyle(
                                  minimumSize:
                                      MaterialStatePropertyAll(Size(250, 45))),
                              onPressed: () {
                                updateProfile();
                              },
                              child: Text(tr("confirm"))),
                      const SizedBox(
                        height: 40,
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        spacing: 15,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: ((context) {
                                return const PasswordChangeScreen();
                              })));
                            },
                            style: ButtonStyle(
                                maximumSize: MaterialStateProperty.all(
                                    const Size(200, 60)),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ))),
                            child: Text(tr("change_password")),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: ((context) {
                                return const EmailChangeScreen();
                              })));
                            },
                            style: ButtonStyle(
                                maximumSize: MaterialStateProperty.all(
                                    const Size(200, 60)),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ))),
                            child: Text(tr("change_email")),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: ((context) {
                                return const DeleteAccountScreen();
                              })));
                            },
                            style: ButtonStyle(
                                maximumSize: MaterialStateProperty.all(
                                    const Size(200, 60)),
                                backgroundColor:
                                    const MaterialStatePropertyAll(Colors.red),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ))),
                            child: Text(
                              tr("delete_account"),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
