import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable number input dialog for editing profile values.
///
/// Returns the new value as a [double], or `null` if cancelled.
Future<double?> showEditValueDialog({
  required BuildContext context,
  required String title,
  required double currentValue,
  String unit = '',
  double? min,
  double? max,
  bool allowDecimals = true,
}) {
  return showDialog<double>(
    context: context,
    builder: (ctx) => _EditValueDialog(
      title: title,
      currentValue: currentValue,
      unit: unit,
      min: min,
      max: max,
      allowDecimals: allowDecimals,
    ),
  );
}

class _EditValueDialog extends StatefulWidget {
  const _EditValueDialog({
    required this.title,
    required this.currentValue,
    required this.unit,
    this.min,
    this.max,
    required this.allowDecimals,
  });

  final String title;
  final double currentValue;
  final String unit;
  final double? min;
  final double? max;
  final bool allowDecimals;

  @override
  State<_EditValueDialog> createState() => _EditValueDialogState();
}

class _EditValueDialogState extends State<_EditValueDialog> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    final display = widget.allowDecimals
        ? widget.currentValue.toString()
        : widget.currentValue.round().toString();
    _controller = TextEditingController(text: display);
    _controller.selection =
        TextSelection(baseOffset: 0, extentOffset: display.length);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = double.tryParse(_controller.text);
    if (value == null) {
      setState(() => _error = 'Enter a valid number');
      return;
    }
    if (widget.min != null && value < widget.min!) {
      setState(() => _error = 'Min: ${widget.min}');
      return;
    }
    if (widget.max != null && value > widget.max!) {
      setState(() => _error = 'Max: ${widget.max}');
      return;
    }
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.numberWithOptions(
              decimal: widget.allowDecimals,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                widget.allowDecimals ? RegExp(r'[\d.]') : RegExp(r'\d'),
              ),
            ],
            style: const TextStyle(color: Colors.white, fontSize: 24),
            decoration: InputDecoration(
              suffixText: widget.unit,
              suffixStyle:
                  const TextStyle(color: Colors.white38, fontSize: 16),
              errorText: _error,
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
