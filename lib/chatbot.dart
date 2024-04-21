import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatMessage {
  final String text;
  final bool isUserMessage;
  final String timestamp;

  ChatMessage({
    required this.text,
    required this.isUserMessage,
    required this.timestamp,
  });
}


class QueryProvider with ChangeNotifier {
  final String _answer = '';
  final query = "";
  final bool _isLoading = false;


  bool get isLoading => _isLoading;
  String baseUrl = 'https://mindmender-lyqyv6cz3a-el.a.run.app';

  Future<String> getAnswer(String query) async {
    notifyListeners();
    print("query:$query");
    try {
      final response = await http.post(
          Uri.parse('$baseUrl/chat?query=$query')
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['response'];
      } else {
        throw Exception('Status ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error communicating with the API');
    }
  }
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {

  final List<List<ChatMessage>> _conversations = [];
  final TextEditingController _textController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final QueryProvider queryProvider = QueryProvider();
  void _sendMessage() async {
    String text = _textController.text;
    if (_textController.text.isNotEmpty) {
      if (_conversations.isEmpty || _conversations.last.isEmpty || !_conversations.last.last.isUserMessage) {
        _conversations.add([]);
      }
      _conversations.last.add(ChatMessage(
        text: _textController.text,
        isUserMessage: true,
        timestamp: DateTime.now().toString(),
      )
      );
      _textController.clear();
      try {
        String x = await queryProvider.getAnswer(text);
        _conversations.last.add(ChatMessage(
          text: x ?? "Bot is thinking...",
          isUserMessage: false,
          timestamp: DateTime.now().toString(),
        ));
      } catch (error) {
        _conversations.last.add(ChatMessage(
          text: "Sorry, there was an error: $error",
          isUserMessage: false,
          timestamp: DateTime.now().toString(),
        ));
      }
      setState(() {});
    }
  }

  void _openConversation(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Conversation ${index + 1}'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var message in _conversations[index])
                Text(message.text),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
          child: AppBar(
            backgroundColor: const Color(0xFF3F2A1B),
            title:  const Text(
              "MindVentor",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 25,
                fontFamily: 'RedditMono',
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  _scaffoldKey.currentState?.openEndDrawer();
                },
              ),
            ],
          ),
        ),
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF3F2A1B),
              ),
              child: Text(
                'Chat History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            for (int i = 0; i < _conversations.length; i++)
              ListTile(
                title: Text('Chat ${i + 1} - ${_conversations[i].last.timestamp}'),
                onTap: () {
                  _openConversation(i);
                },
              ),
          ],
        ),
      ),
      body: Container(
        color: const Color(0xFF1E1003),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 4.0),
          child: Container(
            color: Colors.black.withOpacity(0.3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildChatList(),
                ),
                _buildInputArea(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return Stack(
      children: [
        // Background image
        Image.asset(
          _conversations.isEmpty
              ? "assets/images/chatbotopen.png"
              : "assets/images/chatbotchat.png",
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        queryProvider.isLoading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : ListView.builder(
          itemCount: _conversations.length,
          itemBuilder: (context, index) {
            return _buildChatMessageList(_conversations[index]);
          },
        ),
      ],
    );
  }


  Widget _buildChatMessageList(List<ChatMessage> messages) {
    return Column(
      children: messages.map((message) => _buildChatMessage(message)).toList(),
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    return Row(
      mainAxisAlignment:
      message.isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!message.isUserMessage) _buildAvatar("bot"),
        Expanded(
          child: _buildMessageContainer(
            message.isUserMessage,
            message.text,
          ),
        ),
        if (message.isUserMessage) _buildAvatar("user"),
      ],
    );
  }

  Widget _buildAvatar(String avatarType) {
    return CircleAvatar(
      backgroundImage: AssetImage(avatarType == "user"
          ? "assets/images/chatbot_avatar.png"
          : "assets/images/ai_avatar.png"),
      radius: 20.0,
    );
  }

  Widget _buildMessageContainer(bool isUserMessage, String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isUserMessage ? Colors.blue[700] : Colors.lightBlue[100],
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Text(
        text,
        style: TextStyle(color: isUserMessage ? Colors.white : Colors.black),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      color: const Color(0xFF4E3523),
      padding: const EdgeInsets.all(15.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                border: Border.all(
                  color: const Color(0xFF4E3523),
                  width: 2.0,
                ),
                color: const Color(0xFF3B281C),
              ),
              child: TextField(
                controller: _textController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: " Say something...",
                  hintStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10.0,
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.lightGreen,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(blurRadius: 5, color: Colors.white)],
            ),
            child: IconButton(
              icon: const Icon(Icons.keyboard_return_rounded, color: Colors.white),
              onPressed: _sendMessage,
            ),
          )
        ],
      ),
    );
  }
}