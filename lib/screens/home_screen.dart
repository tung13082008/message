// ✅ HomeScreen with Friend Requests Notification + Real-time Chat Navigation
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'add_friend_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final _users = FirebaseFirestore.instance.collection('users');

    return Scaffold(
      appBar: AppBar(
        title: const Text('👥 Danh sách bạn bè'),
        actions: [
          // 🔔 Icon thông báo lời mời kết bạn
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('friend_requests').doc(uid).snapshots(),
            builder: (context, snapshot) {
              int requestCount = 0;
              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                final from = List<String>.from(data['from'] ?? []);
                requestCount = from.length;
              }

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    tooltip: 'Lời mời kết bạn',
                    onPressed: () {
                      // TODO: Hiện dialog hoặc mở trang lời mời
                    },
                  ),
                  if (requestCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '$requestCount',
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Thêm bạn',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddFriendScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _users.doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("⚠️ Không tìm thấy tài khoản của bạn trên Firestore."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final myUid5 = data['uid5'] ?? 'Chưa có';
          final friendIds = List<String>.from(data['friends'] ?? []);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                color: Colors.blue.shade50,
                child: Text(
                  '🆔 Mã ID của bạn: $myUid5',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              const Divider(height: 0),
              Expanded(
                child: friendIds.isEmpty
                    ? const Center(child: Text('Bạn chưa có người bạn nào 😢'))
                    : ListView.builder(
                        itemCount: friendIds.length,
                        itemBuilder: (context, index) {
                          final friendUid = friendIds[index];
                          return StreamBuilder<DocumentSnapshot>(
                            stream: _users.doc(friendUid).snapshots(),
                            builder: (context, friendSnap) {
                              if (!friendSnap.hasData || !friendSnap.data!.exists) {
                                return const ListTile(title: Text('Đang tải bạn bè...'));
                              }
                              final friend = friendSnap.data!.data() as Map<String, dynamic>;
                              final email = friend['email'] ?? 'Không rõ';
                              final uid5 = friend['uid5'] ?? 'Ẩn';

                              return ListTile(
                                leading: const CircleAvatar(child: Icon(Icons.person)),
                                title: Text(email),
                                subtitle: Text('ID: $uid5'),
                                trailing: const Icon(Icons.chat_bubble_outline),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatScreen(
                                        currentUid5: myUid5,
                                        otherUid5: uid5,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
