
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/models/message_model.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {


    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            CircleAvatar(
              backgroundColor: AppColors.teal,
              child: Icon(Icons.smart_toy_outlined, color: AppColors.white),
            ),
          Container(
            padding: const EdgeInsets.all(12),
            margin: EdgeInsets.all(14),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: message.isUser
                  ? const BorderRadiusDirectional.only(
                      topStart: Radius.circular(16),
                      bottomEnd: Radius.circular(16),
                      bottomStart: Radius.circular(16),
                    )
                  : const BorderRadiusDirectional.only(
                      topEnd: Radius.circular(16),
                      bottomEnd: Radius.circular(16),
                      bottomStart: Radius.circular(16),
                    ),
            ),
            child: Text(
              message.isTyping ? "..." : message.text,
              style: message.isUser
                  ? AppTextStyles.font16WhiteRegular
                  : AppTextStyles.font16GreyRegular,
            ),
          ),
          if (message.isUser)
            if (message.isUser)
              CircleAvatar(
                backgroundColor: AppColors.teal,
                child: Icon(Icons.person_outline, color: AppColors.grey,),
              ),
        ],
      ),
    );
  }
}
