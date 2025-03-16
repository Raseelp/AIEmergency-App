import 'package:flutter/material.dart';
import 'package:emergency_vehicle/Pages/Ambulance/ambulance_home.dart';
import 'package:emergency_vehicle/Pages/User/send_feedback.dart';
import 'package:emergency_vehicle/Pages/Ambulance/send_patient_info.dart';
import 'package:emergency_vehicle/Pages/Ambulance/view_hospital_message_ambulanced.dart';
import '../Auth/login.dart';

class AmbulanceDrawer extends StatelessWidget {
  const AmbulanceDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const Column(
              children: [
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.local_hospital,
                      size: 50, color: Colors.blueAccent),
                ),
                SizedBox(height: 10),
                Text(
                  "Ambulance",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  "Ambulance@example.com",
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  _buildDrawerItem(
                      context, Icons.home, "Home", const AmbulanceHome()),
                  _buildDrawerItem(
                    context,
                    Icons.local_hospital,
                    "View Messages From Hospital",
                    const ViewAmbulanceMessgaepagePage(title: ''),
                  ),
                  _buildDrawerItem(context, Icons.notification_important,
                      "Send Patient Info", SendPatientInfo()),
                  _buildDrawerItem(context, Icons.update,
                      "Ambulance Location Updation", SendFeedback()),
                  const Divider(),
                  _buildDrawerItem(
                      context, Icons.logout, "Logout", const login(),
                      isLogout: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, IconData icon, String title, Widget destination,
      {bool isLogout = false}) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => destination)),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isLogout ? Colors.redAccent : Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: isLogout ? Colors.white : Colors.blueAccent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isLogout ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
