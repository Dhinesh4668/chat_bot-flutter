import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(ChatBotApp());
}

class ChatBotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gemini Key ChatBot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  final String apiKey = 'AIzaSyCiRpyTI2mKc2ZCn9pSRUYU8Jl4tSVjCZ8';
  final String geminiKeyEndpoint = 'https://api.geminikey.com/parse';

  void sendMessage(String messageText) async {
    messageController.clear();
    setState(() {
      messages.add({
        'text': messageText,
        'sender': 'user',
      });
    });

    final response = await http.post(
      Uri.parse(geminiKeyEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({'query': messageText}),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      String botResponse = data['response']['text'];
      setState(() {
        messages.add({
          'text': botResponse,
          'sender': 'bot',
        });
      });
    } else {
      print('Failed to fetch response');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gemini Key ChatBot'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(
                  text: messages[index]['text'],
                  sender: messages[index]['sender'],
                );
              },
            ),
          ),
          Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildMessageComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: messageController,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (value) {},
                decoration: InputDecoration.collapsed(
                  hintText: "Send a message",
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                if (messageController.text.isNotEmpty) {
                  sendMessage(messageController.text);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final String sender;

  MessageBubble({required this.text, required this.sender});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment:
            sender == 'bot' ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: <Widget>[
          sender == 'bot' ? _buildBotAvatar() : Container(),
          Expanded(
            child: Column(
              crossAxisAlignment: sender == 'bot'
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  sender == 'bot' ? 'Bot' : 'You',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5.0),
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: sender == 'bot'
                        ? Colors.grey[300]
                        : Theme.of(context).accentColor,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          sender == 'user' ? _buildUserAvatar() : Container(),
        ],
      ),
    );
  }

  Widget _buildBotAvatar() {
    return CircleAvatar(
      child: Text('B'),
      backgroundColor: Colors.blueGrey,
    );
  }

  Widget _buildUserAvatar() {
    return CircleAvatar(
      child: Text('U'),
      backgroundColor: Colors.blue,
    );
  }
}
