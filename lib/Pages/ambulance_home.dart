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

  Future<void> acceptRequest(int requestId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lid = prefs.getString('lid');
    String? url = prefs.getString('url');
    print(url);

    if (lid != null && url != null && url.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse(url + 'accept_request/$requestId/'), // Updated URL
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({'lid': lid}), // Send ambulance's lid
        );

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body)['status'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(result == 'Accepted'
                    ? 'Request accepted successfully'
                    : result)),
          );
          fetchAmbulanceRequests(); // Refresh requests after acceptance
        } else {
          final error = jsonDecode(response.body)['status'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('LID or URL not found')),
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
        title: const Text(
          "Ambulance Home",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
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
                                    trailing: request['Status'] == 'Requested'
                                        ? ElevatedButton(
                                            onPressed: () =>
                                                acceptRequest(request['id']),
                                            child: const Text('Accept'),
                                          )
                                        : const Icon(Icons.check_circle,
                                            color: Colors.green),
                                  ),
                                );
                              },
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
