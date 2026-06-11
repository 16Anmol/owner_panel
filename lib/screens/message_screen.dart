import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

// ══════════════════════════════════════════════════════════════
//  Owner Chat List
// ══════════════════════════════════════════════════════════════
class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});
  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  List<dynamic> _chats = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.getOwnerChats();
      if (mounted)
        setState(() {
          _chats = res['chats'] as List? ?? [];
          _loading = false;
        });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.textDark),
        title: const Text('Messages',
            style: TextStyle(
                fontWeight: FontWeight.w800, color: AppColors.textDark)),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _chats.isEmpty
              ? const _EmptyChats()
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _chats.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final c = _chats[i] as Map<String, dynamic>;
                      final cust = c['customer'] as Map<String, dynamic>? ?? {};
                      final prop = c['property'] as Map<String, dynamic>? ?? {};
                      final unread = c['unreadByOwner'] as int? ?? 0;
                      final lastMsg =
                          c['lastMessage'] as String? ?? 'Start a conversation';
                      final lastTs = c['lastMessageAt'] as String?;

                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OwnerChatScreen(
                                  chatId: c['_id'] as String,
                                  customerName:
                                      cust['name'] as String? ?? 'Customer',
                                  plotName:
                                      prop['propertyName'] as String? ?? 'Plot',
                                ),
                              ));
                          _load();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: unread > 0
                                ? AppColors.primaryLight
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: unread > 0
                                  ? AppColors.primary.withValues(alpha: 0.3)
                                  : AppColors.border,
                              width: unread > 0 ? 1.5 : 1,
                            ),
                          ),
                          child: Row(children: [
                            // Avatar with unread badge
                            Stack(children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                    color: AppColors.primaryLight,
                                    shape: BoxShape.circle),
                                child: Center(
                                    child: Text(
                                  (cust['name'] as String? ?? 'C')[0]
                                      .toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary),
                                )),
                              ),
                              if (unread > 0)
                                Positioned(
                                    top: -2,
                                    right: -2,
                                    child: Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.white, width: 1.5)),
                                      child: Center(
                                          child: Text('$unread',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight:
                                                      FontWeight.w800))),
                                    )),
                            ]),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Row(children: [
                                    Expanded(
                                        child: Text(cust['name'] ?? 'Customer',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: unread > 0
                                                    ? FontWeight.w800
                                                    : FontWeight.w600,
                                                color: AppColors.textDark))),
                                    Text(_fmtTime(lastTs),
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: unread > 0
                                                ? AppColors.primary
                                                : AppColors.textLight,
                                            fontWeight: unread > 0
                                                ? FontWeight.w700
                                                : FontWeight.w400)),
                                  ]),
                                  const SizedBox(height: 2),
                                  Text('Re: ${prop['propertyName'] ?? 'Plot'}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 3),
                                  Text(lastMsg,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: unread > 0
                                              ? AppColors.textDark
                                              : AppColors.textMuted,
                                          fontWeight: unread > 0
                                              ? FontWeight.w600
                                              : FontWeight.w400),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ])),
                            const Icon(Icons.chevron_right_rounded,
                                color: AppColors.textLight),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  String _fmtTime(String? raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inSeconds < 60) return 'now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      return '${dt.day}/${dt.month}';
    } catch (_) {
      return '';
    }
  }
}

class _EmptyChats extends StatelessWidget {
  const _EmptyChats();
  @override
  Widget build(BuildContext context) => const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.chat_bubble_outline_rounded,
              size: 60, color: AppColors.textLight),
          SizedBox(height: 14),
          Text('No messages yet',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          SizedBox(height: 6),
          Text('Customer messages about your listings appear here',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        ]),
      );
}

// ══════════════════════════════════════════════════════════════
//  Owner Chat Screen (conversation view)
// ══════════════════════════════════════════════════════════════
class OwnerChatScreen extends StatefulWidget {
  final String chatId, customerName, plotName;
  const OwnerChatScreen({
    super.key,
    required this.chatId,
    required this.customerName,
    required this.plotName,
  });
  @override
  State<OwnerChatScreen> createState() => _OwnerChatScreenState();
}

class _OwnerChatScreenState extends State<OwnerChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<Map<String, dynamic>> _msgs = [];

  bool _loading = false;
  bool _sending = false;
  bool _uploading = false;
  String _uploadLabel = 'Uploading…';
  String? _blocked;
  String? _lastTs;
  Timer? _timer;

  // Voice recording
  final AudioRecorder _recorder = AudioRecorder();
  bool _recording = false;
  int _recSecs = 0;
  Timer? _recTimer;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_checkPhone);
    _loadMessages();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _poll());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recTimer?.cancel();
    _recorder.dispose();
    _ctrl.removeListener(_checkPhone);
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ── Record & send voice message ───────────────────────────────
  Future<void> _toggleRecord() async {
    if (_recording) {
      final path = await _recorder.stop();
      _recTimer?.cancel();
      if (mounted) setState(() => _recording = false);
      if (path == null) return;
      try {
        final bytes = await XFile(path).readAsBytes();
        if (mounted)
          setState(() {
            _uploading = true;
            _uploadLabel = 'Processing audio…';
          });
        final res = await ApiService.ownerUploadChatAudio(
            chatId: widget.chatId,
            bytes: bytes,
            fileName: 'voice.webm',
            duration: _recSecs);
        final msg = res['message'] as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            final idx = _msgs.indexWhere((e) => e['_id'] == msg['_id']);
            if (idx < 0) _msgs.add(msg);
            _lastTs = msg['createdAt'] as String?;
          });
          _scrollToBottom();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Voice send failed: $e'),
              backgroundColor: AppColors.error));
        }
      } finally {
        if (mounted) setState(() => _uploading = false);
      }
    } else {
      try {
        if (!await _recorder.hasPermission()) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Microphone permission denied')));
          }
          return;
        }
        await _recorder.start(const RecordConfig(encoder: AudioEncoder.opus),
            path: 'voice');
        if (mounted)
          setState(() {
            _recording = true;
            _recSecs = 0;
          });
        _recTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted) setState(() => _recSecs++);
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Could not start recording: $e'),
              backgroundColor: AppColors.error));
        }
      }
    }
  }

  // ── Phone detection ───────────────────────────────────────────
  bool _looksLikePhone(String t) {
    final s = t.replaceAll(RegExp(r'[\s\-.()+\/\\|_,]'), '');
    if (RegExp(r'\d{8,}').hasMatch(s)) return true;
    if (RegExp(r'\+\d[\d\s\-().]{7,14}\d').hasMatch(t)) return true;
    return RegExp(r'\b\d\b').allMatches(t).length >= 8;
  }

  void _checkPhone() {
    final blocked = _looksLikePhone(_ctrl.text);
    if (blocked != (_blocked != null)) {
      setState(() => _blocked =
          blocked ? '🚫 Phone numbers are not allowed in chat.' : null);
    }
  }

  // ── Load messages ─────────────────────────────────────────────
  Future<void> _loadMessages() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.getOwnerChatMessages(widget.chatId);
      final list = res['messages'] as List? ?? [];
      if (mounted) {
        setState(() {
          _msgs.clear();
          _msgs.addAll(list.cast<Map<String, dynamic>>());
          if (_msgs.isNotEmpty) _lastTs = _msgs.last['createdAt'] as String?;
          _loading = false;
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Poll ──────────────────────────────────────────────────────
  Future<void> _poll() async {
    if (!mounted) return;
    try {
      final since = _lastTs ??
          DateTime.now()
              .subtract(const Duration(seconds: 10))
              .toIso8601String();
      final res = await ApiService.ownerPollMessages(widget.chatId, since);
      final list = res['messages'] as List? ?? [];
      if (list.isNotEmpty && mounted) {
        setState(() {
          for (final m in list.cast<Map<String, dynamic>>()) {
            final idx = _msgs.indexWhere((e) => e['_id'] == m['_id']);
            if (idx >= 0) {
              _msgs[idx] = m;
            } else {
              _msgs.add(m);
            }
          }
          _msgs.sort((a, b) =>
              (a['createdAt'] as String).compareTo(b['createdAt'] as String));
          if (_msgs.isNotEmpty) _lastTs = _msgs.last['createdAt'] as String?;
        });
        _scrollToBottom();
      }
    } catch (_) {}
  }

  void _scrollToBottom() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(_scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut);
        }
      });

  // ── Pick & upload photo ───────────────────────────────────────
  Future<void> _pickPhoto() async {
    Uint8List bytes;
    String name;
    try {
      final picker = ImagePicker();
      final xf =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (xf == null) return;
      bytes = await xf.readAsBytes();
      name = xf.name;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Could not pick photo: $e'),
            backgroundColor: AppColors.error));
      }
      return;
    }

    setState(() {
      _uploading = true;
      _uploadLabel = 'Uploading photo…';
    });
    try {
      final res = await ApiService.ownerUploadChatPhoto(
          chatId: widget.chatId, bytes: bytes, fileName: name);
      final msg = res['message'] as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          final idx = _msgs.indexWhere((e) => e['_id'] == msg['_id']);
          if (idx < 0) _msgs.add(msg);
          _lastTs = msg['createdAt'] as String?;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  // ── Send text ─────────────────────────────────────────────────
  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _blocked != null) return;
    setState(() => _sending = true);
    try {
      final res =
          await ApiService.ownerSendMessage(chatId: widget.chatId, text: text);
      final msg = res['message'] as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          final idx = _msgs.indexWhere((e) => e['_id'] == msg['_id']);
          if (idx < 0) _msgs.add(msg);
          _lastTs = msg['createdAt'] as String?;
        });
        _ctrl.clear();
        _scrollToBottom();
      }
    } catch (e) {
      final err = e.toString().replaceAll('Exception: ', '');
      if (mounted) {
        if (err.contains('phone') || err.contains('blocked')) {
          setState(() => _blocked = '🚫 $err');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(err), backgroundColor: AppColors.error));
        }
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  // ── Delete message (for everyone) ────────────────────────────
  Future<void> _deleteMsg(String msgId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Message?',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: const Text(
            'This message will be deleted for both you and the other person.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      final res = await ApiService.ownerDeleteMessage(
          chatId: widget.chatId, msgId: msgId, scope: 'everyone');
      final updated = res['message'] as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          final idx = _msgs.indexWhere((m) => m['_id'] == msgId);
          if (idx >= 0) _msgs[idx] = updated;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error));
      }
    }
  }

  // ── Edit message ──────────────────────────────────────────────
  Future<void> _editMsg(String msgId, String currentText) async {
    final ctrl = TextEditingController(text: currentText);
    final newText = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Message',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: null,
          decoration: InputDecoration(
            hintText: 'Edit your message',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Save',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (newText == null ||
        newText.isEmpty ||
        newText == currentText ||
        !mounted) {
      return;
    }
    try {
      final res = await ApiService.ownerEditMessage(
          chatId: widget.chatId, msgId: msgId, newText: newText);
      final updated = res['message'] as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          final idx = _msgs.indexWhere((m) => m['_id'] == msgId);
          if (idx >= 0) _msgs[idx] = updated;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.textDark),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.customerName,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark)),
          Text('Re: ${widget.plotName}',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ]),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.shield_outlined, size: 12, color: AppColors.primary),
              SizedBox(width: 4),
              Text('Safe Chat',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ]),
          ),
        ],
      ),
      body: Column(children: [
        // Messages
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : _msgs.isEmpty
                  ? Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          const Icon(Icons.chat_bubble_outline_rounded,
                              size: 50, color: AppColors.textLight),
                          const SizedBox(height: 12),
                          Text('Reply to ${widget.customerName}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark)),
                          const SizedBox(height: 4),
                          const Text('Type a message below',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 13)),
                        ]))
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      itemCount: _msgs.length,
                      itemBuilder: (_, i) {
                        final m = _msgs[i];
                        final isMe = (m['senderType'] as String?) == 'owner';
                        final isDelFm = m['deletedForSender'] as bool? ?? false;
                        if (isDelFm) return const SizedBox.shrink();
                        final isDel = m['deletedForEveryone'] as bool? ?? false;
                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: _HoverMsgWrapper(
                            isMe: isMe,
                            isDeleted: isDel,
                            onEdit: () => _editMsg(
                                m['_id'] as String, m['text'] as String? ?? ''),
                            onDelete: () => _deleteMsg(m['_id'] as String),
                            child: _OwnerBubble(msg: m, isMe: isMe),
                          ),
                        );
                      },
                    ),
        ),

        // Upload progress
        if (_uploading)
          Container(
            color: AppColors.primaryLight,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      color: AppColors.primary, strokeWidth: 2)),
              const SizedBox(width: 10),
              Text(_uploadLabel,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600)),
            ]),
          ),

        // Recording indicator
        if (_recording)
          Container(
            color: const Color(0xFFFFEBEE),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              const Icon(Icons.fiber_manual_record,
                  color: AppColors.error, size: 13),
              const SizedBox(width: 8),
              Text('Recording…  ${_recSecs}s',
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.error,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              const Text('tap ■ to send',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ]),
          ),

        // Phone block warning
        if (_blocked != null)
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: AppColors.error.withValues(alpha: 0.35)),
            ),
            child: Row(children: [
              const Icon(Icons.block_rounded, color: AppColors.error, size: 15),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(_blocked!,
                      style: const TextStyle(
                          color: AppColors.error, fontSize: 12))),
            ]),
          ),

        // Input bar
        Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(
              10, 8, 8, MediaQuery.of(context).viewInsets.bottom + 10),
          child: Row(children: [
            // Photo button (web file picker)
            GestureDetector(
              onTap: _uploading ? null : _pickPhoto,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.add_photo_alternate_rounded,
                    size: 20, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 8),

            // Mic / record button
            GestureDetector(
              onTap: _uploading ? null : _toggleRecord,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _recording ? AppColors.error : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: (_recording ? AppColors.error : AppColors.primary)
                          .withValues(alpha: 0.3)),
                ),
                child: Icon(_recording ? Icons.stop_rounded : Icons.mic_rounded,
                    size: 20,
                    color: _recording ? Colors.white : AppColors.primary),
              ),
            ),
            const SizedBox(width: 8),

            // Text field
            Expanded(
              child: TextField(
                controller: _ctrl,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Reply…',
                  hintStyle:
                      const TextStyle(color: AppColors.textLight, fontSize: 14),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5)),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Send button
            GestureDetector(
              onTap: (_sending || _blocked != null) ? null : _send,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (_blocked != null || _sending)
                      ? AppColors.textLight
                      : AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: (_blocked != null)
                      ? []
                      : [
                          BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3))
                        ],
                ),
                child: _sending
                    ? const Center(
                        child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2)))
                    : const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  Hover wrapper — shows trash icon on hover / long-press
// ══════════════════════════════════════════════════════════════
class _HoverMsgWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isMe;
  final bool isDeleted;
  const _HoverMsgWrapper({
    required this.child,
    required this.onEdit,
    required this.onDelete,
    required this.isMe,
    this.isDeleted = false,
  });
  @override
  State<_HoverMsgWrapper> createState() => _HoverMsgWrapperState();
}

class _HoverMsgWrapperState extends State<_HoverMsgWrapper>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  bool _showMob = false;
  late AnimationController _anim;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 160));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _show() {
    _anim.forward();
  }

  void _hide() {
    _anim.reverse().then((_) {
      if (mounted)
        setState(() {
          _hovered = false;
          _showMob = false;
        });
    });
  }

  void _openMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
            title: const Text('Edit message',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.textDark)),
            onTap: () {
              Navigator.pop(sheetCtx);
              widget.onEdit();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded,
                color: AppColors.error),
            title: const Text('Delete for everyone',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.error)),
            onTap: () {
              Navigator.pop(sheetCtx);
              widget.onDelete();
            },
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDeleted) return widget.child;
    final show = _hovered || _showMob;

    // Only the sender sees the actions button — never on the other person's
    // messages. Tapping it opens a menu with exactly two options.
    final trashBtn = (show && widget.isMe)
        ? FadeTransition(
            opacity: _fade,
            child: GestureDetector(
              onTap: () {
                _hide();
                _openMenu();
              },
              child: Container(
                width: 30,
                height: 30,
                margin: EdgeInsets.only(
                  left: widget.isMe ? 6 : 0,
                  right: widget.isMe ? 0 : 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: const Icon(Icons.more_vert_rounded,
                    size: 18, color: AppColors.textMuted),
              ),
            ),
          )
        : null;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _hovered = true);
        _show();
      },
      onExit: (_) => _hide(),
      child: GestureDetector(
        onLongPress: () {
          setState(() => _showMob = true);
          _show();
        },
        onTap: () {
          if (_showMob) _hide();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!widget.isMe && trashBtn != null) trashBtn,
            Flexible(child: widget.child),
            if (widget.isMe && trashBtn != null) trashBtn,
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  Message bubble
// ══════════════════════════════════════════════════════════════
class _OwnerBubble extends StatelessWidget {
  final Map<String, dynamic> msg;
  final bool isMe;
  const _OwnerBubble({required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final text = msg['text'] as String? ?? '';
    final imageUrl = msg['imageUrl'] as String?;
    final audioUrl = msg['audioUrl'] as String?;
    final linkUrl = msg['linkUrl'] as String?;
    final isDeleted = msg['deletedForEveryone'] as bool? ?? false;
    final isEdited = msg['isEdited'] as bool? ?? false;
    final ts = _fmt(msg['createdAt'] as String?);

    if (isDeleted) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border)),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.block_rounded, size: 14, color: AppColors.textLight),
          SizedBox(width: 6),
          Text('This message was deleted',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textLight,
                  fontStyle: FontStyle.italic)),
        ]),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.68),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (audioUrl != null && audioUrl.isNotEmpty)
            _VoiceMessage(
              url: audioUrl.startsWith('http')
                  ? audioUrl
                  : 'http://localhost:5000$audioUrl',
              isMe: isMe,
              durationSecs: (msg['audioDuration'] as num?)?.toInt() ?? 0,
            ),
          if (imageUrl != null && imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl.startsWith('http')
                    ? imageUrl
                    : 'http://localhost:5000$imageUrl',
                width: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textLight),
              ),
            ),
          if (linkUrl != null && linkUrl.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: isMe ? Colors.transparent : AppColors.border),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.link_rounded,
                    size: 16, color: isMe ? Colors.white70 : AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(linkUrl,
                        style: TextStyle(
                            fontSize: 13,
                            color: isMe ? Colors.white : AppColors.primary,
                            decoration: TextDecoration.underline),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis)),
              ]),
            ),
          if (text.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                border: isMe ? null : Border.all(color: AppColors.border),
              ),
              child: Text(text,
                  style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: isMe ? Colors.white : AppColors.textDark)),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (isEdited)
                const Text('edited · ',
                    style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textLight,
                        fontStyle: FontStyle.italic)),
              Text(ts,
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textLight)),
            ]),
          ),
        ],
      ),
    );
  }

  String _fmt(String? raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m ${dt.hour >= 12 ? 'PM' : 'AM'}';
    } catch (_) {
      return '';
    }
  }
}

// ── Voice message player ─────────────────────────────────────
class _VoiceMessage extends StatefulWidget {
  final String url;
  final bool isMe;
  final int durationSecs;
  const _VoiceMessage(
      {required this.url, required this.isMe, this.durationSecs = 0});
  @override
  State<_VoiceMessage> createState() => _VoiceMessageState();
}

class _VoiceMessageState extends State<_VoiceMessage> {
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;
  Duration _dur = Duration.zero;
  Duration _pos = Duration.zero;
  final List<StreamSubscription> _subs = [];

  @override
  void initState() {
    super.initState();
    _subs.add(_player.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => _playing = s == PlayerState.playing);
    }));
    _subs.add(_player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _dur = d);
    }));
    _subs.add(_player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _pos = p);
    }));
    _subs.add(_player.onPlayerComplete.listen((_) {
      if (mounted)
        setState(() {
          _playing = false;
          _pos = Duration.zero;
        });
    }));
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_playing) {
      await _player.pause();
    } else {
      await _player.play(UrlSource(widget.url));
    }
  }

  String _fmt(Duration d) {
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '${d.inMinutes}:$s';
  }

  @override
  Widget build(BuildContext context) {
    final fg = widget.isMe ? Colors.white : AppColors.primary;
    final bg = widget.isMe ? AppColors.primary : Colors.white;
    // Prefer the player's reported duration; fall back to the stored recording
    // duration (recorded WebM often reports no duration in the browser).
    final totalMs = _dur.inMilliseconds > 0
        ? _dur.inMilliseconds
        : widget.durationSecs * 1000;
    final progress =
        totalMs > 0 ? (_pos.inMilliseconds / totalMs).clamp(0.0, 1.0) : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      width: 220,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: widget.isMe ? Colors.transparent : AppColors.border),
      ),
      child: Row(children: [
        GestureDetector(
          onTap: _toggle,
          child: Icon(
              _playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
              size: 34,
              color: fg),
        ),
        const SizedBox(width: 10),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: fg.withValues(alpha: 0.25),
                valueColor: AlwaysStoppedAnimation(fg),
              ),
            ),
            const SizedBox(height: 5),
            Row(children: [
              Icon(Icons.mic_rounded,
                  size: 13, color: fg.withValues(alpha: 0.8)),
              const SizedBox(width: 4),
              Text(
                  _pos > Duration.zero
                      ? _fmt(_pos)
                      : (totalMs > 0
                          ? _fmt(Duration(milliseconds: totalMs))
                          : 'Voice message'),
                  style: TextStyle(
                      fontSize: 11, color: fg.withValues(alpha: 0.9))),
            ]),
          ]),
        ),
      ]),
    );
  }
}
