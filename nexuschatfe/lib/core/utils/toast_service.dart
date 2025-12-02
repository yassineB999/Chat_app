import 'package:flutter/material.dart';

class ToastService {
  /// Shows a Red Error Toast
  static void showError(BuildContext context, String message) {
    _showToast(
      context,
      message,
      icon: Icons.error_outline_rounded,
      backgroundColor: Colors.red.shade700,
      textColor: Colors.white,
    );
  }

  /// Shows a Green Success Toast
  static void showSuccess(BuildContext context, String message) {
    _showToast(
      context,
      message,
      icon: Icons.check_circle_outline_rounded,
      backgroundColor: Colors.green.shade700,
      textColor: Colors.white,
    );
  }

  /// Shows an Orange Warning Toast
  static void showWarning(BuildContext context, String message) {
    _showToast(
      context,
      message,
      icon: Icons.warning_amber_rounded,
      backgroundColor: Colors.orange.shade800,
      textColor: Colors.white,
    );
  }

  static void _showToast(
    BuildContext context,
    String message, {
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
  }) {
    // remove any current snackbars to avoid stacking
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: textColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: textColor.withOpacity(0.9),
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
