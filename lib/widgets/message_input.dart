import 'package:flutter/material.dart';
import '../services/chat_service.dart';

class MessageInput extends StatefulWidget {
  final String chatId;
  final String senderId;

  const MessageInput({
    super.key,
    required this.chatId,
    required this.senderId,
  });

  @override
  _MessageInputState createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();
  String _enteredText = '';

  void _send() async {
    if (_enteredText.trim().isEmpty) return;

    await ChatService().sendMessage(
      chatId: widget.chatId,
      senderId: widget.senderId,
      text: _enteredText.trim(),
    );

    _controller.clear();
    setState(() => _enteredText = '');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: (val) => setState(() => _enteredText = val),
              decoration: const InputDecoration(labelText: 'Nhập tin nhắn...'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _enteredText.trim().isEmpty ? null : _send,
          ),
        ],
      ),
    );
  }
}
