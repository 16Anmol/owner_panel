import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'call_screen.dart';
import '../services/socket_service.dart';

// ══════════════════════════════════════════════════════════════
//  Owner Chat List
// ══════════════════════════════════════════════════════════════
class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});
  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  List<dynamic> _chats   = [];
  bool          _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.getOwnerChats();
      if (mounted) setState(() { _chats = res['chats'] as List? ?? []; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: const BackButton(color: AppColors.textDark),
        title: const Text('Messages',
            style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textDark)),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
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
                      final c    = _chats[i] as Map<String, dynamic>;
                      final cust = c['customer'] as Map<String, dynamic>? ?? {};
                      final prop = c['property'] as Map<String, dynamic>? ?? {};
                      final unread  = c['unreadByOwner']  as int?    ?? 0;
                      final lastMsg = c['lastMessage']    as String? ?? 'Start a conversation';
                      final lastTs  = c['lastMessageAt']  as String?;

                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(
                            builder: (_) => OwnerChatScreen(
                              chatId:       c['_id']   as String,
                              customerName: cust['name'] as String? ?? 'Customer',
                              customerId:   cust['_id']  as String? ?? '',
                              plotName:     prop['propertyName'] as String? ?? 'Plot',
                            ),
                          ));
                          _load();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color:  unread > 0 ? AppColors.primaryLight : Colors.white,
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
                                width: 48, height: 48,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryLight, shape: BoxShape.circle),
                                child: Center(child: Text(
                                  (cust['name'] as String? ?? 'C')[0].toUpperCase(),
                                  style: const TextStyle(fontSize: 20,
                                      fontWeight: FontWeight.w800, color: AppColors.primary),
                                )),
                              ),
                              if (unread > 0)
                                Positioned(top: -2, right: -2,
                                  child: Container(
                                    width: 18, height: 18,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary, shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 1.5)),
                                    child: Center(child: Text('$unread',
                                        style: const TextStyle(color: Colors.white,
                                            fontSize: 10, fontWeight: FontWeight.w800))),
                                  )),
                            ]),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                Expanded(child: Text(cust['name'] ?? 'Customer',
                                    style: TextStyle(fontSize: 14,
                                        fontWeight: unread > 0 ? FontWeight.w800 : FontWeight.w600,
                                        color: AppColors.textDark))),
                                Text(_fmtTime(lastTs), style: TextStyle(fontSize: 11,
                                    color: unread > 0 ? AppColors.primary : AppColors.textLight,
                                    fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w400)),
                              ]),
                              const SizedBox(height: 2),
                              Text('Re: ${prop['propertyName'] ?? 'Plot'}',
                                  style: const TextStyle(fontSize: 12,
                                      color: AppColors.primary, fontWeight: FontWeight.w600),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 3),
                              Text(lastMsg, style: TextStyle(fontSize: 12,
                                  color: unread > 0 ? AppColors.textDark : AppColors.textMuted,
                                  fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.w400),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                            ])),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
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
      final dt   = DateTime.parse(raw).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inSeconds < 60)  return 'now';
      if (diff.inMinutes < 60)  return '${diff.inMinutes}m';
      if (diff.inHours < 24)    return '${diff.inHours}h';
      return '${dt.day}/${dt.month}';
    } catch (_) { return ''; }
  }
}

class _EmptyChats extends StatelessWidget {
  const _EmptyChats();
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.chat_bubble_outline_rounded, size: 60, color: AppColors.textLight),
      SizedBox(height: 14),
      Text('No messages yet',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark)),
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
  final String chatId, customerName, plotName, customerId;
  const OwnerChatScreen({
    super.key,
    required this.chatId,
    required this.customerName,
    required this.customerId,
    required this.plotName,
  });
  @override
  State<OwnerChatScreen> createState() => _OwnerChatScreenState();
}

class _OwnerChatScreenState extends State<OwnerChatScreen> {
  final _ctrl      = TextEditingController();
  final _scroll    = ScrollController();
  final List<Map<String, dynamic>> _msgs = [];

  bool    _loading   = false;
  bool    _sending      = false;
  bool    _uploading    = false;
  // ── Audio recording ──────────────────────────────────────────
  bool    _recording    = false;
  bool    _sendingAudio = false;
  html.MediaRecorder? _mediaRecorder;
  final List<dynamic> _audioChunks = [];
  Timer?  _recordTimer;
  int     _recordSeconds = 0;
  String? _blocked;
  String? _lastTs;
  Timer?  _timer;

  @override
  Future<void> _startCall() async {
    try {
      final owner = await ApiService.getSavedOwner();
      if (owner == null) return;
      final myId = owner['_id'] as String? ?? '';
      SocketService().register(myId, 'owner');
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => CallScreen(
        myId:       myId,
        myType:     'owner',
        myName:     owner['name'] as String? ?? '',
        peerId:     widget.customerId,
        peerType:   'customer',
        peerName:   widget.customerName,
        isOutgoing: true,
      )));
    } catch (e) { debugPrint('Call error: $e'); }
  }

  void initState() {
    super.initState();
    _ctrl.addListener(_checkPhone);
    _loadMessages();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _poll());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.removeListener(_checkPhone);
    _ctrl.dispose();
    _recordTimer?.cancel();
    _scroll.dispose();
    super.dispose();
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
      setState(() => _blocked = blocked
          ? '🚫 Phone numbers are not allowed in chat.'
          : null);
    }
  }

  // ── Load messages ─────────────────────────────────────────────
  Future<void> _loadMessages() async {
    setState(() => _loading = true);
    try {
      final res  = await ApiService.getOwnerChatMessages(widget.chatId);
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
          DateTime.now().subtract(const Duration(seconds: 10)).toIso8601String();
      final res   = await ApiService.ownerPollMessages(widget.chatId, since);
      final list  = res['messages'] as List? ?? [];
      if (list.isNotEmpty && mounted) {
        setState(() {
          for (final m in list.cast<Map<String, dynamic>>()) {
            final idx = _msgs.indexWhere((e) => e['_id'] == m['_id']);
            if (idx >= 0) { _msgs[idx] = m; } else { _msgs.add(m); }
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
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  });

  // ── Pick & upload photo ───────────────────────────────────────
  Future<void> _pickPhoto() async {
    List<int> bytes = [];
    String    name  = 'photo.jpg';
    try {
      if (kIsWeb) {
        final input = html.FileUploadInputElement()
          ..accept = 'image/jpeg,image/jpg,image/png,image/webp,image/gif'
          ..multiple = false;
        input.click();
        await input.onChange.first;
        if (input.files == null || input.files!.isEmpty) return;
        final file   = input.files!.first;
        final rawName = file.name;
        final ext = rawName.contains('.')
            ? rawName.substring(rawName.lastIndexOf('.')).toLowerCase()
            : '.jpg';
        final safeExt = ['.jpg','.jpeg','.png','.webp','.gif'].contains(ext) ? ext : '.jpg';
        name = 'photo_${DateTime.now().millisecondsSinceEpoch}$safeExt';
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        await reader.onLoad.first;
        bytes = (reader.result as List<dynamic>).cast<int>();
      } else {
        return; // image_picker not needed for owner panel (web only)
      }
    } catch (_) { return; }

    setState(() => _uploading = true);
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
  // ── Audio recording methods ─────────────────────────────────
  Future<void> _startRecording() async {
    if (!kIsWeb) return;
    if (_recording) { await _stopRecording(); return; }
    try {
      final stream = await html.window.navigator.mediaDevices?.getUserMedia({'audio': true});
      if (stream == null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not access microphone')));
        return;
      }
      _audioChunks.clear();
      final mimeType = html.MediaRecorder.isTypeSupported('audio/webm;codecs=opus')
          ? 'audio/webm;codecs=opus'
          : html.MediaRecorder.isTypeSupported('audio/webm') ? 'audio/webm' : '';
      _mediaRecorder = mimeType.isNotEmpty
          ? html.MediaRecorder(stream, {'mimeType': mimeType})
          : html.MediaRecorder(stream);
      _mediaRecorder!.addEventListener('dataavailable', (e) {
        final blob = (e as html.BlobEvent).data;
        if (blob != null && blob.size > 0) _audioChunks.add(blob);
      });
      _mediaRecorder!.start(250);
      _recordSeconds = 0;
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _recordSeconds++);
      });
      setState(() => _recording = true);
    } catch (e) {
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone access denied. Allow mic in browser settings.'))); }
    }
  }

  Future<void> _stopRecording() async {
    if (_mediaRecorder == null) return;
    _recordTimer?.cancel();
    _mediaRecorder!.requestData();
    final completer = Completer<void>();
    _mediaRecorder!.addEventListener('stop', (_) => completer.complete());
    _mediaRecorder!.stop();
    await completer.future;
    _mediaRecorder!.stream?.getTracks().forEach((t) => t.stop());
    setState(() { _recording = false; _sendingAudio = true; });
    try {
      if (_audioChunks.isEmpty) {
        if (mounted) { ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No audio recorded'))); }
        return;
      }
      final blob = html.Blob(List<dynamic>.from(_audioChunks), 'audio/webm');
      final reader = html.FileReader();
      reader.readAsArrayBuffer(blob);
      await reader.onLoad.first;
      // Flutter web returns NativeUint8List or ByteBuffer depending on version
      final result = reader.result;
      final List<int> bytes;
      if (result is ByteBuffer) {
        bytes = result.asUint8List();
      } else {
        bytes = (result as dynamic).buffer.asUint8List() as List<int>;
      }
      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.webm';
      await ApiService.uploadOwnerChatAudio(chatId: widget.chatId, bytes: bytes, fileName: fileName);
      _audioChunks.clear();
      _mediaRecorder = null;
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send audio: $e')));
    } finally {
      if (mounted) setState(() => _sendingAudio = false);
    }
  }

  void _cancelRecording() {
    _recordTimer?.cancel();
    _mediaRecorder?.stream?.getTracks().forEach((t) => t.stop());
    _mediaRecorder?.stop();
    _audioChunks.clear();
    _mediaRecorder = null;
    setState(() { _recording = false; _recordSeconds = 0; });
  }

  String _fmtRec(int s) =>
      '${(s ~/ 60).toString().padLeft(2,"0")}:${(s % 60).toString().padLeft(2,"0")}';

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _blocked != null) return;
    setState(() => _sending = true);
    try {
      final res = await ApiService.ownerSendMessage(
          chatId: widget.chatId, text: text);
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(err), backgroundColor: AppColors.error));
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
                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: const BackButton(color: AppColors.textDark),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.customerName,
              style: const TextStyle(fontSize: 15,
                  fontWeight: FontWeight.w800, color: AppColors.textDark)),
          Text('Re: ${widget.plotName}',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.shield_outlined, size: 12, color: AppColors.primary),
              SizedBox(width: 4),
              Text('Safe Chat',
                  style: TextStyle(fontSize: 11,
                      fontWeight: FontWeight.w700, color: AppColors.primary)),
            ]),
          ),
        ],
      ),
      body: Column(children: [
        // Info banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          color: AppColors.primaryLight,
          child: const Row(children: [
            Icon(Icons.info_outline_rounded, size: 14, color: AppColors.primary),
            SizedBox(width: 8),
            Expanded(child: Text(
              'Phone numbers are blocked. Share text, images and links safely.',
              style: TextStyle(fontSize: 11, color: AppColors.primary, height: 1.3),
            )),
          ]),
        ),

        // Messages
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _msgs.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.chat_bubble_outline_rounded,
                          size: 50, color: AppColors.textLight),
                      const SizedBox(height: 12),
                      Text('Reply to ${widget.customerName}',
                          style: const TextStyle(fontWeight: FontWeight.w700,
                              color: AppColors.textDark)),
                      const SizedBox(height: 4),
                      const Text('Type a message below',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    ]))
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      itemCount: _msgs.length,
                      itemBuilder: (_, i) {
                        final m       = _msgs[i];
                        final isMe    = (m['senderType'] as String?) == 'owner';
                        final isDelFm = m['deletedForSender'] as bool? ?? false;
                        if (isDelFm) return const SizedBox.shrink();
                        final isDel   = m['deletedForEveryone'] as bool? ?? false;
                        final bubble = _OwnerBubble(msg: m, isMe: isMe);
                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          // Only show delete icon on OWN messages
                          child: isMe
                              ? _HoverMsgWrapper(
                                  isMe:      isMe,
                                  isDeleted: isDel,
                                  onDelete:  () => _deleteMsg(m['_id'] as String),
                                  child: bubble,
                                )
                              : bubble,
                        );
                      },
                    ),
        ),

        // Upload progress
        if (_uploading)
          Container(
            color: AppColors.primaryLight,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Row(children: [
              SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(
                      color: AppColors.primary, strokeWidth: 2)),
              SizedBox(width: 10),
              Text('Uploading photo…',
                  style: TextStyle(fontSize: 13, color: AppColors.primary,
                      fontWeight: FontWeight.w600)),
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
              border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.35)),
            ),
            child: Row(children: [
              const Icon(Icons.block_rounded, color: AppColors.error, size: 15),
              const SizedBox(width: 8),
              Expanded(child: Text(_blocked!,
                  style: const TextStyle(color: AppColors.error, fontSize: 12))),
            ]),
          ),

        // Recording indicator
        if (_recording)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              Container(width: 8, height: 8,
                  decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text('Recording… ${_fmtRec(_recordSeconds)}',
                  style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600)),
              const Spacer(),
              GestureDetector(
                onTap: _cancelRecording,
                child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ),
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
                width: 40, height: 40,
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

            // Text field
            Expanded(
              child: TextField(
                controller: _ctrl,
                minLines: 1, maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Reply…',
                  hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  filled: true, fillColor: AppColors.background,
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
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _ctrl,
              builder: (_, val, __) {
                final hasText = val.text.trim().isNotEmpty;
                if (hasText) {
                  return GestureDetector(
                    onTap: (_sending || _blocked != null) ? null : _send,
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: (_blocked != null || _sending) ? AppColors.textLight : AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: (_blocked != null) ? []
                            : [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: _sending
                          ? const Center(child: SizedBox(width: 18, height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                          : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  );
                }
                return GestureDetector(
                  onTap: _recording ? _stopRecording : _startRecording,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: _recording ? AppColors.error : AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(
                          color: (_recording ? AppColors.error : AppColors.primary).withValues(alpha: 0.35),
                          blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: _sendingAudio
                        ? const Center(child: SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                        : Icon(_recording ? Icons.stop_circle_rounded : Icons.mic_rounded,
                            color: Colors.white, size: 22),
                  ),
                );
              },
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
  final VoidCallback onDelete;
  final bool isMe;
  final bool isDeleted;
  const _HoverMsgWrapper({
    required this.child,
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
  late Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 160));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  void _show() { _anim.forward(); }
  void _hide() {
    _anim.reverse().then((_) {
      if (mounted) setState(() { _hovered = false; _showMob = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDeleted) return widget.child;
    final show = _hovered || _showMob;

    final trashBtn = show
        ? FadeTransition(
            opacity: _fade,
            child: GestureDetector(
              onTap: () { _hide(); widget.onDelete(); },
              child: Container(
                width: 30, height: 30,
                margin: EdgeInsets.only(
                  left:  widget.isMe ? 6 : 0,
                  right: widget.isMe ? 0 : 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 6, offset: const Offset(0, 2),
                  )],
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    size: 16, color: Color(0xFFC62828)),
              ),
            ),
          )
        : null;

    return MouseRegion(
      onEnter: (_) { setState(() => _hovered = true); _show(); },
      onExit:  (_) => _hide(),
      child: GestureDetector(
        onLongPress: () { setState(() => _showMob = true); _show(); },
        onTap:       () { if (_showMob) _hide(); },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!widget.isMe && trashBtn != null) trashBtn,
            Flexible(child: widget.child),
            if (widget.isMe  && trashBtn != null) trashBtn,
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
    final text      = msg['text']              as String? ?? '';
    final imageUrl  = msg['imageUrl']          as String?;
    final linkUrl   = msg['linkUrl']           as String?;
    final audioUrl  = msg['audioUrl']          as String?;
    final isDeleted = msg['deletedForEveryone'] as bool? ?? false;
    final isEdited  = msg['isEdited']          as bool? ?? false;
    final ts        = _fmt(msg['createdAt']    as String?);

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
              style: TextStyle(fontSize: 13,
                  color: AppColors.textLight, fontStyle: FontStyle.italic)),
        ]),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.68),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (imageUrl != null && imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl.startsWith('http')
                    ? imageUrl
                    : 'http://localhost:5000$imageUrl',
                width: 200, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image_outlined, color: AppColors.textLight),
              ),
            ),
          // Audio bubble
          if (audioUrl != null && audioUrl.isNotEmpty) ...[
            _OwnerAudioBubble(
              url: audioUrl.startsWith('http') ? audioUrl : 'http://localhost:5000$audioUrl',
              isMe: isMe,
            ),
          ] else if (linkUrl != null && linkUrl.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: isMe ? Colors.transparent : AppColors.border),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.link_rounded, size: 16,
                    color: isMe ? Colors.white70 : AppColors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(linkUrl,
                    style: TextStyle(fontSize: 13,
                        color: isMe ? Colors.white : AppColors.primary,
                        decoration: TextDecoration.underline),
                    maxLines: 2, overflow: TextOverflow.ellipsis)),
              ]),
            ),
          if (text.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft:     const Radius.circular(18),
                  topRight:    const Radius.circular(18),
                  bottomLeft:  Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                border: isMe ? null : Border.all(color: AppColors.border),
              ),
              child: Text(text,
                  style: TextStyle(fontSize: 14, height: 1.4,
                      color: isMe ? Colors.white : AppColors.textDark)),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (isEdited)
                const Text('edited · ',
                    style: TextStyle(fontSize: 10,
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
      final h  = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m  = dt.minute.toString().padLeft(2, '0');
      return '$h:$m ${dt.hour >= 12 ? 'PM' : 'AM'}';
    } catch (_) { return ''; }
  }
}

// ══════════════════════════════════════════════════════════════
//  Owner Audio Bubble
// ══════════════════════════════════════════════════════════════
class _OwnerAudioBubble extends StatefulWidget {
  final String url;
  final bool   isMe;
  const _OwnerAudioBubble({required this.url, required this.isMe});
  @override
  State<_OwnerAudioBubble> createState() => _OwnerAudioBubbleState();
}

class _OwnerAudioBubbleState extends State<_OwnerAudioBubble> {
  html.AudioElement? _audio;
  bool   _playing  = false;
  double _progress = 0.0;
  double _duration = 0.0;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _audio = html.AudioElement()
      ..src = widget.url
      ..preload = 'metadata';
    // Append to DOM — required for browser audio pipeline in Flutter web
    html.document.body!.append(_audio!);
    _audio!.onLoadedMetadata.listen((_) {
      if (mounted) setState(() => _duration = (_audio!.duration as num).toDouble());
    });
    _audio!.onEnded.listen((_) {
      _ticker?.cancel();
      if (mounted) setState(() { _playing = false; _progress = 0.0; });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _audio?.pause();
    _audio?.remove();
    _audio = null;
    super.dispose();
  }

  void _toggle() {
    if (_audio == null) return;
    if (_playing) {
      _audio!.pause();
      _ticker?.cancel();
      setState(() => _playing = false);
    } else {
      _audio!.play();
      // Poll every 80ms — most reliable approach for Flutter web
      _ticker = Timer.periodic(const Duration(milliseconds: 80), (_) {
        if (!mounted) { _ticker?.cancel(); return; }
        if (_duration > 0) {
          final t = _audio!.currentTime.toDouble();
          if (t != (_progress * _duration)) {
            setState(() => _progress = (t / _duration).clamp(0.0, 1.0));
          }
        }
      });
      setState(() => _playing = true);
    }
  }

  String _fmt(double s) {
    if (!s.isFinite || s <= 0) return '0:00';
    final t = s.toInt();
    return '${(t ~/ 60)}:${(t % 60).toString().padLeft(2, "0")}';
  }

  @override
  Widget build(BuildContext context) {
    final bg    = widget.isMe ? AppColors.primary : Colors.white;
    final muted = widget.isMe
        ? Colors.white.withValues(alpha: 0.6)
        : AppColors.textMuted;

    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: widget.isMe ? null : Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        GestureDetector(
          onTap: _toggle,
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: widget.isMe
                  ? Colors.white.withValues(alpha: 0.25)
                  : AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: widget.isMe ? Colors.white : AppColors.primary, size: 22),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
              activeTrackColor:   widget.isMe ? Colors.white : AppColors.primary,
              inactiveTrackColor: muted,
              thumbColor:         widget.isMe ? Colors.white : AppColors.primary,
              overlayColor: (widget.isMe ? Colors.white : AppColors.primary).withValues(alpha: 0.2),
            ),
            child: Slider(
              value: _progress.clamp(0.0, 1.0),
              onChanged: (v) {
                if (_audio == null || _duration <= 0) return;
                _audio!.currentTime = v * _duration;
                setState(() => _progress = v);
              },
            ),
          ),
          Row(children: [
            Icon(Icons.mic_rounded, size: 11, color: muted),
            const SizedBox(width: 3),
            Text(
              _playing
                  ? _fmt(_audio!.currentTime.toDouble())
                  : _fmt(_duration),
              style: TextStyle(fontSize: 10, color: muted),
            ),
          ]),
        ])),
      ]),
    );
  }
}

