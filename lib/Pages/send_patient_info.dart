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
  final TextEditingController _patientInfoController = TextEditingController();
  bool _isLoading = false;
  @override
  void dispose() {
    _patientInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "New Patient Info",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Describe the Patient's Condition",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: _patientInfoController,
                maxLines: 5,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Enter patient details here...",
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        final sh = await SharedPreferences.getInstance();
                        String patient_info =
                            _patientInfoController.text.trim();
                        String url = sh.getString("url").toString();
                        String lid = sh.getString("lid").toString();

                        var data = await http.post(
                          Uri.parse(url + "send_patient_info"),
                          body: {'patient_info': patient_info, 'lid': lid},
                        );
                        var jasondata = json.decode(data.body);
                        String status = jasondata['task'].toString();

                        if (status == "ok") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AmbulanceHome()));
                        } else {
                          print("error");
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Submit Info",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitPatientInfo() async {
    setState(() {
      _isLoading = true;
    });

    final sh = await SharedPreferences.getInstance();
    String patientInfo = _patientInfoController.text.trim();
    String url = sh.getString("url").toString();
    String lid = sh.getString("lid").toString();

    try {
      var response = await http.post(
        Uri.parse("$url/send_patient_info"),
        body: {'patient_info': patientInfo, 'lid': lid},
      );

      var jsonData = json.decode(response.body);
      String status = jsonData['task'].toString();

      if (status == "ok") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Patient info submitted successfully!")),
        );
        Navigator.pushReplacementNamed(context, "/ambulanceHome");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error submitting patient info!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error, please try again.")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
