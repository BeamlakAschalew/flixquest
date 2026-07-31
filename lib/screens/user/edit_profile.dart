import 'package:easy_localization/easy_localization.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '/screens/user/delete_account.dart';
import '/screens/user/email_change.dart';
import '/screens/user/password_change.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '/provider/settings_provider.dart';
import '../../constants/app_constants.dart';
import '../../models/profile_image_list.dart';
import '../../services/globle_method.dart';
import '../../ui_components/app_ui_components.dart';

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({super.key});

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
  late final List<Profile> _profileList = profileImages.profile();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final GlobalMethods _globalMethods = GlobalMethods();
  DocumentSnapshot? userDoc;
  final ScrollController _profileScrollController = ScrollController();

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

      if (profileId != null && profileId! > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_profileScrollController.hasClients) {
            final double offset = (profileId! * (72.0 + 14.0)).clamp(
              0.0,
              _profileScrollController.position.maxScrollExtent,
            );
            _profileScrollController.jumpTo(offset);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _profileScrollController.dispose();
    super.dispose();
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
            if (mounted) {
              Provider.of<SettingsProvider>(context, listen: false)
                  .analytics
                  .trackProfileUpdated();
              Navigator.pop(context);
            }
          });
        } else if (username != _userName) {
          if (await checkIfDocExists(_userName) == true) {
            if (mounted) {
              GlobalMethods.showCustomScaffoldMessage(
                  SnackBar(
                    content: Text(
                      tr('username_exists'),
                      maxLines: 3,
                      style: kTextSmallBodyStyle,
                    ),
                    duration: const Duration(seconds: 4),
                  ),
                  context);
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
            if (mounted) {
              Navigator.pop(context);
            }
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
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('edit_profile')),
      ),
      body: AppResponsiveContent(
        maxWidth: 680,
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          Text(tr('profile_picture'),
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text(
                            tr('choose_profile'),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 8),
                              child: SizedBox(
                                height: 84,
                                child: ListView.separated(
                                  controller: _profileScrollController,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8),
                                  physics: const BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _profileList.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 14),
                                  itemBuilder: (context, index) {
                                    final profile = _profileList[index];
                                    final selected =
                                        profileId == profile.index;
                                    return Semantics(
                                      selected: selected,
                                      button: true,
                                      child: InkWell(
                                        customBorder: const CircleBorder(),
                                        onTap: () => setState(() {
                                          profileId = profile.index;
                                          selectedProfile = profile.index;
                                        }),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                              milliseconds: 180),
                                          width: 72,
                                          height: 72,
                                          padding: EdgeInsets.all(
                                              selected ? 3 : 0),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: selected
                                                ? Border.all(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    width: 3,
                                                  )
                                                : null,
                                          ),
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              ClipOval(
                                                child: Image.asset(
                                                  'assets/images/profiles/${profile.index}.png',
                                                  width: 66,
                                                  height: 66,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              if (selected)
                                                Positioned(
                                                  right: -3,
                                                  bottom: -3,
                                                  child: Container(
                                                    width: 24,
                                                    height: 24,
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Theme.of(
                                                                context)
                                                            .scaffoldBackgroundColor,
                                                        width: 2,
                                                      ),
                                                    ),
                                                    child: Icon(
                                                      PhosphorIcons.check(),
                                                      size: 15,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextFormField(
                              initialValue: name,
                              key: const ValueKey('name'),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return tr('name_empty');
                                } else if (value.length > 40 ||
                                    value.length < 2) {
                                  return tr('name_short_long');
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.next,
                              // onEditingComplete: () => FocusScope.of(context)
                              //     .requestFocus(_emailFocusNode),
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                errorMaxLines: 3,
                                filled: true,
                                prefixIcon: Icon(PhosphorIcons.user()),
                                labelText: tr('full_name'),
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
                                  return tr('username_empty');
                                } else if (value.length < 5 ||
                                    value.length > 30) {
                                  return tr('username_short_long');
                                } else if (!value
                                    .contains(RegExp('^[a-zA-Z0-9_]*'))) {
                                  return tr('invalid_username');
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                errorMaxLines: 3,
                                filled: true,
                                prefixIcon: Icon(PhosphorIcons.at()),
                                labelText: tr('username'),
                              ),
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
                                      WidgetStatePropertyAll(Size(250, 45))),
                              onPressed: () {
                                updateProfile();
                              },
                              child: Text(tr('confirm'))),
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
                                maximumSize: WidgetStateProperty.all(
                                    const Size(200, 60)),
                                shape: WidgetStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ))),
                            child: Text(tr('change_password')),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: ((context) {
                                return const EmailChangeScreen();
                              })));
                            },
                            style: ButtonStyle(
                                maximumSize: WidgetStateProperty.all(
                                    const Size(200, 60)),
                                shape: WidgetStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ))),
                            child: Text(tr('change_email')),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: ((context) {
                                return const DeleteAccountScreen();
                              })));
                            },
                            style: ButtonStyle(
                                maximumSize: WidgetStateProperty.all(
                                    const Size(200, 60)),
                                backgroundColor:
                                    const WidgetStatePropertyAll(Colors.red),
                                shape: WidgetStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ))),
                            child: Text(
                              tr('delete_account'),
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
