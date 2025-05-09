import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewNearestNotification extends StatelessWidget {
  const ViewNearestNotification({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
      ),
      home: const ViewTraficNotificarion(title: 'Flutter Demo Home Page'),
      routes: {},
    );
  }
}

class ViewTraficNotificarion extends StatefulWidget {
  const ViewTraficNotificarion({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<ViewTraficNotificarion> createState() => _ViewTraficNotificarionState();
}

class _ViewTraficNotificarionState extends State<ViewTraficNotificarion> {
  int _counter = 0;

  _ViewTraficNotificarionState() {
    load();
  }

  List<String> ccid_ = <String>[];
  List<String> notification_ = <String>[];
  List<String> date_ = <String>[];
  // List<String> Type_ = <String>[];
  // List<String> Status_ = <String>[];
  // List<String> department_= <String>[];
  // List<String> age_ = <String>[];
  // List<String> gender_ = <String>[];

  Future<void> load() async {
    List<String> ccid = <String>[];
    List<String> notification = <String>[];
    List<String> date = <String>[];
    List<String> Type = <String>[];
    List<String> Status = <String>[];
    // List<String> department = <String>[];
    // List<String> age = <String>[];
    // List<String> gender = <String>[];

    try {
      final pref = await SharedPreferences.getInstance();
      // String vid= pref.getString("rid").toString();
      String ip = pref.getString("url").toString();
      // String lid= pref.getString("lid").toString();

      String url = ip + "view_nearest_traffic_notifivcation";
      print(url);
      var data = await http.post(Uri.parse(url), body: {
        // 'rid':vid
      });

      var jsondata = json.decode(data.body);
      String status = jsondata['status'];

      var arr = jsondata["data"];

      print(arr);

      print(arr.length);

      // List<String> schid_ = <String>[];
      // List<String> Name_ = <String>[];
      // List<String> type_ = <String>[];

      for (int i = 0; i < arr.length; i++) {
        ccid.add(arr[i]['id'].toString());
        notification.add(arr[i]['notification'].toString());
        date.add(arr[i]['date'].toString());

        // Phone.add(arr[i]['phone'].toString());
        // department.add(arr[i]['department'].toString());
        // age.add(arr[i]['age'].toString());
        // gender.add(arr[i]['gender'].toString());
      }
      setState(() {
        ccid_ = ccid;
        notification_ = notification;
        date_ = date;
        // Type_ = Type;
        // Status_ = Status;
        // department_ = department;
        // age_ = age;
        // gender_ = gender;
      });
      print(status);
    } catch (e) {
      print("Error ------------------- " + e.toString());
      //there is error during converting file image to base64 encoding.
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: notification_.length,
        itemBuilder: (context, index) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  const BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  children: [
                    const Icon(Icons.notifications,
                        color: Colors.redAccent, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification_[index],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            formatDate(date_[index]),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
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

  String formatDate(String rawDate) {
    try {
      DateTime dateTime = DateTime.parse(rawDate);
      return DateFormat("MMM dd, yyyy - HH:mm").format(dateTime);
    } catch (e) {
      return rawDate;
    }
  }
}
