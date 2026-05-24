
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../theme/app_text_styles.dart';

Future<void> showErrorDialog(
    BuildContext context,
    String message, {
      bool doublePop = false,
      VoidCallback? onPressed,
    }) async {

  if (context.mounted) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error, color: Colors.red, size: 32),
        content: Text(
          message,
          style: AppTextStyles.font16BlackBold,
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed:
            onPressed ??
                    () {
                  Navigator.of(context).pop();
                  if (doublePop) {
                    Navigator.of(context).pop();
                  }
                },
            child: Text(S.of(context).day, style: AppTextStyles.font16BlackBold),
          ),
        ],
      ),
    );
  }
}
