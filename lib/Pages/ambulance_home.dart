import 'dart:convert';
import 'package:emergency_vehicle/Pages/ambulance_Drawer.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'Drawer.dart'; // Ensure you import your Drawer class

class AmbulanceHome extends StatefulWidget {
  const AmbulanceHome({Key? key}) : super(key: key);

  @override
  State<AmbulanceHome> createState() => _AmbulanceHomeState();
}

class _AmbulanceHomeState extends State<AmbulanceHome> {
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
  //         //     builder: (context) => AmbulanceHomepage(),
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
      final response = await http.post(requestUrl, body: {'lid': lid});
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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.redAccent),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const AmbulanceDraweClass(), // Drawer integration
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Text(
                //   _currentLocation,
                //   style: const TextStyle(fontSize: 16, color: Colors.grey),
                // ),
                //
                // // Emergency Message
                const Text(
                  "Ambulance Home",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                // const SizedBox(height: 10),
                // const Text(
                //   "Press the button below, help will reach you soon.",
                //   style: TextStyle(fontSize: 16, color: Colors.grey),
                //   textAlign: TextAlign.center,
                // ),
                // const SizedBox(height: 30),
                //
                // // SOS Button
                // GestureDetector(
                //   onTap: sendSOSRequest,
                //   child: Container(
                //     padding: const EdgeInsets.all(10),
                //     decoration: BoxDecoration(
                //       shape: BoxShape.circle,
                //       boxShadow: [
                //         BoxShadow(
                //           color: Colors.redAccent.withOpacity(0.4),
                //           blurRadius: 30,
                //           spreadRadius: 10,
                //         ),
                //       ],
                //     ),
                //     child: Container(
                //       width: 120,
                //       height: 120,
                //       decoration: const BoxDecoration(
                //         color: Colors.redAccent,
                //         shape: BoxShape.circle,
                //       ),
                //       child: const Center(
                //         child: Text(
                //           "SOS",
                //           style: TextStyle(
                //             color: Colors.white,
                //             fontSize: 26,
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 40),
                //
                // // Current Location Section
                // Container(
                //   padding: const EdgeInsets.all(15),
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(10),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.grey.withOpacity(0.2),
                //         blurRadius: 5,
                //         spreadRadius: 1,
                //       ),
                //     ],
                //   ),
                //   child: Row(
                //     children: [
                //       CircleAvatar(
                //         radius: 22,
                //         backgroundImage: AssetImage(userProfileImage),
                //       ),
                //       const SizedBox(width: 10),
                //       Expanded(
                //         child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             const Text(
                //               "Your current address",
                //               style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                //             ),
                //             Text(
                //               userAddress,
                //               style: const TextStyle(fontSize: 14, color: Colors.grey),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                //
                // const Spacer(),

                // Bottom Navigation
                // Container(
                //   padding: const EdgeInsets.symmetric(vertical: 10),
                //   decoration: BoxDecoration(
                //     color: Colors.redAccent,
                //     borderRadius: BorderRadius.circular(15),
                //   ),
                //   child: const Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                //     children: [
                //       Icon(Icons.AmbulanceHome, color: Colors.white, size: 30),
                //       Icon(Icons.location_on_outlined, color: Colors.white, size: 30),
                //       Icon(Icons.settings, color: Colors.white, size: 30),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
