import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'Drawer.dart'; // Ensure you import your Drawer class

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String userAddress = "151-171 Montclair Ave, Newark, NJ 07104, USA";
  // String userProfileImage = "assets/profile.jpg"; // Replace with actual image
  String? selectedAlert;
  String _currentLocation = "Press the button to get the location";
  double? _latitude;
  double? _longitude;

  // Future<void> alert() async {
  //     if (_latitude == null || _longitude == null) {
  //       Fluttertoast.showToast(msg: "Please fetch your location first.");
  //       return;
  //     }
  //
  //     final sh = await SharedPreferences.getInstance();
  //     String url = sh.getString("url").toString();
  //     try {
  //       var data = await http.post(
  //         Uri.parse(url + "user_send_ambulance_request"),
  //         body: {
  //           'lid': sh.getString("lid").toString(),
  //           // 'alert': selectedAlert,
  //           'latitude': _latitude.toString(),
  //           'longitude': _longitude.toString(),
  //         },
  //       );
  //       var jsonData = json.decode(data.body);
  //       String status = jsonData['status'].toString();
  //
  //       if (status == "ok") {
  //         Fluttertoast.showToast(msg: "Alert Sent!");
  //         // Navigator.push(
  //         //   context,
  //         //   MaterialPageRoute(
  //         //     builder: (context) => Homepage(),
  //         //   ),
  //         // );
  //       } else {
  //         // _showAlertDialog("Sending alert failed.");
  //       }
  //     } catch (e) {
  //       print(e);
  //       // _showAlertDialog("An error occurred: $e");
  //     }
  //
  // }

  Future<void> sendSOSRequest() async {

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url'); // Keep null safety handling
    String? lid = sh.getString('lid');

    if (url == null || lid == null || url.isEmpty || lid.isEmpty) {
      Fluttertoast.showToast(msg: 'Invalid URL or ID');
      return;
    }

    // Ensure the URL has a trailing slash
    if (!url.endsWith('/')) {
      url += '/';
    }

    final requestUrl = Uri.parse(url + 'user_send_ambulance_request');

    try {
      final response = await http.post(requestUrl, body: {

        'lid': lid,
        'latitude': _latitude.toString(),
        'longitude': _longitude.toString(),
      });
      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        Fluttertoast.showToast(
            msg: status == 'ok' ? 'Request Sent' : 'Already Sent!');
      } else {
        Fluttertoast.showToast(
            msg: 'Network Error (Status: ${response.statusCode})');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Request Failed: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentLocation = 'Location permissions are denied';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentLocation = 'Location permissions are permanently denied';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _latitude = position.latitude;
      _longitude = position.longitude;

      setState(() {
        _currentLocation = 'Latitude: $_latitude, Longitude: $_longitude';
      });
    } catch (e) {
      setState(() {
        _currentLocation = 'Unable to fetch location: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Emergency SOS",
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.redAccent),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const Drawerclass(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              Text(
                _currentLocation,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _getCurrentLocation,
                child: const Text("Get Current Location"),
              ),

              // User Greeting
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome back,",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      Text(
                        "Jenifer Pilman",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.person, size: 30, color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Emergency Message
              const Text(
                "Are you in emergency?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "Press the button below, help will reach you soon.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // SOS Button with Shadow
              GestureDetector(
                onTap: () {
                  _getCurrentLocation();
                  sendSOSRequest();
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Colors.redAccent, Colors.deepOrange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.5),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.redAccent,
                      ),
                      child: const Center(
                        child: FaIcon(FontAwesomeIcons.ambulance,
                            color: Colors.white, size: 50),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              // Current Location Section
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.redAccent,
                      child: Icon(Icons.location_on, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Your Current Address",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            userAddress,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
