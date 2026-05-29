import 'package:flutter/material.dart';
import 'package:gym_app/core/widgets/app_avatar.dart';
import '../../../chat/data/chat_model.dart';

class MessageTile extends StatelessWidget {
  final CoachChatMessage item;
  final VoidCallback? onTap;

  const MessageTile({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            AppAvatar(
              name:   item.name,
              url:    item.avatarUrl,
              radius: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(item.message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(item.time,
                style: const TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
