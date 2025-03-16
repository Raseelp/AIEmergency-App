import 'dart:convert';
import 'dart:io';
import 'package:emergency_vehicle/Pages/Ambulance/ambulance_home.dart';
import 'package:emergency_vehicle/Pages/User/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class SendPatientInfo extends StatefulWidget {
  @override
  _SendPatientInfoState createState() => _SendPatientInfoState();
}

class _SendPatientInfoState extends State<SendPatientInfo> {
  final TextEditingController _patientInfoController = TextEditingController();

  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  bool _isUplading = false;

  String? _filePath;

  @override
  void initState() {
    _initializeRecorder();
    super.initState();
  }

  @override
  void dispose() {
    _patientInfoController.dispose();
    _recorder.closeRecorder();
    super.dispose();
  }

  Future<void> _initializeRecorder() async {
    await _recorder.openRecorder();
    await Permission.microphone.request();
  }

  Future<void> _startRecording() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text('Started Recording, Describe the patients condition...'),
      ),
    );
    Directory tempDir = await getTemporaryDirectory();
    String filePath = '${tempDir.path}/audio_message.aac';

    await _recorder.startRecorder(toFile: filePath);
    setState(() {
      _isRecording = true;
      _filePath = filePath;
    });
  }

  Future<void> _stopRecording() async {
    String? path = await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
      _filePath = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title:
            const Text("Patient Info", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4A90E2),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A90E2), Color(0xFF145DA0)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _isRecording
                  ? const Text(
                      "Recording...",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Press the Button to Record",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
              const SizedBox(height: 8),
              _isRecording
                  ? const Text(
                      "Explain the condition of the Patient",
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    )
                  : const Text(
                      "Talk To the hospital about the Patients Condition",
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
              const SizedBox(height: 30),
              GestureDetector(
                  onTap: () {
                    if (_isRecording) {
                      _stopRecording(); // Stop recording and submit
                      setState(() {
                        _isUplading == true;
                      });
                      _uploadVoiceMessage(_isUplading);
                    } else {
                      _startRecording(); // Start recording
                    }
                  },
                  child: _isRecording
                      ? Container(
                          width: 150, // Size of the circular button
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors
                                .green, // Change color based on recording state
                            shape: BoxShape.circle, // Circular shape
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isRecording
                                ? Icons.stop
                                : Icons
                                    .mic, // Change icon based on recording state
                            color: Colors.white,
                            size: 40,
                          ),
                        )
                      : Container(
                          width: 100, // Size of the circular button
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors
                                .red, // Change color based on recording state
                            shape: BoxShape.circle, // Circular shape
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isRecording
                                ? Icons.stop
                                : Icons
                                    .mic, // Change icon based on recording state
                            color: Colors.white,
                            size: 40,
                          ),
                        )),
              const SizedBox(height: 20),
              if (_isUplading)
                const CircularProgressIndicator(), // Show a loading indicator while uploading
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadVoiceMessage(bool isUploading) async {
    if (_filePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No voice message recorded!')),
      );
      return;
    }
    final sh = await SharedPreferences.getInstance();

    String url = sh.getString("url").toString();
    String lid = sh.getString("lid").toString();

    var uri = Uri.parse(url! + 'upload_voice_message/');

    var request = http.MultipartRequest('POST', uri)
      ..fields['lid'] = lid
      ..files
          .add(await http.MultipartFile.fromPath('voice_message', _filePath!));

    var response = await request.send();

    if (response.statusCode == 201) {
      setState(() {
        isUploading == false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Voice message uploaded successfully!')),
      );
    } else {
      print('Error uploading voice message');
    }
  }

//   Future<void> _submitPatientInfo() async {
//     setState(() {
//       _isLoading = true;
//     });

  // final sh = await SharedPreferences.getInstance();
  // String patientInfo = _patientInfoController.text.trim();
  // String url = sh.getString("url").toString();
  // String lid = sh.getString("lid").toString();

//     try {
//       var response = await http.post(
//         Uri.parse("$url/send_patient_info"),
//         body: {'patient_info': patientInfo, 'lid': lid},
//       );

//       var jsonData = json.decode(response.body);
//       String status = jsonData['task'].toString();

//       if (status == "ok") {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Patient info submitted successfully!")),
//         );
//         Navigator.pushReplacementNamed(context, "/ambulanceHome");
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error submitting patient info!")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Network error, please try again.")),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
// }
}
