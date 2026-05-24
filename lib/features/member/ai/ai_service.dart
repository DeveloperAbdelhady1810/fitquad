class AiService {
  Future<String> reply(String message) async {
    await Future.delayed(const Duration(seconds: 2));

    if (message.toLowerCase().contains('recommend')) {
      return '📚 I recommend *Atomic Habits*. It\'s simple and inspiring.';
    }

    if (message.toLowerCase().contains('stats')) {
      return '📊 You have read 12 books so far. Keep going!';
    }

    return '🤖 I\'m your AI reading assistant!';
  }
}
