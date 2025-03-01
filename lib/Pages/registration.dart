import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'login.dart';

class Registration extends StatefulWidget {
  const Registration({Key? key}) : super(key: key);

  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  TextEditingController dateInputController = TextEditingController();
  final TextEditingController fnameController = TextEditingController();
  final TextEditingController lnameController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController postController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? selectedGender;
  final _formKey = GlobalKey<FormState>(); // Add a global key for the form

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Emergency"),
        ),
        body: SafeArea(
            child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                    child: Column(children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Register",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: fnameController,
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        hintText: "First Name",
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null; // Return null if the input is valid
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: placeController,
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        hintText: "place",
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your place';
                        }
                        return null; // Return null if the input is valid
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: postController,
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        hintText: "post",
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your post';
                        }
                        return null; // Return null if the input is valid
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: pinController,
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        hintText: "pin",
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your pin';
                        }
                        if (value.length < 6) {
                          return 'Please enter a valid pin';
                        }
                        return null; // Return null if the input is valid
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        hintText: "Phone",
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your phoneNumber';
                        }
                        if (value.length < 10) {
                          return 'Please enter a valid phone number';
                        }
                        if (value.length > 10) {
                          return 'Please enter a valid phone number';
                        }
                        if (value.contains(RegExp(r'[A-Z]'))) {
                          return 'Please enter a valid phone number';
                        }
                        if (value.contains(RegExp(r'[a-z]'))) {
                          return 'Please enter a valid phone number';
                        }

                        return null; // Return null if the input is valid
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        hintText: "Email",
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return '`Please enter your email address';
                        }
                        if (!value.contains('@')) {
                          return 'Email must contain @';
                        }
                        if (!value.contains('.')) {
                          return 'Email must contain .';
                        }
                        return null; // Return null if the input is valid
                      },
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                          hintText: "Username",
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null; // Return null if the input is valid
                        },
                      )),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                          hintText: "Password",
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters long';
                          }

                          return null; // Return null if the input is valid
                        },
                      )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) {
                        } else {
                          final sh = await SharedPreferences.getInstance();
                          String fname = fnameController.text.toString();
                          // String lname = lnameController.text.toString();
                          String place = placeController.text.toString();
                          String post = postController.text.toString();
                          String pin = pinController.text.toString();
                          String phone = phoneController.text.toString();
                          String email = emailController.text.toString();
                          String uname = usernameController.text.toString();
                          String pasword = passwordController.text.toString();

                          String url = sh.getString("url").toString();
                          print("okkkkkkkkkkkkkkkkk");
                          var data = await http.post(
                              Uri.parse(url + "user_registration"),
                              body: {
                                'fname': fname,
                                // 'lname': lname,
                                'place': place,
                                'post': post,
                                'pin': pin,
                                'phone': phone,
                                'email': email,
                                'uname': uname,
                                'password': pasword,
                                'lid': sh.getString("lid").toString(),
                              });
                          var jasondata = json.decode(data.body);
                          String status = jasondata['task'].toString();
                          print(status);
                          if (status == "valid") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: const Text(
                                    "Registration Successful! You can now log in."),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );

                            Future.delayed(const Duration(seconds: 1), () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => login()),
                              );
                            });
                          } else {
                            print("error");
                          }
                        }
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Submit'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Color(
                              0xFF6ADC50), // Use a proper color value (e.g., Hex or RGB)
                        ),
                      ),
                    ),
                  )
                ])))));
  }
}
