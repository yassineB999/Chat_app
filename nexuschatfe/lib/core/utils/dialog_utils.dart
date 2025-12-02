import 'package:flutter/material.dart';

class DialogUtils {
  DialogUtils._(); // Prevents instantiation

  static void showLoadingDialog(BuildContext context) {
    // Using a RouteAware widget can prevent trying to show a dialog
    // when the context is not visible, but for simplicity, we'll keep it direct.
    showDialog(
      context: context,
      barrierDismissible:
          false, // User cannot dismiss the dialog by tapping outside
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    // This will close the top-most route, which is our dialog.
    Navigator.of(context, rootNavigator: true).pop();
  }

  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
