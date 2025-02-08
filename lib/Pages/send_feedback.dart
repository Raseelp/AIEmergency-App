import 'dart:convert';
import 'package:emergency_vehicle/Pages/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SendFeedback extends StatefulWidget {
  @override
  _SendFeedbackState createState() => _SendFeedbackState();
}

class _SendFeedbackState extends State<SendFeedback> {
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Write a New Feedback",style: TextStyle(color: Colors.white),),
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
              "We value your feedback! Let us know your thoughts.",
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
                controller: _feedbackController,
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
                  String feedback = _feedbackController.text.trim();
                  String url = sh.getString("url").toString();
                  String lid = sh.getString("lid").toString();

                  var data = await http.post(
                    Uri.parse(url + "sendfeedback"),
                    body: {'feedback': feedback, 'lid': lid},
                  );
                  var jasondata = json.decode(data.body);
                  String status = jasondata['task'].toString();

                  if (status == "ok") {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
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
                  "Submit Feedback",
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
