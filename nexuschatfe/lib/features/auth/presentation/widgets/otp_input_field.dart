import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInputField extends StatefulWidget {
  final Function(String) onCompleted;
  final Function(String)? onChanged;
  final int length;

  const OtpInputField({
    Key? key,
    required this.onCompleted,
    this.onChanged,
    this.length = 6,
  }) : super(key: key);

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1) {
      // Move to next field
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last field, trigger completion
        _focusNodes[index].unfocus();
        _checkCompletion();
      }
    } else if (value.isEmpty) {
      // Move to previous field on backspace
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    } else if (value.length > 1) {
      // Handle paste operation
      _handlePaste(value, index);
    }

    _checkCompletion();
  }

  void _handlePaste(String value, int startIndex) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    for (
      int i = 0;
      i < digits.length && (startIndex + i) < widget.length;
      i++
    ) {
      _controllers[startIndex + i].text = digits[i];
    }

    // Focus the last filled field or the next empty one
    final lastFilledIndex = (startIndex + digits.length - 1).clamp(
      0,
      widget.length - 1,
    );
    if (lastFilledIndex < widget.length - 1) {
      _focusNodes[lastFilledIndex + 1].requestFocus();
    } else {
      _focusNodes[lastFilledIndex].unfocus();
    }
  }

  void _checkCompletion() {
    final otp = _controllers.map((c) => c.text).join();

    if (widget.onChanged != null) {
      widget.onChanged!(otp);
    }

    if (otp.length == widget.length) {
      widget.onCompleted(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        widget.length,
        (index) => _buildOtpBox(index, theme),
      ),
    );
  }

  Widget _buildOtpBox(int index, ThemeData theme) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: TextFormField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: _controllers[index].text.isEmpty
                ? theme.colorScheme.surface
                : theme.colorScheme.primary.withOpacity(0.1),
          ),
          onChanged: (value) => _onChanged(value, index),
          onTap: () {
            // Clear the field on tap for easier editing
            if (_controllers[index].text.isNotEmpty) {
              _controllers[index].selection = TextSelection(
                baseOffset: 0,
                extentOffset: _controllers[index].text.length,
              );
            }
          },
        ),
      ),
    );
  }
}
