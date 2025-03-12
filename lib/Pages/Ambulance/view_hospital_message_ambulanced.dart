import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ViewAmbulanceMessgaepagePage extends StatefulWidget {
  const ViewAmbulanceMessgaepagePage({super.key, required this.title});

  final String title;

  @override
  State<ViewAmbulanceMessgaepagePage> createState() =>
      _ViewAmbulanceMessgaepagePage();
}

class _ViewAmbulanceMessgaepagePage
    extends State<ViewAmbulanceMessgaepagePage> {
  int _counter = 0;

  _ViewAmbulanceMessgaepagePage() {
    view_college();
  }

  List<String> cid_ = <String>[];
  List<String> EmergencyMessage_ = <String>[];
  List<String> date_ = <String>[];
  // List<String> caddress_ = <String>[];
  // List<String> cphone_= <String>[];
  // List<String> cemail_ = <String>[];

  Future<void> view_college() async {
    List<String> cid = <String>[];
    List<String> EmergencyMessage = <String>[];
    List<String> date = <String>[];
    // List<String> caddress = <String>[];
    // List<String> cemail = <String>[];
    // List<String> cphone = <String>[];

    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("url").toString();
      // String lid= pref.getString("lid").toString();

      String url = ip + "view_messages_from_hospital";
      print(url);
      print("=========================");

      var data = await http.post(Uri.parse(url), body: {});
      var jsondata = json.decode(data.body);
      String status = jsondata['status'];

      var arr = jsondata["data"];

      print(arr);

      print(arr.length);

      for (int i = 0; i < arr.length; i++) {
        print("okkkkkkkkkkkkkkkkkkkkkkkk");
        cid.add(arr[i]['id'].toString());
        EmergencyMessage.add(arr[i]['EmergencyMessage'].toString());
        date.add(arr[i]['date'].toString());
        // caddress.add(arr[i]['regno'].toString());
        // cphone.add(arr[i]['phone'].toString());
        // cemail.add(arr[i]['email'].toString());
        print("ppppppppppppppppppp");
      }

      setState(() {
        cid_ = cid;
        EmergencyMessage_ = EmergencyMessage;
        date_ = date;

        // caddress_ = caddress;
        // cemail_ = cemail;
        // cphone_ = cphone;
      });

      print(cid_.length);
      print("+++++++++++++++++++++");
      print(status);
    } catch (e) {
      print("Error ------------------- " + e.toString());
      //there is error during converting file image to base64 encoding.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "View Messages Hospital",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: EmergencyMessage_.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Message Row
                    Row(
                      children: [
                        const Icon(Icons.message, color: Colors.blueAccent),
                        const SizedBox(width: 10),
                        const Text(
                          "Message:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            EmergencyMessage_[index],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Date & Time Row
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: Colors.blueAccent),
                        const SizedBox(width: 10),
                        const Text(
                          "Date & Time:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            formatDate(date_[index]),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Button Section
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: () {
                          print("View Details Pressed");
                        },
                        child: const Text(
                          "View Details",
                          style: TextStyle(color: Colors.white),
                        ),
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
