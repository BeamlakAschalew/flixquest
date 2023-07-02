import 'package:provider/provider.dart';

import '../../constants/app_constants.dart';
import '../../provider/settings_provider.dart';
import '../../services/globle_method.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PasswordChangeScreen extends StatefulWidget {
  const PasswordChangeScreen({Key? key}) : super(key: key);

  @override
  PasswordChangeScreenState createState() => PasswordChangeScreenState();
}

class PasswordChangeScreenState extends State<PasswordChangeScreen> {
  String currentPassword = '';
  String newPassword = '';
  bool _obscureText = true;
  User? user;
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalMethods _globalMethods = GlobalMethods();
  bool _isLoading = false;
  final FocusNode _newPasswordFocusNode = FocusNode();
  final FocusNode _passwordVerifyFocusNode = FocusNode();
  String? _emailAddress;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    User? user = _auth.currentUser;
    setState(() {
      _emailAddress = user!.email;
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

        await user!.updatePassword(newPassword).then((value) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Your password has been changed successfully :)',
                maxLines: 3,
                style: kTextSmallBodyStyle,
              ),
              duration: Duration(seconds: 4),
            ),
          );
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
      appBar: AppBar(title: const Text('Change password')),
      body: _emailAddress == null
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
                        'Password change',
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
                                key: const ValueKey('newPassword'),
                                validator: (value) {
                                  if (value!.isEmpty || value.length < 7) {
                                    return 'Please enter a valid Password';
                                  } else if (value == '12345678' ||
                                      value == 'qwertyuiop' ||
                                      value == 'password') {
                                    return '*In Chandler\'s voice* Could your password be any lamer? \ni.e your password is too weak';
                                  }
                                  return null;
                                },
                                textInputAction: TextInputAction.next,
                                focusNode: _newPasswordFocusNode,
                                keyboardType: TextInputType.visiblePassword,
                                obscureText: _obscureText,
                                onEditingComplete: () => FocusScope.of(context)
                                    .requestFocus(_passwordVerifyFocusNode),
                                decoration: InputDecoration(
                                    errorMaxLines: 3,
                                    border: const UnderlineInputBorder(),
                                    filled: true,
                                    prefixIcon: const Icon(Icons.lock),
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
                                    labelText: 'Enter new password',
                                    fillColor: Theme.of(context)
                                        .colorScheme
                                        .background),
                                onChanged: (value) {
                                  setState(() {
                                    newPassword = value;
                                  });
                                },
                                onSaved: (value) {
                                  newPassword = value!;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: TextFormField(
                                key: const ValueKey('verifyPassword'),
                                validator: (value) {
                                  if (value != newPassword) {
                                    return 'The passwords entered don\'t match';
                                  }
                                  return null;
                                },
                                textInputAction: TextInputAction.next,
                                focusNode: _passwordVerifyFocusNode,
                                keyboardType: TextInputType.visiblePassword,
                                obscureText: _obscureText,
                                decoration: InputDecoration(
                                    errorMaxLines: 3,
                                    border: const UnderlineInputBorder(),
                                    filled: true,
                                    prefixIcon: const Icon(Icons.lock),
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
                                    labelText: 'Repeat new password',
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
                                    'Reset password',
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
