import 'package:emergency_vehicle/Pages/send%20alert.dart';
import 'package:emergency_vehicle/Pages/send_feedback.dart';
import 'package:emergency_vehicle/Pages/send_patient_info.dart';
import 'package:emergency_vehicle/Pages/view_hospital_message_ambulanced.dart';
import 'package:emergency_vehicle/Pages/view_nearest_ambulances.dart';
import 'package:flutter/material.dart';

import 'Viewtrafficnoti.dart';
import 'home.dart';
import 'login.dart';

class AmbulanceDraweClass extends StatelessWidget {
  const AmbulanceDraweClass({Key? key}) : super(key: key);

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
              "Ambulance",
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
            title: const Text("View Messages From Hospital"),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ViewAmbulanceMessgae()));
            },
          ),
          ListTile(
            leading: IconButton(
                onPressed: () {}, icon: const Icon(Icons.directions_bus)),
            title: const Text("Send Patient Info To Hosptital"),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SendPatientInfo()));
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
            title: const Text("Send Emergency Info To Hospital"),
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
            title: const Text("Ambulance Location Updation"),
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
