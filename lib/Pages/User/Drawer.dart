import 'package:flutter/material.dart';
import 'home.dart';
import '../Auth/login.dart';
import 'package:emergency_vehicle/Pages/send%20alert.dart';
import 'package:emergency_vehicle/Pages/User/send_feedback.dart';
import 'package:emergency_vehicle/Pages/User/view_nearest_ambulances.dart';
import 'Viewtrafficnoti.dart';

class Drawerclass extends StatelessWidget {
  const Drawerclass({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Profile Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.person, size: 35, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "User",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "user@example.com",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Drawer Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
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
                const Divider(thickness: 1, indent: 16, endIndent: 16),
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
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.redAccent : Colors.black54),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isLogout ? FontWeight.w600 : FontWeight.w400,
          color: isLogout ? Colors.redAccent : Colors.black,
        ),
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => destination,
            ));
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      hoverColor: Colors.blueAccent.withOpacity(0.1), // Subtle hover effect
    );
  }
}
