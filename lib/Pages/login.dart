import 'dart:convert';

import 'package:emergency_vehicle/Pages/ambulance_home.dart';
import 'package:emergency_vehicle/Pages/registration.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'amb location_service.dart';
import 'home.dart';
import 'location_service.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo or App Title
                const Icon(Icons.local_hospital,
                    size: 80, color: Colors.blueAccent),
                const SizedBox(height: 20),
                const Text(
                  "Welcome Back!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Login to continue",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 30),

                // Username Input
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    hintText: "Username",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Input with Toggle
                TextField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    hintText: "Password",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final sh = await SharedPreferences.getInstance();
                      String Uname = usernameController.text.toString();
                      String Passwd = passwordController.text.toString();
                      String url = sh.getString("url").toString();
                      print("okkkkkkkkkkkkkkkkk");
                      var data =
                          await http.post(Uri.parse(url + "logincode"), body: {
                        'username': Uname,
                        "password": Passwd,
                      });
                      var jasondata = json.decode(data.body);
                      String status = jasondata['task'].toString();
                      String type = jasondata['type'].toString();
                      if (status == "valid") {
                        if (type == 'user') {
                          String lid = jasondata['lid'].toString();
                          sh.setString("lid", lid);
                          // Navigator.push(context,
                          //     MaterialPageRoute(
                          //         builder: (context) => sapp()));

                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Home()));
                        } else if (type == 'ambulance') {
                          String lid = jasondata['lid'].toString();
                          sh.setString("lid", lid);
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => AmbPP()));

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AmbulanceHome()));
                        } else {
                          print("error");
                        }
                      } else {
                        print("error");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Registration Button
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Registration(),
                        ));
                  },
                  child: const Text(
                    "Don't have an account? Register",
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
