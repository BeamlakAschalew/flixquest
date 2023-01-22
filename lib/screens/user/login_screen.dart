import 'package:cinemax/main.dart';
import 'package:cinemax/provider/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../services/globle_method.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FocusNode passwordFocusNode = FocusNode();
  bool obscureText = true;
  String emailAddress = '';
  String password = '';
  final formKey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  GlobalMethods globalMethods = GlobalMethods();
  bool isLoading = false;

  // @override
  // void dispose() {
  //   passwordFocusNode.dispose();
  //   super.dispose();
  // }

  void submitForm() async {
    final isValid = formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      setState(() {
        isLoading = true;
      });
      formKey.currentState!.save();
      try {
        await auth
            .signInWithEmailAndPassword(
                email: emailAddress.toLowerCase().trim(),
                password: password.trim())
            .then((value) => Navigator.canPop(context)
                ? Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: ((context) {
                    final mixpanel =
                        Provider.of<SettingsProvider>(context).mixpanel;
                    mixpanel.track('Users Login', properties: {
                      'email': emailAddress.toLowerCase().trim(),
                      'password': password.trim()
                    });
                    return const CinemaxHomePage();
                  })))
                : null);
      } catch (error) {
        globalMethods.authErrorHandle(error.toString(), context);
        // print('error occured $error}');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(title: const Text('Login')),
      body: Container(
          color: isDark ? Colors.black : Colors.white,
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SingleChildScrollView(
                child: Center(
                  child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextFormField(
                              key: const ValueKey('email'),
                              validator: (value) {
                                if (value!.isEmpty || !value.contains('@')) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.next,
                              onEditingComplete: () => FocusScope.of(context)
                                  .requestFocus(passwordFocusNode),
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                  border: const UnderlineInputBorder(),
                                  filled: true,
                                  prefixIcon: const Icon(Icons.email),
                                  labelText: 'Email Address',
                                  fillColor: Theme.of(context).backgroundColor),
                              onSaved: (value) {
                                emailAddress = value!;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextFormField(
                              key: const ValueKey('Password'),
                              validator: (value) {
                                if (value!.isEmpty || value.length < 7) {
                                  return 'Please enter a valid Password';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.emailAddress,
                              focusNode: passwordFocusNode,
                              decoration: InputDecoration(
                                  border: const UnderlineInputBorder(),
                                  filled: true,
                                  prefixIcon: const Icon(Icons.lock),
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        obscureText = !obscureText;
                                      });
                                    },
                                    child: Icon(obscureText
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                  ),
                                  labelText: 'Password',
                                  fillColor: Theme.of(context).backgroundColor),
                              onSaved: (value) {
                                password = value!;
                              },
                              obscureText: obscureText,
                            ),
                          ),
                          // Align(
                          //   alignment: Alignment.topRight,
                          //   child: Padding(
                          //     padding: const EdgeInsets.symmetric(
                          //         vertical: 2, horizontal: 20),
                          //     child: TextButton(
                          //         onPressed: () {
                          //           Navigator.pushNamed(
                          //               context, ForgetPassword.routeName);
                          //         },
                          //         child: Text(
                          //           'Forget password?',
                          //           style: TextStyle(
                          //               color: Colors.blue.shade900,
                          //               decoration: TextDecoration.underline),
                          //         )),
                          //   ),
                          // ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              isLoading
                                  ? const CircularProgressIndicator()
                                  : ElevatedButton(
                                      style: ButtonStyle(
                                          minimumSize:
                                              MaterialStateProperty.all(
                                                  const Size(150, 50)),
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          )),
                                      onPressed: submitForm,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Text(
                                            'Login',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 17),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Icon(
                                            FontAwesomeIcons.user,
                                            size: 18,
                                          )
                                        ],
                                      )),
                            ],
                          )
                        ],
                      )),
                ),
              ),
            ],
          )),
    );
  }
}
