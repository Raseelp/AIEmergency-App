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
  String? selectedItem; // Store selected value
  final List<String> items = ['Available', 'Unavailable']; // List of
  List<Map<String, dynamic>> requests = [];
  bool isLoading = false;

  Future<void> fetchAmbulanceRequests() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lid = prefs.getString('lid');
    String? url = prefs.getString('url');

    if (lid != null) {
      try {
        final response = await http.post(
          Uri.parse(url! +
              'get_ambulance_requests/'), // Replace with your backend URL
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({'lid': lid}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            requests = List<Map<String, dynamic>>.from(data['requests']);
            isLoading = false;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to fetch requests: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('LID not found')),
      );
    }
  }

  Future<void> updateStatus(String status) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lid = prefs.getString('lid'); // Get the saved lid
    String? url = prefs.getString('url');

    if (lid != null) {
      try {
        final response = await http.post(
          Uri.parse(url! + 'update_status/'), // Replace with your backend URL
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'lid': lid,
            'status': status,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Status updated successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to update status: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('LID not found')),
      );
    }
  }
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
  void initState() {
    fetchAmbulanceRequests();
    super.initState();
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
                Center(
                  child: DropdownButton<String>(
                    value: selectedItem,
                    hint: const Text('Select Availability'),
                    items: items.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedItem = newValue;
                        updateStatus(selectedItem.toString());
                      });
                    },
                    icon: const Icon(Icons.arrow_drop_down_circle,
                        color: Colors.blue),
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.black, fontSize: 18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : requests.isEmpty
                        ? const Center(child: Text('No requests available'))
                        : Expanded(
                            child: ListView.builder(
                              itemCount: requests.length,
                              itemBuilder: (context, index) {
                                final request = requests[index];
                                return Card(
                                  elevation: 3,
                                  margin: const EdgeInsets.all(8),
                                  child: ListTile(
                                    title:
                                        Text('Request: ${request['request']}'),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Status: ${request['Status']}'),
                                        Text('Date: ${request['date']}'),
                                        Text(
                                            'Location: ${request['latitude']}, ${request['longitude']}'),
                                      ],
                                    ),
                                    trailing:
                                        const Icon(Icons.arrow_forward_ios),
                                  ),
                                );
                              },
                            ),
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
