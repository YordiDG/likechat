import 'package:flutter/material.dart';

import '../CustomUI/CustomCard.dart';
import '../Model/ChatModel.dart';
import '../Screens/SelectContact.dart';

class ChatPage extends StatefulWidget {
  final List<ChatModel> chatmodels;
  final ChatModel sourchat;

  ChatPage({required Key key, required this.chatmodels, required this.sourchat}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (builder) => SelectContact()),
          );
        },
        child: Icon(
          Icons.chat,
          color: Colors.white,
        ),
      ),
      body: ListView.builder(
        itemCount: widget.chatmodels.length,
        itemBuilder: (context, index) => CustomCard(
          chatModel: widget.chatmodels[index],
          sourchat: widget.sourchat,
        ),
      ),
    );
  }
}
