class ChatMessage {
  final String text;
  final bool isUser;
  final bool isTyping;
  final bool inBodyAttached;

  const ChatMessage({
    required this.text,
    required this.isUser,
    this.isTyping = false,
    this.inBodyAttached = false,
  });
}
