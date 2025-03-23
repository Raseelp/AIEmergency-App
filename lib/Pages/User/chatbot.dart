import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MedicalChatbot extends StatefulWidget {
  const MedicalChatbot({super.key});

  @override
  _MedicalChatbotState createState() => _MedicalChatbotState();
}

class _MedicalChatbotState extends State<MedicalChatbot> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();
    loadChatHistory();
  }

  Future<void> loadChatHistory() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? chatHistory = sh.getString('chat_history');

      if (chatHistory != null) {
        List<dynamic> decodedList = json.decode(chatHistory);
        List<Map<String, String>> loadedMessages = [];
        for (var item in decodedList) {
          loadedMessages.add({
            "role": item["role"].toString(),
            "message": item["message"].toString(),
          });
        }
        setState(() {
          messages = loadedMessages;
        });
      }
    } catch (e) {
      print("Error loading chat history: $e");
    }
  }

  Future<void> saveChatHistory() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    await sh.setString('chat_history', json.encode(messages));
  }

  Future<void> sendMessage(String message) async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');

    setState(() {
      messages.add({"role": "user", "message": message});
    });
    await saveChatHistory();

    try {
      // Prepare the chat history as a list of messages
      List<String> chatHistory =
          messages.map((msg) => msg["message"]!).toList();

      final response = await http.post(
        Uri.parse(url! + 'medical_chatbot'),
        body: {
          'message': message,
          'chat_history': json.encode(chatHistory),
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          messages.add({"role": "bot", "message": responseData["response"]});
        });
      } else {
        setState(() {
          messages.add(
              {"role": "bot", "message": "Error: Unable to get a response!"});
        });
      }
    } catch (e) {
      setState(() {
        messages.add({"role": "bot", "message": "Error: $e"});
      });
    }

    await saveChatHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Medical Chatbot"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              SharedPreferences sh = await SharedPreferences.getInstance();
              await sh.remove('chat_history');
              setState(() {
                messages.clear();
              });
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    spreadRadius: 2,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  bool isUser = messages[index]["role"] == "user";
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blueAccent : Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: isUser
                                ? const Radius.circular(12)
                                : Radius.zero,
                            bottomRight: isUser
                                ? Radius.zero
                                : const Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: isUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              isUser ? "You" : "Bot",
                              style: TextStyle(
                                color: isUser ? Colors.white70 : Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              messages[index]["message"]!,
                              style: TextStyle(
                                color: isUser ? Colors.white : Colors.black87,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask a medical question...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: () async {
                    if (_controller.text.isNotEmpty) {
                      await sendMessage(_controller.text);
                      _controller.clear();
                    }
                  },
                  backgroundColor: Colors.blueAccent,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
