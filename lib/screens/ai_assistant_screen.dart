import 'package:flutter/material.dart';

import '../models/user_profile_model.dart';
import '../services/ai_chat_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_bubble.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text:
          "Hi, I am your Sri Lanka AI travel assistant. Ask me for real plans, budgets, routes, beaches, cultural stops, or food ideas and I will answer from the app's local guide first.",
      isUser: false,
    ),
  ];
  bool _isLoading = false;

  final List<String> _suggestions = const [
    "Best places to visit",
    "3 day Sri Lanka itinerary",
    "What to do in Ella?",
    "Best sunset places near me",
    "Kandy plan for 3 people",
    "How the map works",
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _controller.text).trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isLoading = true;
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final currentUser = await AuthService.instance.currentUser();
      if (currentUser != null) {
        await AuthService.instance.updateBehaviorCounter(
          currentUser.id,
          'assistant_messages',
        );
      }

      final requestMessages = _buildRequestMessages(currentUser);
      final response = await AiChatService.send(requestMessages);

      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            text: _formatAnswer(response),
            isUser: false,
          ),
        );
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          const _ChatMessage(
            text:
                "I could not reach the live server, so I stayed in local guide mode. Try a destination, a budget, a group size, or a route and I will still help from the app data.",
            isUser: false,
          ),
        );
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  List<AiChatMessage> _buildRequestMessages(AppUser? user) {
    final messages = _messages
        .map(
          (message) => AiChatMessage(
            role: message.isUser ? 'user' : 'assistant',
            content: message.text,
          ),
        )
        .toList();

    if (user == null) {
      return messages;
    }

    messages.insert(
      0,
      AiChatMessage(
        role: 'assistant',
        content:
            'Traveler profile: interests ${TravelerPreferences.labelForInterests(user.preferences.allInterests)}, budget ${TravelerPreferences.labelForBudget(user.preferences.budget)}, style ${TravelerPreferences.labelForStyle(user.preferences.style)}, food ${TravelerPreferences.labelForFood(user.preferences.food)}, mood ${TravelerPreferences.labelForMood(user.preferences.mood)}.',
      ),
    );

    return messages;
  }

  String _formatAnswer(AiChatResponse response) {
    if (response.sources.isEmpty) return response.answer;

    final sourceLines = response.sources
        .where((source) => source.url.isNotEmpty)
        .map((source) => '- ${source.title}: ${source.url}')
        .join('\n');
    return '${response.answer}\n\nSources:\n$sourceLines';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Travel Assistant'),
        backgroundColor: AppColors.midnight,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Clear chat',
            onPressed: _isLoading
                ? null
                : () {
                    setState(() {
                      _messages
                        ..clear()
                        ..add(
                          const _ChatMessage(
                            text:
                                "Hi, I am your Sri Lanka AI travel assistant. Ask me for real plans, budgets, routes, beaches, cultural stops, or food ideas and I will answer from the app's local guide first.",
                            isUser: false,
                          ),
                        );
                    });
                  },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF151D30),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.gold.withAlpha(22)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.travel_explore, color: AppColors.gold),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ask about Sri Lanka places, routes, beaches, culture, seasons, budgets, group travel, or quick itineraries. The assistant now handles destination-specific questions much better.',
                      style: TextStyle(height: 1.35, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return ChatBubble(text: message.text, isUser: message.isUser);
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
                child: LinearProgressIndicator(minHeight: 3),
              ),
            Container(
              padding: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.midnight.withAlpha(235),
                border: Border(
                  top: BorderSide(color: Colors.white.withAlpha(10)),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                      scrollDirection: Axis.horizontal,
                      itemCount: _suggestions.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final suggestion = _suggestions[index];
                        return ActionChip(
                          label: Text(suggestion),
                          onPressed: () => _send(suggestion),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      12,
                      8,
                      12,
                      MediaQuery.of(context).padding.bottom + 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            style: const TextStyle(color: Colors.white),
                            textInputAction: TextInputAction.send,
                            minLines: 1,
                            maxLines: 4,
                            onSubmitted: (_) => _send(),
                            decoration: InputDecoration(
                              hintText: 'Ask your travel question...',
                              hintStyle: const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Colors.white.withAlpha(10),
                              prefixIcon: const Icon(
                                Icons.chat_bubble_outline,
                                color: AppColors.gold,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Material(
                          color: _isLoading ? Colors.grey : AppColors.gold,
                          shape: const CircleBorder(),
                          child: IconButton(
                            tooltip: 'Send',
                            onPressed: _isLoading ? null : () => _send(),
                            icon: const Icon(
                              Icons.send,
                              color: AppColors.midnight,
                            ),
                          ),
                        ),
                      ],
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

class _ChatMessage {
  final String text;
  final bool isUser;

  const _ChatMessage({
    required this.text,
    required this.isUser,
  });
}
