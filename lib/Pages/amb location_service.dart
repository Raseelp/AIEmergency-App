
// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';

// import 'package:geolocator/geolocator.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// // import 'package:awesome_notifications/awesome_notifications.dart';
// // import 'dart:io';
// // /import 'package:flutter_isolate/flutter_isolate.dart';
// void backgroundTask( String s) {
//   Timer.periodic(Duration(seconds: 20), (timer) {
//     location_fn();
//     // Perform your periodic task here
//     //print('Background task executed at ${DateTime.now()}');
//   });
// }
// class AmbPP extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: ShakeDetectionDemo(),
//     );
//   }
// }



// class ShakeDetectionDemo extends StatefulWidget {
//   @override
//   _ShakeDetectionDemoState createState() => _ShakeDetectionDemoState();
// }
// class location_fn
// {
//   String lat="0";
//   String lon="0";
//   Future<String> location()
//   async {



//     Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

// print("Location");
// print(position);
//     lat=position.latitude.toString();
//     lon=position.longitude.toString();
//     return position.latitude.toString()+"#"+position.longitude.toString();

//   }
//   String loc_send()
//   {
//     //print("++++++++++++++++++++++");
//     //print("++++++++++++++++++++++");
//     //print("++++++++++++++++++++++");
//     location();
//     //print(lat+"#"+lon);
//     return lat+"#"+lon;
//   }
// }
// class _ShakeDetectionDemoState extends State<ShakeDetectionDemo> {
//   double _accelerometerX = 0.0;
//   double _accelerometerY = 0.0;
//   double _accelerometerZ = 0.0;
//   String checkingstatus = "0";
//   String usertype = "0";
//   bool _isShaking = false;
//   location_fn ob=location_fn();
//   // bool _status=true;
//   Future<String> checkfn()
//   async {
//     final sh = await SharedPreferences.getInstance();
//     // String lid=sh.getString("lid").toString();
//     checkingstatus=sh.getString("lid").toString();
//     usertype=sh.getString("type").toString();
//     return sh.getString("lid").toString();
//   }
//   get flutterLocalNotificationsPlugin => null;
//   // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//   // FlutterLocalNotificationsPlugin();
//   // static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

//   // static const String name = 'Awesome Notifications - Example App';
//   // static const Color mainColor = Colors.deepPurple;
//   String s="0";
//   int i=0;
//   Timer? _timer;
//   int timelimit=12;

// // Request notification permission (Android 14+)

// // Show a test notification

//   void _startPeriodicTask() {
//     const duration = Duration(seconds:5); // Set the interval to 5 minutes
//     _timer = Timer.periodic(duration, (timer) async {
//       // Code to execute every 5 minutes
//       print('Executing task at ${DateTime.now()}');
//       ob.location();
//       String lids =checkfn().toString();


//       List<String> lll = ob.loc_send().split("#");
//       final sh = await SharedPreferences.getInstance();
//       sh.setString("lat", lll[0]);
//       sh.setString("lon", lll[1]);

//       String url = sh.getString("url") ?? "";
//                     String lid = sh.getString("lid") ?? "";

//       var data = await http.post(
//           Uri.parse(url + "updatelocation"),
//           body: {'lat': lll[0],
//             "lon": lll[1],
//             "lid": lid
//           });

//       var jasondata = json.decode(data.body);
//       String status = jasondata['task'].toString();
//       print(status + "+++++++++++++++====++----");













//       print(checkingstatus);
//     });
//   }
//   @override
//   void initState() {

//     _startPeriodicTask();
//     super.initState();



//   }






//   @override
//   void dispose() {
//     super.dispose();

//     // Cancel the accelerometer subscription when the widget is disposed

//   }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Shake Detection Demo'),
//       ),
//       body:
//       Center(

//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text('Accelerometer Data'),
//             Text('X: $_accelerometerX'),
//             Text('Y: $_accelerometerY'),
//             Text('Z: $_accelerometerZ'),

//             SizedBox(height: 20),
//             Text(
//               _isShaking ? 'Device is shaking!' : 'Device is not shaking.',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: _isShaking ? Colors.red : Colors.green,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );

//   }
// }
