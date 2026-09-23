import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/robot_command.dart';

class KeyboardShortcutsListener extends StatefulWidget {
  const KeyboardShortcutsListener({
    super.key,
    required this.child,
    required this.onCommand,
    required this.onStop,
  });

  final Widget child;
  final ValueChanged<RobotCommand> onCommand;
  final VoidCallback onStop;

  @override
  State<KeyboardShortcutsListener> createState() =>
      _KeyboardShortcutsListenerState();
}

class _KeyboardShortcutsListenerState extends State<KeyboardShortcutsListener> {
  final FocusNode _focusNode = FocusNode();
  final Set<LogicalKeyboardKey> _pressedKeys = {};

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      _pressedKeys.add(event.logicalKey);
      _evaluateCommands();
      return KeyEventResult.handled;
    } else if (event is KeyUpEvent) {
      _pressedKeys.remove(event.logicalKey);
      _evaluateCommands();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _evaluateCommands() {
    if (_pressedKeys.contains(LogicalKeyboardKey.space)) {
      widget.onStop();
      return;
    }

    if (_pressedKeys.contains(LogicalKeyboardKey.keyW) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowUp)) {
      widget.onCommand(RobotCommand.forward);
    } else if (_pressedKeys.contains(LogicalKeyboardKey.keyS) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowDown)) {
      widget.onCommand(RobotCommand.backward);
    } else if (_pressedKeys.contains(LogicalKeyboardKey.keyA) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowLeft)) {
      widget.onCommand(RobotCommand.left);
    } else if (_pressedKeys.contains(LogicalKeyboardKey.keyD) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowRight)) {
      widget.onCommand(RobotCommand.right);
    } else if (_pressedKeys.contains(LogicalKeyboardKey.keyQ)) {
      widget.onCommand(RobotCommand.rotateLeft);
    } else if (_pressedKeys.contains(LogicalKeyboardKey.keyE)) {
      widget.onCommand(RobotCommand.rotateRight);
    } else {
      widget.onStop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: widget.child,
    );
  }
}
