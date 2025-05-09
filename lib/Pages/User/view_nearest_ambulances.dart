// import 'dart:convert';
// import 'dart:math';
//
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:permission_handler/permission_handler.dart'; // Add this for handling runtime permissions
//
// class ViewNearestAmbulances extends StatelessWidget {
//   const ViewNearestAmbulances({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // Try running your application with "flutter run". You'll see the
//         // application has a blue toolbar. Then, without quitting the app, try
//         // changing the primarySwatch below to Colors.green and then invoke
//         // "hot reload" (press "r" in the console where you ran "flutter run",
//         // or simply save your changes to "hot reload" in a Flutter IDE).
//         // Notice that the counter didn't reset back to zero; the application
//         // is not restarted.
//         primarySwatch: Colors.red,
//       ),
//       home: const ViewNearestAmbulancesPage(title: 'Flutter Demo Home Page'),
//       routes: {},
//     );
//   }
// }
//
// class ViewNearestAmbulancesPage extends StatefulWidget {
//   const ViewNearestAmbulancesPage({super.key, required this.title});
//
//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.
//
//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".
//
//   final String title;
//
//   @override
//   State<ViewNearestAmbulancesPage> createState() =>
//       _ViewNearestAmbulancesPageState();
// }
//
// class _ViewNearestAmbulancesPageState extends State<ViewNearestAmbulancesPage> {
//   int _counter = 0;
//
//   _ViewNearestAmbulancesPageState() {
//     load();
//   }
//
//   List<String> ccid_ = <String>[];
//   List<String> AmbulanceNumber_ = <String>[];
//   List<String> Hospital_ = <String>[];
//   List<String> Type_ = <String>[];
//   List<String> Status_ = <String>[];
//   List<String> Latitude_ = <String>[];
//   List<String> Longitude_ = <String>[];
//   // List<String> department_= <String>[];
//   // List<String> age_ = <String>[];
//   // List<String> gender_ = <String>[];
//
//   Future<void> load() async {
//     List<String> ccid = <String>[];
//     List<String> AmbulanceNumber = <String>[];
//     List<String> Hospital = <String>[];
//     List<String> Type = <String>[];
//     List<String> Status = <String>[];
//     List<String> Latitude = <String>[];
//     List<String> Longitude = <String>[];
//     // List<String> department = <String>[];
//     // List<String> age = <String>[];
//     // List<String> gender = <String>[];
//
//     try {
//       final pref = await SharedPreferences.getInstance();
//       // String vid= pref.getString("rid").toString();
//       String ip = pref.getString("url").toString();
//       // String lid= pref.getString("lid").toString();
//
//       String url = ip + "view_nearest_ambulances";
//       print(url);
//       var data = await http.post(Uri.parse(url), body: {
//         // 'rid':vid
//       });
//
//       var jsondata = json.decode(data.body);
//       String status = jsondata['status'];
//
//       var arr = jsondata["data"];
//
//       print(arr);
//
//       print(arr.length);
//
//       // List<String> schid_ = <String>[];
//       // List<String> Name_ = <String>[];
//       // List<String> type_ = <String>[];
//
//       for (int i = 0; i < arr.length; i++) {
//         ccid.add(arr[i]['id'].toString());
//         AmbulanceNumber.add(arr[i]['Ambulance'].toString());
//         Hospital.add(arr[i]['Hospital'].toString());
//
//         Type.add(arr[i]['Type'].toString());
//         Status.add(arr[i]['Status'].toString());
//         Latitude.add(arr[i]['Latitude'].toString());
//         Longitude.add(arr[i]['Longitude'].toString());
//         // age.add(arr[i]['age'].toString());
//         // gender.add(arr[i]['gender'].toString());
//       }
//       setState(() {
//         ccid_ = ccid;
//         AmbulanceNumber_ = AmbulanceNumber;
//         Hospital_ = Hospital;
//         Type_ = Type;
//         Status_ = Status;
//         Latitude_ = Latitude;
//         Longitude_ = Longitude;
//         // department_ = department;
//         // age_ = age;
//         // gender_ = gender;
//       });
//       print(status);
//     } catch (e) {
//       print("Error ------------------- " + e.toString());
//       //there is error during converting file image to base64 encoding.
//     }
//   }
//
//   Future<void> openMap(double lat, double lon) async {
//     // Check permission before opening the map
//     PermissionStatus permissionStatus = await Permission.location.request();
//     if (permissionStatus.isGranted) {
//       final Uri googleMapsUrl = Uri.parse(
//           "https://www.google.com/maps/search/?api=1&query=$lat,$lon");
//
//       if (await canLaunch(googleMapsUrl.toString())) {
//         await launch(googleMapsUrl.toString());
//       } else {
//         throw "Could not launch $googleMapsUrl";
//       }
//     } else {
//       print("Location permission denied");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blueAccent,
//         title: Text(
//           "Nearest Ambulances",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         elevation: 4,
//       ),
//       body: ListView.builder(
//         physics: BouncingScrollPhysics(),
//         itemCount: ccid_.length,
//         itemBuilder: (BuildContext context, int index) {
//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
//             child: Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               elevation: 5,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _infoRow("🚑 Ambulance Number:", AmbulanceNumber_[index]),
//                     Divider(),
//                     _infoRow("🏥 Hospital:", Hospital_[index]),
//                     Divider(),
//                     _infoRow("🛠 Type:", Type_[index]),
//                     Divider(),
//                     _infoRow("📍 Latitude:", Latitude_[index]),
//                     _infoRow("📍 Longitude:", Longitude_[index]),
//                     Divider(),
//                     _statusChip(Status_[index]),
//                     const SizedBox(height: 16),
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         openMap(
//                           double.parse(Latitude_[index]),
//                           double.parse(Longitude_[index]),
//                         );
//                       },
//                       icon: const Icon(Icons.map, color: Colors.white),
//                       label: const Text("Track"),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.redAccent,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 8, horizontal: 10),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _infoRow(String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 15,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(width: 6),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(fontSize: 15, color: Colors.black54),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _statusChip(String status) {
//     Color chipColor = status == "Available" ? Colors.green : Colors.orange;
//     return Align(
//       alignment: Alignment.centerRight,
//       child: Chip(
//         label: Text(
//           status,
//           style: const TextStyle(color: Colors.white),
//         ),
//         backgroundColor: chipColor,
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class ViewNearestAmbulances extends StatelessWidget {
  const ViewNearestAmbulances({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nearest Ambulances',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const ViewNearestAmbulancesPage(title: 'Nearest Ambulances'),
    );
  }
}

class ViewNearestAmbulancesPage extends StatefulWidget {
  const ViewNearestAmbulancesPage({super.key, required this.title});
  final String title;

  @override
  State<ViewNearestAmbulancesPage> createState() => _ViewNearestAmbulancesPageState();
}

class _ViewNearestAmbulancesPageState extends State<ViewNearestAmbulancesPage> {
  List<String> ccid_ = [];
  List<String> AmbulanceNumber_ = [];
  List<String> Hospital_ = [];
  List<String> Type_ = [];
  List<String> Status_ = [];
  List<String> Latitude_ = [];
  List<String> Longitude_ = [];

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    initializeNotifications();
    load();
  }

  // Initialize local notifications
  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: androidInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request notification permission for Android 13+
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  // Load nearest ambulances from API
  Future<void> load() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("url") ?? ""; // Fallback if URL is not set

      if (ip.isEmpty) {
        print("Error: API URL not found in SharedPreferences");
        return;
      }

      String url = "${ip}view_nearest_ambulances";
      print("Fetching data from: $url");

      var response = await http.post(Uri.parse(url));

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        String status = jsondata['status'];
        var arr = jsondata["data"];

        print("Response Data: $arr");

        if (status == "ok") {
          setState(() {
            ccid_ = arr.map<String>((e) => e['id'].toString()).toList();
            AmbulanceNumber_ = arr.map<String>((e) => e['Ambulance'].toString()).toList();
            Hospital_ = arr.map<String>((e) => e['Hospital'].toString()).toList();
            Type_ = arr.map<String>((e) => e['Type'].toString()).toList();
            Status_ = arr.map<String>((e) => e['Status'].toString()).toList();
            Latitude_ = arr.map<String>((e) => e['Latitude'].toString()).toList();
            Longitude_ = arr.map<String>((e) => e['Longitude'].toString()).toList();
          });

          await showNotification("New Ambulances Available!", "Tap to check nearest ambulances.");
        }
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  // Show a local notification
  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'ambulance_channel_id',
      'Ambulance Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
    );
  }

  // Open Google Maps with given coordinates
  Future<void> openMap(double lat, double lon) async {
    final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lon");

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      print("Could not launch $googleMapsUrl");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text("Nearest Ambulances", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 4,
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: ccid_.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow("🚑 Ambulance Number:", AmbulanceNumber_[index]),
                    const Divider(),
                    _infoRow("🏥 Hospital:", Hospital_[index]),
                    const Divider(),
                    _infoRow("🛠 Type:", Type_[index]),
                    const Divider(),
                    _infoRow("📍 Latitude:", Latitude_[index]),
                    _infoRow("📍 Longitude:", Longitude_[index]),
                    const Divider(),
                    _statusChip(Status_[index]),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        openMap(double.parse(Latitude_[index]), double.parse(Longitude_[index]));
                      },
                      icon: const Icon(Icons.map, color: Colors.white),
                      label: const Text("Track"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
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

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 15, color: Colors.black54), overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color chipColor = status == "Available" ? Colors.green : Colors.orange;
    return Align(
      alignment: Alignment.centerRight,
      child: Chip(label: Text(status, style: const TextStyle(color: Colors.white)), backgroundColor: chipColor),
    );
  }
}
