import 'dart:async';
import 'dart:convert';
import 'package:emergency_vehicle/Pages/models/ambulance_mode.dart';
import 'package:emergency_vehicle/widgets/map_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

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
  String username = 'User';
  final MapController _mapController = MapController();
  LatLng? currentLocation = LatLng(11.2588, 75.7804);
  List<Ambulance> fetchedAmbulances = [];
  bool _isMapReady = false;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Timer? _ambulanceTimer;

  @override
  void initState() {
    _fetchambulancesOnInit();
    _ambulanceTimer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) {
        loadnot();
      },
    );

    showUsername();
    initializeNotifications();

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _isMapReady = true;
      });
    });
    super.initState();
  }

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request notification permission for Android 13+
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'ambulance_channel_id',
      'Ambulance Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
    );
  }

  Future<void> _fetchambulancesOnInit() async {
    await fetchAmbulances();

    // Future.delayed(const Duration(milliseconds: 300), () {
    //   setState(()  {
    //    loadnot();
    //   });
    // });
  }

  bool _isFullScreen = false;

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  bool _isHelp = false;

  void _toggleHelp() {
    setState(() {
      _isHelp = !_isHelp;
    });
  }

  Future<String?> getUsername() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? lid = sh.getString('lid');
    String? url = sh.getString('url');
    print(url);

    try {
      final response = await http.get(Uri.parse(url! + 'get-username/$lid/'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['username'];
      } else {
        print('Error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  Future<void> showUsername() async {
    String? fetchedUsername = await getUsername();
    if (fetchedUsername != null) {
      setState(() {
        username = fetchedUsername;
      });
    } else {
      print('User not found or error occurred');
    }
  }

  Future<void> sendSOSRequest() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
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

      _latitude = position.latitude;
      _longitude = position.longitude;

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

  @override
  Widget build(BuildContext context) {
    final screenheight = MediaQuery.of(context).size.height;
    final screenwidth = MediaQuery.of(context).size.width;
    return _isFullScreen
        ? Scaffold(
            body: _isMapReady
                ? userMap(fetchedAmbulances, fetchAmbulances(),
                    context: context,
                    getcurrentLocation: _getCurrentLocation(),
                    height: screenheight * 0.3,
                    width: screenwidth * 0.8,
                    mapController: _mapController,
                    currentLocation: currentLocation,
                    isFullScreen: _isFullScreen,
                    toggleFullScreen: _toggleFullScreen,
                    ishelp: _isHelp,
                    toggleHelp: _toggleHelp)
                : const Center(child: CircularProgressIndicator()),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text(
                "Emergency SOS",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon:
                      const Icon(Icons.notifications, color: Colors.redAccent),
                  onPressed: () {},
                ),
              ],
            ),
            drawer: const UserDrawer(),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Welcome back,",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                username,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey[200],
                            child: const Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.black54, // Subtle contrast
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Emergency Message
                    const Text(
                      "Are you in emergency?",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                      child: Padding(
                        padding: EdgeInsets.only(bottom: screenheight * 0.05),
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
                    ),
                    _isMapReady
                        ? userMap(fetchedAmbulances, fetchAmbulances(),
                            context: context,
                            getcurrentLocation: _getCurrentLocation(),
                            height: screenheight * 0.3,
                            width: screenwidth * 0.8,
                            mapController: _mapController,
                            currentLocation: currentLocation,
                            isFullScreen: _isFullScreen,
                            toggleFullScreen: _toggleFullScreen,
                            ishelp: _isHelp,
                            toggleHelp: _toggleHelp)
                        : const Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
            ),
          );
  }

  Future<void> loadnot() async {
    print("object");
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');

    final response = await http.post(
        Uri.parse(url! + 'view_nearest_ambulances2'),
        body: {'id': sh.getString("id").toString()});

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['status'] == 'ok') {
        String id = data['id'].toString();
        print('object${id}');
        sh.setString("id", id);
        await showNotification("New Ambulances Available!", "Passing..");
      } else {
        throw Exception('Failed to load ambulances: ${data['status']}');
      }
    } else {
      throw Exception('Failed to load ambulances');
    }
  }
}
