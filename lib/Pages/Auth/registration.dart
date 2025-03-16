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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A90E2), Color(0xFF145DA0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_hospital,
                          size: 80, color: Colors.white),
                      const SizedBox(height: 20),
                      const Text(
                        "Welcome!",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Enter Your Details to continue",
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      const SizedBox(height: 30),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: fnameController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person,
                              color: Colors.blueAccent),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          hintText: "First Name",
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.phone, color: Colors.blueAccent),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          hintText: "Phone",
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.email, color: Colors.blueAccent),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          hintText: "Email",
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person_2_outlined,
                              color: Colors.blueAccent),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          hintText: "Username",
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.password,
                              color: Colors.blueAccent),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          hintText: "Password",
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) {
                          } else {
                            final sh = await SharedPreferences.getInstance();
                            String fname = fnameController.text.toString();

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
                                  content: Text(
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
                        icon: const Icon(Icons.send, color: Colors.white),
                        label: const Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
