

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';  // Add this for handling runtime permissions

class EmergencyAlerts extends StatelessWidget {
  const EmergencyAlerts({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emergency Alerts',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const EmergencyAlertsPage(title: 'Emergency Alerts'),
    );
  }
}

class EmergencyAlertsPage extends StatefulWidget {
  const EmergencyAlertsPage({super.key, required this.title});
  final String title;

  @override
  State<EmergencyAlertsPage> createState() => _EmergencyAlertsPageState();
}

class _EmergencyAlertsPageState extends State<EmergencyAlertsPage> {
  List<String> cid_ = <String>[];
  List<String> alert_ = <String>[];
  List<String> date_ = <String>[];
  List<String> latitude_ = <String>[];
  List<String> longitude_ = <String>[];
  List<String> user_ = <String>[];
  List<String> distance_km_ = <String>[];
  List<String> placeNames_ = <String>[]; // List for place names

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    List<String> cid = <String>[];
    List<String> alert = <String>[];
    List<String> date = <String>[];
    List<String> latitude = <String>[];
    List<String> longitude = <String>[];
    List<String> user = <String>[];
    List<String> distance_km = <String>[];
    List<String> placeNames = <String>[]; // Temporary list for place names

    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("url").toString();
      String url = ip + "user_view_emergency_alert";
      var data = await http.post(Uri.parse(url), body: {'lid': pref.getString("lid").toString()});

      var jsondata = json.decode(data.body);
      var arr = jsondata["data"];
      for (int i = 0; i < arr.length; i++) {
        String lat = arr[i]['latitude'].toString();
        String lon = arr[i]['longitude'].toString();

        // Add data to lists
        cid.add(arr[i]['id'].toString());
        alert.add(arr[i]['alert'].toString());
        date.add(arr[i]['date'].toString());
        user.add(arr[i]['user'].toString());
        distance_km.add(arr[i]['distance_km'].toString());
        latitude.add(lat);
        longitude.add(lon);

        // Fetch place name
        String placeName = await fetchPlaceName(double.parse(lat), double.parse(lon));
        placeNames.add(placeName);
      }

      setState(() {
        cid_ = cid;
        alert_ = alert;
        date_ = date;
        latitude_ = latitude;
        longitude_ = longitude;
        user_ = user;
        distance_km_ = distance_km;
        placeNames_ = placeNames; // Update place names in state
      });
    } catch (e) {
      print("Error: ${e.toString()}");
    }
  }

  Future<String> fetchPlaceName(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return "${place.locality}, ${place.administrativeArea}, ${place.country}";
      }
      return "Unknown Location";
    } catch (e) {
      print("Geocoding Error: ${e.toString()}");
      return "Unknown Location";
    }
  }

  Future<void> openMap(double lat, double lon) async {
    // Check permission before opening the map
    PermissionStatus permissionStatus = await Permission.location.request();
    if (permissionStatus.isGranted) {
      final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lon");

      if (await canLaunch(googleMapsUrl.toString())) {
        await launch(googleMapsUrl.toString());
      } else {
        throw "Could not launch $googleMapsUrl";
      }
    } else {
      print("Location permission denied");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: cid_.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Card(
              margin: const EdgeInsets.all(10.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Alert: ${alert_[index]}"),
                    Text("Date: ${date_[index]}"),
                    Text("User: ${user_[index]}"),
                    Text("Distance: ${distance_km_[index]} km"),
                    Text("Location: ${placeNames_[index]}"),
                    ElevatedButton(
                      onPressed: () {
                        openMap(
                          double.parse(latitude_[index]),
                          double.parse(longitude_[index]),
                        );
                      },
                      child: const Text('Track'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


// geolocator:
// geocoding:
// url_launcher:
// flutter_map:
// latlong2: