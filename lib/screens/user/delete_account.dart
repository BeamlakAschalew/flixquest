import 'package:cinemax/screens/common/landing_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../provider/settings_provider.dart';
import '../../services/globle_method.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({Key? key}) : super(key: key);

  @override
  DeleteAccountScreenState createState() => DeleteAccountScreenState();
}

class DeleteAccountScreenState extends State<DeleteAccountScreen> {
  String confirmationText = '';
  User? user;
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalMethods _globalMethods = GlobalMethods();
  bool _isLoading = false;
  DocumentSnapshot? userDoc;
  String? uid;
  String? username;
  final FocusNode deleteFN = FocusNode();

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
      username = userDoc!.get('username');
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

        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .delete()
            .then((value) async {
          await FirebaseFirestore.instance
              .collection('bookmarks')
              .doc(uid)
              .delete()
              .then((value) async {
            await FirebaseFirestore.instance
                .collection('bookmarks-v2.0')
                .doc(uid)
                .delete()
                .then((value) async {
              await FirebaseFirestore.instance
                  .collection('usernames')
                  .doc(username)
                  .delete()
                  .then((value) async {
                await user!.delete().then((value) async {
                  await Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return const LandingScreen();
                  })).then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Your account was deleted successfully. We are sad to see you go :(, or are we? ;)',
                          maxLines: 3,
                          style: kTextSmallBodyStyle,
                        ),
                        duration: Duration(seconds: 4),
                      ),
                    );
                  });
                });
              });
            });
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
        appBar: AppBar(title: const Text('Delete account')),
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
                        'Delete account',
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Text(
                      'Note: deleting your account will also delete your synced movies and TV shows from the server.\nType "CONFIRM" (all caps) and press "Delete account" to delete your account.\nIf the process is stuck, you need to logout and login and then try again.',
                      textAlign: TextAlign.center,
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
                                key: const ValueKey('confirmation'),
                                validator: (value) {
                                  if (value != 'CONFIRM') {
                                    return 'Type: \'Confirm\' or \'CONFIRM\' to delete your account, if you are not deleting your account, you can go back.';
                                  }
                                  return null;
                                },
                                focusNode: deleteFN,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                    errorMaxLines: 3,
                                    border: const UnderlineInputBorder(),
                                    filled: true,
                                    prefixIcon:
                                        const Icon(Icons.text_fields_sharp),
                                    labelText:
                                        'Type \'CONFIRM\' to delete your account',
                                    fillColor: Theme.of(context)
                                        .colorScheme
                                        .background),
                                onSaved: (value) {
                                  setState(() {
                                    confirmationText = value!;
                                  });
                                },
                                onChanged: (value) {
                                  setState(() {
                                    confirmationText = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              child: _isLoading
                                  ? const CircularProgressIndicator()
                                  : ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              const MaterialStatePropertyAll(
                                                  Colors.red),
                                          minimumSize:
                                              const MaterialStatePropertyAll(
                                                  Size(200, 50)),
                                          shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          )),
                                      onPressed: () {
                                        _submitForm();
                                      },
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Delete account',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 17),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Icon(
                                            FontAwesomeIcons.trash,
                                            size: 18,
                                          )
                                        ],
                                      )),
                            ),
                          ],
                        ),
                      ),
                    )
                  ]))));
  }
}
