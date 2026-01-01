import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A widget that wraps the app and provides global keyboard event handling
/// for TV remote control navigation.
class TvKeyboardHandler extends StatefulWidget {
  final Widget child;
  final VoidCallback? onBack;

  const TvKeyboardHandler({
    super.key,
    required this.child,
    this.onBack,
  });

  @override
  State<TvKeyboardHandler> createState() => _TvKeyboardHandlerState();
}

class _TvKeyboardHandlerState extends State<TvKeyboardHandler> {
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        // Arrow keys for directional focus
        const SingleActivator(LogicalKeyboardKey.arrowUp): const DirectionalFocusIntent(TraversalDirection.up),
        const SingleActivator(LogicalKeyboardKey.arrowDown): const DirectionalFocusIntent(TraversalDirection.down),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): const DirectionalFocusIntent(TraversalDirection.left),
        const SingleActivator(LogicalKeyboardKey.arrowRight): const DirectionalFocusIntent(TraversalDirection.right),
        // Tab for next focus
        const SingleActivator(LogicalKeyboardKey.tab): const NextFocusIntent(),
        const SingleActivator(LogicalKeyboardKey.tab, shift: true): const PreviousFocusIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          DirectionalFocusIntent: DirectionalFocusAction(),
          NextFocusIntent: NextFocusAction(),
          PreviousFocusIntent: PreviousFocusAction(),
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (intent) => _handleBack(context),
          ),
        },
        child: Focus(
          autofocus: true,
          onKeyEvent: (node, event) => _handleKeyEvent(context, event),
          child: widget.child,
        ),
      ),
    );
  }

  void _handleBack(BuildContext context) {
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  KeyEventResult _handleKeyEvent(BuildContext context, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    // Handle back/escape to pop navigation
    if (event.logicalKey == LogicalKeyboardKey.escape ||
        event.logicalKey == LogicalKeyboardKey.goBack ||
        event.logicalKey == LogicalKeyboardKey.browserBack ||
        event.physicalKey == PhysicalKeyboardKey.browserBack) {
      _handleBack(context);
      return KeyEventResult.handled;
    }

    // WebOS remote key codes (as physical keys)
    // 461 = Back button on WebOS
    if (event.physicalKey.usbHidUsage == 0x000700F1) {
      _handleBack(context);
      return KeyEventResult.handled;
    }

    // Let arrow keys be handled by Shortcuts widget
    return KeyEventResult.ignored;
  }
}

/// Extension to add TV-friendly focus traversal configuration
/// Uses WidgetOrderTraversalPolicy for predictable d-pad navigation
class TvFocusTraversalGroup extends StatelessWidget {
  final Widget child;

  const TvFocusTraversalGroup({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      child: child,
    );
  }
}

/// A horizontal focus traversal group for rows of content
/// Left/Right arrows move within the row, Up/Down move to other rows
class HorizontalTvFocusGroup extends StatelessWidget {
  final Widget child;

  const HorizontalTvFocusGroup({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      child: child,
    );
  }
}
