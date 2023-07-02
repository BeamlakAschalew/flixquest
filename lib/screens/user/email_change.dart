import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../constants/app_constants.dart';
import '../../provider/settings_provider.dart';
import '../../services/globle_method.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailChangeScreen extends StatefulWidget {
  const EmailChangeScreen({Key? key}) : super(key: key);

  @override
  EmailChangeScreenState createState() => EmailChangeScreenState();
}

class EmailChangeScreenState extends State<EmailChangeScreen> {
  String currentEmail = '';
  String newEmail = '';
  User? user;
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalMethods _globalMethods = GlobalMethods();
  bool _isLoading = false;
  final FocusNode _newEmailFocusNode = FocusNode();
  final FocusNode _emailVerifyFocusNode = FocusNode();
  Timestamp? createdAt;
  DocumentSnapshot? userDoc;
  String? uid;
  String? userId;
  String? userEmail;
  bool? isVerified;
  String? name;
  String? email;
  String? joinedAt;
  int? profileId;
  bool? userAnonymous;
  String? username;
  String? month;
  int? year;
  int? selectedProfile;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    User? user = _auth.currentUser;
    uid = user!.uid;
    userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    setState(() {
      name = userDoc!.get('name');
      email = userDoc!.get('email');
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

  void _submitForm() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      setState(() {
        _isLoading = true;
      });
      _formKey.currentState!.save();
      try {
        user = _auth.currentUser;

        await user!.updateEmail(newEmail).then((value) async {
          await FirebaseFirestore.instance.collection('users').doc(uid).update({
            'createdAt': createdAt,
            'email': newEmail,
            'id': userId,
            'joinedAt': joinedAt,
            'name': name,
            'profileId': profileId,
            'username': username!.trim().toLowerCase(),
            'verified': isVerified
          }).then((value) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Your email has been changed successfully :)',
                  maxLines: 3,
                  style: kTextSmallBodyStyle,
                ),
                duration: Duration(seconds: 4),
              ),
            );
          });
        });
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-mismatch') {
          _globalMethods.authErrorHandle(
              'The given email and password doesn\'t correspond to this user.',
              context);
        } else if (e.code == 'user-not-found') {
          _globalMethods.authErrorHandle(
              'A user was not found with this email address.', context);
        } else if (e.code == 'invalid-credential') {
          _globalMethods.authErrorHandle(
              'The password or email enterd is invalid.', context);
        } else if (e.code == 'invalid-email') {
          _globalMethods.authErrorHandle(
              'The email entered is invalid.', context);
        } else if (e.code == 'wrong-password:') {
          _globalMethods.authErrorHandle(
              'The password entered is wrong.', context);
        } else if (e.code == 'weak-password') {
          _globalMethods.authErrorHandle(
              'The password entered is too weak, try another one.', context);
        } else if (e.code == 'requires-recent-login') {
          _globalMethods.authErrorHandle(
              'You have been signed with this account for too long, re-authenticate to change your password. Logout and Signin to change your password.',
              context);
        }
        // print('error occured ${error.message}');
      } finally {
        setState(() {
          _isLoading = false;
        });

        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF171717) : const Color(0xFFdedede),
      appBar: AppBar(title: const Text('Change email')),
      body: userDoc == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 80,
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Email change',
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'If the process is stuck, you need to logout and login and then try again.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: TextFormField(
                                key: const ValueKey('email'),
                                focusNode: _newEmailFocusNode,
                                validator: (value) {
                                  if (value!.isEmpty || !value.contains('@')) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                                textInputAction: TextInputAction.next,
                                onEditingComplete: () => FocusScope.of(context)
                                    .requestFocus(_emailVerifyFocusNode),
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                    errorMaxLines: 3,
                                    border: const UnderlineInputBorder(),
                                    filled: true,
                                    prefixIcon: const Icon(Icons.email),
                                    labelText: 'Enter new email Address',
                                    fillColor: Theme.of(context)
                                        .colorScheme
                                        .background),
                                onSaved: (value) {
                                  newEmail = value!;
                                },
                                onChanged: (value) {
                                  newEmail = value;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: TextFormField(
                                key: const ValueKey('verifyEmail'),
                                validator: (value) {
                                  if (value != newEmail) {
                                    return 'The emails entered don\'t match';
                                  }
                                  return null;
                                },
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                    errorMaxLines: 3,
                                    border: const UnderlineInputBorder(),
                                    filled: true,
                                    prefixIcon: const Icon(Icons.mail),
                                    labelText: 'Repeat new email',
                                    fillColor: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              style: ButtonStyle(
                                  minimumSize: const MaterialStatePropertyAll(
                                      Size(200, 50)),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  )),
                              onPressed: () {
                                _submitForm();
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Change email',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Icon(
                                    Icons.refresh_outlined,
                                    size: 18,
                                  )
                                ],
                              )),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
