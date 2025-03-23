import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MedicalChatbot extends StatefulWidget {
  const MedicalChatbot({super.key});

  @override
  _MedicalChatbotState createState() => _MedicalChatbotState();
}

class _MedicalChatbotState extends State<MedicalChatbot> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, String>> messages = [];
  bool isLoading = false;

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
      isLoading = true;
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
          isLoading = false;
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

  TextSpan formatMessage(String message) {
    final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');
    List<TextSpan> spans = [];
    int start = 0;

    // Match all bold patterns
    for (final match in boldPattern.allMatches(message)) {
      // Normal text before the bold pattern
      if (match.start > start) {
        spans.add(TextSpan(
          text: message.substring(start, match.start),
          style: const TextStyle(color: Colors.black87),
        ));
      }

      // Bold text
      spans.add(TextSpan(
        text: match.group(1),
        style:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
      ));

      start = match.end;
    }

    // Add remaining normal text
    if (start < message.length) {
      spans.add(TextSpan(
        text: message.substring(start),
        style: const TextStyle(color: Colors.black87),
      ));
    }

    return TextSpan(children: spans);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 50), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Center(child: Text("Medical Chatbot")),
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
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
                  controller: _scrollController,
                  itemCount: isLoading ? messages.length + 1 : messages.length,
                  itemBuilder: (context, index) {
                    if (isLoading && index == messages.length) {
                      _scrollToBottom();

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                LoadingAnimationWidget.fourRotatingDots(
                                  color: Colors.blueAccent,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "Anuuu is thinking...",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    bool isUser = messages[index]["role"] == "user";
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                offset: Offset(0, 0),
                              ),
                            ],
                            color:
                                isUser ? Colors.blueAccent : Colors.grey[300],
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
                          child: RichText(
                            text: isUser
                                ? TextSpan(
                                    text: messages[index]["message"],
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 15),
                                  )
                                : formatMessage(messages[index]["message"]!),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
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
                        _scrollToBottom();
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
      ),
    );
  }
}
