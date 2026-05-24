import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const MessageInput({required this.controller, required this.onSend, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              cursorColor: AppColors.emerald,
              controller: controller,
              decoration:  InputDecoration(
                hintText: "Type a message",
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.emerald),
                  borderRadius: BorderRadius.all(Radius.circular(20),
                  )
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))
                ),
              ),
            ),
          ),
          IconButton(
            icon:  Icon(Icons.send , color: AppColors.teal,),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}
