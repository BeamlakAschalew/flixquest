// ignore_for_file: use_build_context_synchronously
import '/flixquest_main.dart';
import '/functions/function.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '/constants/app_constants.dart';
import '/models/profile_image_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../provider/settings_provider.dart';
import '../../services/globle_method.dart';
import '../../ui_components/app_ui_components.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _passwordVerifyFocusNode = FocusNode();
  final ProfileImages profileImages = ProfileImages();

  int profileValue = 0;
  int selectedProfile = 0;
  bool _obscureText = true;
  String _emailAddress = '';
  String _password = '';
  String _fullName = '';
  String _userName = '';
  bool _isUserVerified = false;
  late DocumentSnapshot subscription;
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalMethods _globalMethods = GlobalMethods();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordVerifyFocusNode.dispose();
    _usernameFocusNode.dispose();
    super.dispose();
  }

  Future<bool> usernameExists(String username) async =>
      (await FirebaseFirestore.instance
              .collection('usernames')
              .where('username', isEqualTo: username.trim().toLowerCase())
              .get())
          .docs
          .isEmpty;

  void submitForm() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    var date = DateTime.now().toString();
    checkConnection().then((value) async {
      if (value) {
        if (isValid && mounted) {
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

            if (await checkIfDocExists(_userName) == true) {
              _globalMethods.authErrorHandle(
                  tr('username_exists').toString(), context);
              return;
            } else {
              await _auth.createUserWithEmailAndPassword(
                  email: _emailAddress.toLowerCase().trim(),
                  password: _password.trim());
              final User? user = _auth.currentUser;
              final uid = user!.uid;
              user.reload();
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .set({
                'id': uid,
                'name': _fullName,
                'email': _emailAddress,
                'profileId': selectedProfile,
                'username': _userName.trim().toLowerCase(),
                'verified': _isUserVerified,
                'joinedAt': date,
                'createdAt': Timestamp.now(),
              });
              await FirebaseFirestore.instance
                  .collection('usernames')
                  .doc(_userName)
                  .set({'uname': _userName.trim().toLowerCase(), 'uid': uid});

              await FirebaseFirestore.instance
                  .collection('bookmarks-v2.0')
                  .doc(uid)
                  .set({});

              subscription = await FirebaseFirestore.instance
                  .collection('bookmarks-v2.0')
                  .doc(uid)
                  .get();

              final docData = subscription.data() as Map<String, dynamic>;

              if (docData.containsKey('movies') == false) {
                await FirebaseFirestore.instance
                    .collection('bookmarks-v2.0')
                    .doc(uid)
                    .update(
                  {'movies': []},
                );
              }

              if (docData.containsKey('tvShows') == false) {
                await FirebaseFirestore.instance
                    .collection('bookmarks-v2.0')
                    .doc(uid)
                    .update(
                  {'tvShows': []},
                );
              }

              Navigator.canPop(context)
                  ? Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: ((context) {
                      final mixpanel =
                          Provider.of<SettingsProvider>(context).mixpanel;
                      mixpanel.track(
                        'Users Signup',
                      );
                      return const FlixQuestHomePage();
                    })))
                  : null;
            }
          } on FirebaseAuthException catch (error) {
            if (error.code == 'weak-password') {
              _globalMethods.authErrorHandle(tr('weak_password'), context);
            } else if (error.code == 'email-already-in-use') {
              _globalMethods.authErrorHandle(tr('email_exists'), context);
            } else if (error.code == 'invalid-email') {
              _globalMethods.authErrorHandle(tr('invalid_email'), context);
            } else if (error.code == 'operation-not-allowed') {
              _globalMethods.authErrorHandle(
                  tr('operation_not_allowed'), context);
            }
          } catch (e) {
            _globalMethods.authErrorHandle(e.toString(), context);
          } finally {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          }
        }
      } else {
        GlobalMethods.showCustomScaffoldMessage(
            SnackBar(
              content: Text(
                tr('check_connection'),
                maxLines: 3,
                style: kTextSmallBodyStyle,
              ),
              duration: const Duration(seconds: 3),
            ),
            context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('signup')),
      ),
      body: AppResponsiveContent(
        maxWidth: 720,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 30),
                child: Row(
                  children: [
                    GestureDetector(
                      onDoubleTap: () {
                        setState(() {
                          _isUserVerified = true;
                        });
                      },
                      child: Hero(
                        tag: 'logo_shadow',
                        child: SizedBox(
                            width: 90,
                            height: 90,
                            child: Image.asset('assets/images/logo.png')),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        tr('signup_to_sync'),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 4,
                        style: kTextSmallHeaderStyle,
                      ),
                    )
                  ],
                ),
              ),
              Card(
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tr('choose_profile'),
                                  style: const TextStyle(
                                    fontFamily: 'FigtreeSB',
                                    fontSize: 20,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  height: 88,
                                  child: ListView.separated(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    physics: const BouncingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: profileImages.profile().length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: 14),
                                    itemBuilder: (context, index) {
                                      final profile =
                                          profileImages.profile()[index];
                                      final selected =
                                          profileValue == profile.index;
                                      return InkWell(
                                        customBorder: const CircleBorder(),
                                        onTap: () => setState(() {
                                          profileValue = profile.index;
                                          selectedProfile = profile.index;
                                        }),
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 180),
                                          width: 72,
                                          padding:
                                              EdgeInsets.all(selected ? 3 : 0),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: selected
                                                ? Border.all(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    width: 3)
                                                : null,
                                          ),
                                          child: ClipOval(
                                            child: Image.asset(
                                              'assets/images/profiles/${profile.index}.png',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: TextFormField(
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
                                onEditingComplete: () => FocusScope.of(context)
                                    .requestFocus(_emailFocusNode),
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  errorMaxLines: 3,
                                  filled: true,
                                  prefixIcon: const Icon(FontAwesomeIcons.user),
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
                                key: const ValueKey('email'),
                                focusNode: _emailFocusNode,
                                validator: (value) {
                                  if (value!.isEmpty || !value.contains('@')) {
                                    return tr('invalid_email');
                                  }
                                  return null;
                                },
                                textInputAction: TextInputAction.next,
                                onEditingComplete: () => FocusScope.of(context)
                                    .requestFocus(_usernameFocusNode),
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                    errorMaxLines: 3,
                                    filled: true,
                                    prefixIcon:
                                        const Icon(FontAwesomeIcons.envelope),
                                    labelText: tr('email_address')),
                                onSaved: (value) {
                                  _emailAddress = value!;
                                },
                                onChanged: (value) {
                                  _emailAddress = value;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: TextFormField(
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
                                focusNode: _usernameFocusNode,
                                textInputAction: TextInputAction.next,
                                onEditingComplete: () => FocusScope.of(context)
                                    .requestFocus(_passwordFocusNode),
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                    errorMaxLines: 3,
                                    filled: true,
                                    prefixIcon: const Icon(FontAwesomeIcons.at),
                                    labelText: tr('username')),
                                onSaved: (value) {
                                  _userName = value!;
                                },
                                onChanged: (value) {
                                  _userName = value;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: TextFormField(
                                key: const ValueKey('Password'),
                                validator: (value) {
                                  if (value!.isEmpty || value.length < 7) {
                                    return tr('invalid_password');
                                  } else if (value == '12345678' ||
                                      value == 'qwertyuiop' ||
                                      value == 'password') {
                                    return tr('lame_password');
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.visiblePassword,
                                focusNode: _passwordFocusNode,
                                obscureText: _obscureText,
                                onEditingComplete: () => FocusScope.of(context)
                                    .requestFocus(_passwordVerifyFocusNode),
                                decoration: InputDecoration(
                                    errorMaxLines: 3,
                                    filled: true,
                                    prefixIcon:
                                        const Icon(FontAwesomeIcons.lock),
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                      child: Icon(_obscureText
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                    ),
                                    labelText: tr('enter_password')),
                                onSaved: (value) {
                                  _password = value!;
                                },
                                onChanged: (value) {
                                  _password = value;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: TextFormField(
                                key: const ValueKey('VerifyPassword'),
                                validator: (value) {
                                  if (value != _password) {
                                    return tr('password_mismatch');
                                  }
                                  return null;
                                },
                                obscureText: _obscureText,
                                keyboardType: TextInputType.visiblePassword,
                                focusNode: _passwordVerifyFocusNode,
                                decoration: InputDecoration(
                                    errorMaxLines: 3,
                                    filled: true,
                                    prefixIcon:
                                        const Icon(FontAwesomeIcons.lock),
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                      child: Icon(_obscureText
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                    ),
                                    labelText: tr('repeat_password')),
                                // onSaved: (value) {
                                //   _passwordVerify = value!;
                                // }
                                // onChanged: (value) {
                                //   _passwordVerify = value;
                                // },
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _isLoading
                                    ? const CircularProgressIndicator()
                                    : ElevatedButton(
                                        style: ButtonStyle(
                                            minimumSize:
                                                WidgetStateProperty.all(
                                                    const Size(150, 50)),
                                            shape: WidgetStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                            )),
                                        onPressed: submitForm,
                                        child: Text(
                                          tr('sign_up'),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 17),
                                        )),
                              ],
                            ),
                          ],
                        ))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
