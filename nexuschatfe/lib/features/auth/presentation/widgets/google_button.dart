import 'package:flutter/material.dart';

class GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool loading;
  const GoogleButton({
    super.key,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: loading ? null : onPressed,
        icon: Image.asset(
          'web/icons/Icon-192.png',
          height: 20,
          width: 20,
          errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata),
        ),
        label: Text(loading ? 'Connecting…' : 'Continue with Google'),
      ),
    );
  }
}
