import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../theme.dart';
import '../models/companion.dart';
import '../models/memory.dart';
import '../services/db_service.dart';
import '../services/llm_service.dart';
import '../widgets/companion_avatar.dart';

class ChatScreen extends StatefulWidget {
  final Companion companion;
  const ChatScreen({super.key, required this.companion});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _generating = false;
  String _streamingText = '';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await DbService.instance.getRecentMessages(widget.companion.id, limit: 50);
    setState(() => _messages = history);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// The full message pipeline described in the spec:
  /// receive -> retrieve relevant memories -> inject into prompt ->
  /// generate -> store new memories if important.
  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _generating) return;
    _controller.clear();

    final userMsg = ChatMessage(
      id: const Uuid().v4(),
      companionId: widget.companion.id,
      isUser: true,
      content: text,
    );
    await DbService.instance.addMessage(userMsg);
    setState(() {
      _messages.add(userMsg);
      _generating = true;
      _streamingText = '';
    });
    _scrollToBottom();

    // 1. Retrieve relevant memories for this message.
    final relevant = await DbService.instance.getRelevantMemories(widget.companion.id, text);
    final memoryContext = relevant.map((m) => '- ${m.content}').join('\n');

    // 2. Build recent-turn history for short-term context.
    final recent = await DbService.instance.getRecentMessages(widget.companion.id, limit: 12);
    final history = recent
        .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.content})
        .toList();

    // 3. Generate the response, streaming tokens in.
    try {
      final buffer = StringBuffer();
      await for (final chunk in LlmService.instance.generateResponse(
        systemPrompt: widget.companion.buildSystemPrompt(),
        memoryContext: memoryContext,
        history: history,
        userMessage: text,
      )) {
        buffer.write(chunk);
        setState(() => _streamingText = buffer.toString());
        _scrollToBottom();
      }

      final replyText = buffer.toString().trim();
      final reply = ChatMessage(
        id: const Uuid().v4(),
        companionId: widget.companion.id,
        isUser: false,
        content: replyText.isEmpty ? '...' : replyText,
      );
      await DbService.instance.addMessage(reply);

      // 4. Extract & store new memories if the message looks important
      // (simple heuristic layer; swap in a classifier prompt for higher quality).
      await _maybeStoreMemory(text);

      setState(() {
        _messages.add(reply);
        _generating = false;
        _streamingText = '';
      });
    } catch (e) {
      setState(() {
        _generating = false;
        _streamingText = '';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The model isn\'t ready yet. Check Settings.')),
        );
      }
    }
    _scrollToBottom();
  }

  Future<void> _maybeStoreMemory(String userText) async {
    final lower = userText.toLowerCase();
    final triggers = {
      'birthday': 'birthday',
      'my favorite': 'preference',
      'i love': 'preference',
      'i hate': 'preference',
      'remember': 'note',
      'call me': 'nickname',
    };
    for (final entry in triggers.entries) {
      if (lower.contains(entry.key)) {
        await DbService.instance.addMemory(MemoryFact(
          id: const Uuid().v4(),
          companionId: widget.companion.id,
          category: entry.value,
          content: userText,
          importance: entry.key == 'birthday' ? 3 : 2,
        ));
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: Row(
            children: [
              CompanionAvatar(companion: widget.companion, size: 36),
              const SizedBox(width: 10),
              Text(widget.companion.name),
            ],
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _messages.length + (_generating ? 1 : 0),
            itemBuilder: (context, i) {
              if (i == _messages.length) {
                return _bubble(
                  _streamingText.isEmpty ? '···' : _streamingText,
                  isUser: false,
                );
              }
              final m = _messages[i];
              return _bubble(m.content, isUser: m.isUser);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: 'Message ${widget.companion.name}...',
                    filled: true,
                    fillColor: AppColors.card,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: AppColors.purple,
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  onPressed: _send,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bubble(String text, {required bool isUser}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          gradient: isUser ? AppTheme.accentGradient() : null,
          color: isUser ? null : AppColors.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
