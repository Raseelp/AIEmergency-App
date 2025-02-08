import 'package:emergency_vehicle/Pages/send%20alert.dart';
import 'package:emergency_vehicle/Pages/send_feedback.dart';
import 'package:emergency_vehicle/Pages/view_nearest_ambulances.dart';
import 'package:flutter/material.dart';

import 'Viewtrafficnoti.dart';
import 'home.dart';
import 'login.dart';

class Drawerclass extends StatelessWidget {
  const Drawerclass({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.red,
            ),
            child: Text(
              "User",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: IconButton(
              onPressed: () {
                // Handle icon button press
              },
              icon: const Icon(Icons.home),
            ),
            title: const Text("Home"),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Home()));
            },
          ),
          ListTile(
            leading: IconButton(
                onPressed: () {}, icon: const Icon(Icons.directions_bus)),
            title: const Text("View Nearest Ambulance Services"),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ViewNearestAmbulances()));
            },
          ),
          ListTile(
            leading: IconButton(
                onPressed: () {}, icon: const Icon(Icons.directions_bus)),
            title: const Text("View Nearest Ambulance alertsss"),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SendAlert()));
            },
          ),
          // ListTile(
          //   leading: IconButton(onPressed: () {}, icon: const Icon(Icons.bus_alert),),
          //   title: const Text("View Status and info of Selected Ambulance"),
          //   onTap: () {
          //     Navigator.push(context, MaterialPageRoute(builder: (context) => ViewStatusSelectedAmbulance()));
          //
          //   },
          // ),

          ListTile(
            leading: IconButton(
                onPressed: () {}, icon: const Icon(Icons.book_online)),
            title: const Text("Traffic Notification"),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ViewNearestNotification()));
            },
          ),
          ListTile(
            leading:
                IconButton(onPressed: () {}, icon: const Icon(Icons.feedback)),
            title: const Text("Send Feedback"),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SendFeedback()));
            },
          ),
          //        ListTile(
          //          leading: IconButton(onPressed: () {}, icon: const Icon(Icons.payment)),
          //          title: const Text("SCAN QR AND PAY"),
          //            onTap: () {
          //              // Navigator.push(context, MaterialPageRoute(builder: (context) => YourScreen()));
          //
          //            },
          //
          //
          //
          // ),

          ListTile(
            leading:
                IconButton(onPressed: () {}, icon: const Icon(Icons.logout)),
            title: const Text("Logout"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const login()),
              );
            },
          ),
        ],
      ),
    );
  }
}
