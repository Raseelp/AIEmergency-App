import 'dart:convert';


import 'package:emergency_vehicle/Pages/ambulance_home.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'home.dart';
class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {


  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                    hintText: "Username",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                    hintText: "Password",
                  ),
                ),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding:const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigator.push(context,
                          //     MaterialPageRoute(builder: (context) => Registration()));
                        },
                        child: Text("Registration"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: ()async {
                          final sh = await SharedPreferences.getInstance();
                          String Uname=usernameController.text.toString();
                          String Passwd=passwordController.text.toString();
                          String url = sh.getString("url").toString();
                          print("okkkkkkkkkkkkkkkkk");
                          var data = await http.post(
                              Uri.parse(url+"logincode"),
                              body: {'username':Uname,
                                "password":Passwd,
                              });
                          var jasondata = json.decode(data.body);
                          String status=jasondata['task'].toString();
                          String type=jasondata['type'].toString();
                          if(status=="valid") {
                            if (type == 'user') {
                              String lid = jasondata['lid'].toString();
                              sh.setString("lid", lid);
                              Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (context) => Home()));
                            }
                            else if (type == 'ambulance') {
                              String lid = jasondata['lid'].toString();
                              sh.setString("lid", lid);
                              Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (context) => AmbulanceHome()));
                            }
                            else{
                              print("error");

                            }
                          }
                          else{
                            print("error");

                          }

                        },
                        child: const Text("Login"),
                      ),
                    )
                  ]),
            ],
          ),
        ),
      ),
    );
  }
}