import 'dart:convert';
import 'package:emergency_vehicle/Pages/models/ambulance_mode.dart';
import 'package:emergency_vehicle/widgets/map_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
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
  String? selectedAlert;
  String _currentLocationStatus = "Press the button to get the location";
  double? _latitude;
  double? _longitude;
  final MapController _mapController = MapController();
  LatLng? currentLocation = LatLng(11.2588, 75.7804);
  List<Ambulance> fetchedAmbulances = [];
  bool _isMapReady = false;

  @override
  void initState() {
    _fetchambulancesOnInit();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _isMapReady = true;
      });
    });
    super.initState();
  }

  Future<void> _fetchambulancesOnInit() async {
    await fetchAmbulances();
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
            _currentLocationStatus = 'Location permissions are denied';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentLocationStatus =
              'Location permissions are permanently denied';
        });
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        // _mapController.move(currentLocation!, 14.0);
      });

      // _latitude = position.latitude;
      // _longitude = position.longitude;

      setState(() {
        _currentLocationStatus = currentLocation.toString();
      });
    } catch (e) {
      setState(() {
        _currentLocationStatus = 'Unable to fetch location: $e';
      });
    }
  }

  Future<void> fetchAmbulances() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');

    final response =
        await http.get(Uri.parse(url! + 'view_nearest_ambulances'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['status'] == 'ok') {
        List<Ambulance> ambulances = (data['data'] as List)
            .map((jsonItem) => Ambulance.fromJson(jsonItem))
            .toList();
        setState(() {
          fetchedAmbulances = ambulances;
        });
      } else {
        throw Exception('Failed to load ambulances: ${data['status']}');
      }
    } else {
      throw Exception('Failed to load ambulances');
    }
  }

  // Future<void> _getCurrentLocation() async {
  //   try {
  //     LocationPermission permission = await Geolocator.checkPermission();

  //     if (permission == LocationPermission.denied) {
  //       permission = await Geolocator.requestPermission();
  //       if (permission == LocationPermission.denied) {
  //         setState(() {
  //           _currentLocation = 'Location permissions are denied';
  //         });
  //         return;
  //       }
  //     }

  //     if (permission == LocationPermission.deniedForever) {
  //       setState(() {
  //         _currentLocation = 'Location permissions are permanently denied';
  //       });
  //       return;
  //     }

  //     Position position = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.high);
  //     _latitude = position.latitude;
  //     _longitude = position.longitude;

  //     setState(() {
  //       _currentLocation = 'Latitude: $_latitude, Longitude: $_longitude';
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _currentLocation = 'Unable to fetch location: $e';
  //     });
  //   }

  // }
  @override
  Widget build(BuildContext context) {
    final screenheight = MediaQuery.of(context).size.height;
    final screenwidth = MediaQuery.of(context).size.width;
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
              // const SizedBox(height: 20),
              // const SizedBox(height: 20),
              // Text(
              //   _currentLocation,
              //   style: const TextStyle(fontSize: 16, color: Colors.grey),
              // ),
              // const SizedBox(height: 10),
              // ElevatedButton(
              //   onPressed: _getCurrentLocation,
              //   child: const Text("Get Current Location"),
              // ),

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
              _isMapReady
                  ? UserMap(fetchedAmbulances,
                      context: context,
                      getcurrentLocation: _getCurrentLocation(),
                      height: screenheight * 0.3,
                      width: screenwidth * 0.8,
                      mapController: _mapController,
                      currentLocation: currentLocation)
                  : Center(child: CircularProgressIndicator()),
              ElevatedButton(
                  onPressed: () async {
                    await fetchAmbulances();
                    print(fetchedAmbulances);
                  },
                  child: Text('ReFetch Ambulances')),

              // // Current Location Section
              // Container(
              //   padding: const EdgeInsets.all(15),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(12),
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
              //       const CircleAvatar(
              //         radius: 25,
              //         backgroundColor: Colors.redAccent,
              //         child: Icon(Icons.location_on, color: Colors.white),
              //       ),
              //       const SizedBox(width: 12),
              //       Expanded(
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             const Text(
              //               "Your Current Address",
              //               style: TextStyle(
              //                   fontSize: 14, fontWeight: FontWeight.bold),
              //             ),
              //             Text(
              //               userAddress,
              //               style: const TextStyle(
              //                   fontSize: 14, color: Colors.grey),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              // const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
