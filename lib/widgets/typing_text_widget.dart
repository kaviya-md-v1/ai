// lib/widgets/typing_text_widget.dart
// Renders AI response text with a character-by-character typewriter effect,
// mimicking a real terminal printout.

import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TypingTextWidget extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final VoidCallback? onComplete;
  final int charDelayMs; // milliseconds per character

  const TypingTextWidget({
    super.key,
    required this.text,
    this.style,
    this.onComplete,
    this.charDelayMs = 18,
  });

  @override
  State<TypingTextWidget> createState() => _TypingTextWidgetState();
}

class _TypingTextWidgetState extends State<TypingTextWidget> {
  String _displayed = '';
  int _index = 0;
  Timer? _timer;
  bool _showCursor = true;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    _startTyping();
    _startCursorBlink();
  }

  @override
  void didUpdateWidget(TypingTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _timer?.cancel();
      _displayed = '';
      _index = 0;
      _startTyping();
    }
  }

  void _startTyping() {
    _timer = Timer.periodic(Duration(milliseconds: widget.charDelayMs), (t) {
      if (_index < widget.text.length) {
        setState(() {
          _displayed += widget.text[_index];
          _index++;
        });
      } else {
        t.cancel();
        widget.onComplete?.call();
      }
    });
  }

  void _startCursorBlink() {
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 530), (_) {
      if (mounted) setState(() => _showCursor = !_showCursor);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isTypingDone = _index >= widget.text.length;
    return RichText(
      text: TextSpan(
        style: widget.style ?? AppTheme.terminalMedium,
        children: [
          TextSpan(text: _displayed),
          // Show blinking cursor while typing or just after completion
          if (!isTypingDone || _showCursor)
            TextSpan(
              text: '█',
              style: (widget.style ?? AppTheme.terminalMedium).copyWith(
                color: isTypingDone
                    ? AppTheme.neonGreen.withOpacity(0.6)
                    : AppTheme.neonGreen,
              ),
            ),
        ],
      ),
    );
  }
}
