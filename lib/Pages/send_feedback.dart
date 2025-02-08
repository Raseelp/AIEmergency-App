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
  int _selectedEmoji = 3; // Default to neutral
  final List<String> emojiLabels = [
    "Very Bad",
    "Bad",
    "Neutral",
    "Good",
    "Excellent"
  ];
  final List<IconData> emojiIcons = [
    Icons.sentiment_very_dissatisfied,
    Icons.sentiment_dissatisfied,
    Icons.sentiment_neutral,
    Icons.sentiment_satisfied,
    Icons.sentiment_very_satisfied
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Feedback", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "How was your experience with the emergency service?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "Your feedback helps us improve ambulance response and efficiency.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(emojiIcons.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedEmoji = index;
                    });
                  },
                  child: Column(
                    children: [
                      Icon(
                        emojiIcons[index],
                        size: 40,
                        color: _selectedEmoji == index
                            ? Colors.orangeAccent
                            : Colors.grey,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        emojiLabels[index],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _selectedEmoji == index
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }),
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
                maxLines: 4,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Add a comment...",
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
                  var jsonData = json.decode(data.body);
                  String status = jsonData['task'].toString();

                  if (status == "ok") {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Home()));
                  } else {
                    print("Error sending feedback");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Submit Now",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
