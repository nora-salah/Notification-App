import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notification/screens/login_screen.dart';
import 'package:notification/utils/app_colors.dart';
import 'package:notification/widgets/round_gradient_btn.dart';
import 'package:notification/widgets/round_text_field.dart';

import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _auth = FirebaseAuth.instance;
  CollectionReference _users = FirebaseFirestore.instance.collection("users");
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isObscure = true;
  bool _isChecked = false;
  final _formKey = GlobalKey<FormState>();

  //
  // Future<User?> _signUp(
  //     BuildContext context, String email, String password) async {
  //   try {
  //     UserCredential userCredential = await _auth
  //         .createUserWithEmailAndPassword(email: email, password: password);
  //     User? user = userCredential.user;
  //     Navigator.push(
  //         context, MaterialPageRoute(builder: (context) => HomeScreen()));
  //     return user;
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text('Sign Up Failed, Please try again'),
  //     ));
  //     return null;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: media.height * 0.1),
                  SizedBox(
                    width: media.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: media.width * 0.03),
                        Text(
                          'hey there',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.black2,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: media.width * 0.01),
                        Text(
                          'Create Account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.black2,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: media.width * 0.05),
                        RoundTextField(
                          textEditingController: _firstNameController,
                          hintText: 'First Name',
                          icon: Icons.person,
                          textInputType: TextInputType.name,
                          isObscureText: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your first name";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: media.width * 0.05),
                        RoundTextField(
                          textEditingController: _lastNameController,
                          hintText: 'Last Name',
                          icon: Icons.person,
                          textInputType: TextInputType.name,
                          isObscureText: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your last name";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: media.width * 0.05),
                        RoundTextField(
                          textEditingController: _emailController,
                          hintText: 'Email',
                          icon: Icons.email,
                          textInputType: TextInputType.emailAddress,
                          isObscureText: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your email";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: media.width * 0.05),
                        RoundTextField(
                          textEditingController: _passwordController,
                          hintText: 'Password',
                          icon: Icons.lock,
                          textInputType: TextInputType.visiblePassword,
                          isObscureText: isObscure,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your Password";
                            } else if (value.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                          rightIcon: TextButton(
                              onPressed: () {
                                setState(() {
                                  isObscure = !isObscure;
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width: 20,
                                height: 20,
                                child: isObscure
                                    ? Icon(Icons.visibility_off)
                                    : Icon(Icons.remove_red_eye),
                              )),
                        ),
                        SizedBox(height: media.width * 0.05),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isChecked = !_isChecked;
                                  });
                                },
                                icon: Icon(
                                  _isChecked
                                      ? Icons.check_box_outlined
                                      : Icons.check_box_outline_blank,
                                  color: AppColors.gray,
                                )),
                            Expanded(
                              child: Text(
                                "I accept the terms and conditions",
                                style: TextStyle(
                                  color: AppColors.gray,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: media.width * 0.05),
                        RoundGradientBtn(
                            title: 'Create Account ',
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (_isChecked) {
                                  try {
                                    UserCredential userCredential = await _auth
                                        .createUserWithEmailAndPassword(
                                            email: _emailController.text,
                                            password: _passwordController.text);

                                    String uid = userCredential.user!.uid;
                                    await _users.doc(uid).set({
                                      'email': _emailController.text,
                                      'firstName': _firstNameController.text,
                                      'lastName': _lastNameController.text,
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text("Account create Successfully"),
                                      ),
                                    );
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LoginScreen()));
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(e.toString()),
                                      ),
                                    );
                                  }
                                }
                              }
                              //     _isChecked) {
                              //   _signUp(context, _emailController.text,
                              //       _passwordController.text);
                              // } else if (!_isChecked) {
                              //   ScaffoldMessenger.of(context).showSnackBar(
                              //     SnackBar(
                              //       content: Text(
                              //           'Please accept the terms and conditions'),
                              //     ),
                              //   );
                              // }
                            }),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                width: double.maxFinite,
                                height: 1,
                                color: AppColors.gray.withOpacity(0.5),
                              ),
                            ),
                            Text(
                              "  Or  ",
                              style: TextStyle(
                                  color: AppColors.gray,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12),
                            ),
                            Expanded(
                              child: Container(
                                width: double.maxFinite,
                                height: 1,
                                color: AppColors.gray.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: media.width * 0.05),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                height: 50,
                                width: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                        color: AppColors.primaryColor1,
                                        width: 1)),
                                child: Icon(Icons.g_mobiledata),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                height: 50,
                                width: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                        color: AppColors.primaryColor1,
                                        width: 1)),
                                child: Icon(Icons.g_mobiledata),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: media.width * 0.05),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()));
                          },
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.black2),
                                children: [
                                  TextSpan(text: "Already have an account?  "),
                                  TextSpan(
                                      text: "Login",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.secondaryColor)),
                                ]),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
