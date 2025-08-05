import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final _controller = TextEditingController();
  final _userService = UserService();
  String? _message;

  void _submit() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final friend = await _userService.getUserByUid5(_controller.text.trim());
    if (friend == null) {
      setState(() => _message = 'Không tìm thấy người dùng này.');
      return;
    }

    await _userService.addFriend(currentUser.uid, friend.uid);
    setState(() => _message = 'Kết bạn thành công với ${friend.email}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kết bạn qua ID')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Nhập ID 5 số'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _submit, child: Text('Kết bạn')),
            if (_message != null) ...[
              const SizedBox(height: 20),
              Text(_message!),
            ]
          ],
        ),
      ),
    );
  }
}

