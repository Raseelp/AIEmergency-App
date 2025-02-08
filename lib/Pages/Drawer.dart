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
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text("User"),
            accountEmail: Text("user@example.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 50, color: Colors.blueAccent),
            ),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildDrawerItem(context, Icons.home, "Home", Home()),
                _buildDrawerItem(context, Icons.local_hospital,
                    "View Nearest Ambulances", ViewNearestAmbulances()),
                _buildDrawerItem(context, Icons.notification_important,
                    "Emergency Alerts", SendAlert()),
                _buildDrawerItem(context, Icons.traffic,
                    "Traffic Notifications", ViewNearestNotification()),
                _buildDrawerItem(
                    context, Icons.feedback, "Send Feedback", SendFeedback()),
                Divider(),
                _buildDrawerItem(context, Icons.logout, "Logout", const login(),
                    isLogout: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    Widget destination, {
    bool isLogout = false,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => destination,
            ));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(
              8.0,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
