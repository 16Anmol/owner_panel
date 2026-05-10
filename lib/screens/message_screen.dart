import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  // Sample chat data
  static const List<Map<String, dynamic>> _chats = [
    {
      'name': 'Gaytari',
      'msg': 'Thank you for information',
      'time': '1:22 AM',
      'unread': true,
      'avatar': 'G',
      'color': Color(0xFFE8D5C4),
    },
    {
      'name': 'Sonia Sharma',
      'msg': 'Hi there, the price is negotiable',
      'time': '8:22 PM',
      'unread': true,
      'avatar': 'S',
      'color': Color(0xFFD4C5B8),
    },
    {
      'name': 'Karan Khurana',
      'msg': 'Have a plan for discuss this ?',
      'time': '8:22 PM',
      'unread': true,
      'avatar': 'K',
      'color': Color(0xFFC9BAB0),
    },
    {
      'name': 'Rehmat Kaur',
      'msg': 'Have a plan for discuss this ?',
      'time': '8:22 PM',
      'unread': false,
      'avatar': 'R',
      'color': Color(0xFFBFB0A8),
    },
    {
      'name': 'Leena',
      'msg': 'Have a plan for discuss this ?',
      'time': '8:22 PM',
      'unread': false,
      'avatar': 'L',
      'color': Color(0xFFD4C5B8),
    },
    {
      'name': 'Ashdeep',
      'msg': 'Have a plan for discuss this ?',
      'time': '8:22 PM',
      'unread': false,
      'avatar': 'A',
      'color': Color(0xFFE0D0C5),
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Toggle: set to true to show populated list, false for empty state
    const bool hasMessages = true;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: AppColors.textDark),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Message',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search_rounded,
                        size: 24, color: AppColors.textDark),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            Expanded(
              child: hasMessages ? _buildList(context) : _buildEmpty(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration placeholder
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_chat_unread_outlined,
              size: 80,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'No message yet',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          const Text(
            'You can start a chat anytime.',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Text(
            'All Message',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: _chats.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              indent: 72,
              color: AppColors.border,
            ),
            itemBuilder: (context, i) {
              final chat = _chats[i];
              return _ChatTile(chat: chat);
            },
          ),
        ),
      ],
    );
  }
}

class _ChatTile extends StatelessWidget {
  final Map<String, dynamic> chat;
  const _ChatTile({required this.chat});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(
            name: chat['name'] as String,
            avatar: chat['avatar'] as String,
            avatarColor: chat['color'] as Color,
          ),
        ),
      ),
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: chat['color'] as Color,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  chat['avatar'] as String,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Name + Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat['name'] as String,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    chat['msg'] as String,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Time + Unread dot
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat['time'] as String,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textLight),
                ),
                const SizedBox(height: 6),
                if (chat['unread'] as bool)
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(width: 9, height: 9),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Individual Chat Screen ──
class ChatDetailScreen extends StatefulWidget {
  final String name;
  final String avatar;
  final Color avatarColor;

  const ChatDetailScreen({
    super.key,
    required this.name,
    required this.avatar,
    required this.avatarColor,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {'text': 'Hello! I am interested in your property.', 'isMe': false, 'time': '8:20 PM'},
    {'text': 'Hi! Thank you for your interest. Which property are you looking at?', 'isMe': true, 'time': '8:21 PM'},
    {'text': 'Have a plan for discuss this ?', 'isMe': false, 'time': '8:22 PM'},
    {'text': 'Sure! We can schedule a call. When are you free?', 'isMe': true, 'time': '8:22 PM'},
  ];

  void _send() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'text': text, 'isMe': true, 'time': 'Just now'});
      _msgCtrl.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border))),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: AppColors.textDark),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: widget.avatarColor, shape: BoxShape.circle),
                    child: Center(
                      child: Text(widget.avatar,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.name,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark)),
                        const Text('Online',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.success)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.call_outlined,
                        color: AppColors.primary, size: 22),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // ── Messages ──
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final m = _messages[i];
                  final isMe = m['isMe'] as bool;
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isMe ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(14),
                          topRight: const Radius.circular(14),
                          bottomLeft: Radius.circular(isMe ? 14 : 2),
                          bottomRight: Radius.circular(isMe ? 2 : 14),
                        ),
                        border: isMe ? null : Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(m['text'] as String,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: isMe ? Colors.white : AppColors.textDark,
                                  height: 1.4)),
                          const SizedBox(height: 4),
                          Text(m['time'] as String,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: isMe
                                      ? Colors.white.withOpacity(0.7)
                                      : AppColors.textLight)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── Input Bar ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.border))),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _msgCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                    ),
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
