import 'dart:convert';
import 'package:emergency_vehicle/Pages/ambulance_home.dart';
import 'package:emergency_vehicle/Pages/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SendPatientInfo extends StatefulWidget {
  @override
  _SendPatientInfoState createState() => _SendPatientInfoState();
}

class _SendPatientInfoState extends State<SendPatientInfo> {
  final TextEditingController _patient_infoController = TextEditingController();

  @override
  void dispose() {
    _patient_infoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Write a New patient_info",style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Enter the condition of the patient",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _patient_infoController,
                maxLines: 5,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Enter your message...",
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final sh = await SharedPreferences.getInstance();
                  String patient_info = _patient_infoController.text.trim();
                  String url = sh.getString("url").toString();
                  String lid = sh.getString("lid").toString();

                  var data = await http.post(
                    Uri.parse(url + "send_patient_info"),
                    body: {'patient_info': patient_info, 'lid': lid},
                  );
                  var jasondata = json.decode(data.body);
                  String status = jasondata['task'].toString();

                  if (status == "ok") {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AmbulanceHome()));
                  } else {
                    print("error");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Submit patient_info",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
