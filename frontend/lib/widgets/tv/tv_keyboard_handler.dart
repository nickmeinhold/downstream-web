import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A widget that wraps the app and provides global keyboard event handling
/// for TV remote control navigation.
class TvKeyboardHandler extends StatelessWidget {
  final Widget child;
  final VoidCallback? onBack;

  const TvKeyboardHandler({
    super.key,
    required this.child,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) => _handleKeyEvent(context, event),
      child: child,
    );
  }

  KeyEventResult _handleKeyEvent(BuildContext context, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    // Handle back/escape to pop navigation
    if (event.logicalKey == LogicalKeyboardKey.escape ||
        event.logicalKey == LogicalKeyboardKey.goBack ||
        event.logicalKey == LogicalKeyboardKey.browserBack) {
      if (onBack != null) {
        onBack!();
        return KeyEventResult.handled;
      }

      // Try to pop the current route
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        return KeyEventResult.handled;
      }
    }

    // Let other keys propagate for focus traversal
    return KeyEventResult.ignored;
  }
}

/// Extension to add TV-friendly focus traversal configuration
class TvFocusTraversalGroup extends StatelessWidget {
  final Widget child;

  const TvFocusTraversalGroup({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: ReadingOrderTraversalPolicy(),
      child: child,
    );
  }
}

/// A horizontal focus traversal group for rows of content
class HorizontalTvFocusGroup extends StatelessWidget {
  final Widget child;

  const HorizontalTvFocusGroup({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: child,
    );
  }
}
