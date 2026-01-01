import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A wrapper widget that adds TV-friendly focus behavior to any child widget.
/// Shows a focus ring when focused and handles Enter/Select key presses.
class FocusableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onSelect;
  final FocusNode? focusNode;
  final bool autofocus;
  final double focusScale;
  final Color? focusColor;
  final double focusBorderWidth;
  final BorderRadius? borderRadius;

  const FocusableCard({
    super.key,
    required this.child,
    required this.onSelect,
    this.focusNode,
    this.autofocus = false,
    this.focusScale = 1.05,
    this.focusColor,
    this.focusBorderWidth = 3.0,
    this.borderRadius,
  });

  @override
  State<FocusableCard> createState() => _FocusableCardState();
}

class _FocusableCardState extends State<FocusableCard>
    with SingleTickerProviderStateMixin {
  late final FocusNode _focusNode;
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.focusScale,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange(bool hasFocus) {
    setState(() {
      _isFocused = hasFocus;
    });

    if (hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    // Handle Enter, Space, or Select key
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space ||
        event.logicalKey == LogicalKeyboardKey.select) {
      widget.onSelect();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final focusColor =
        widget.focusColor ?? Theme.of(context).colorScheme.primary;
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(8);

    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onFocusChange: _handleFocusChange,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: () {
          _focusNode.requestFocus();
          widget.onSelect();
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  border: _isFocused
                      ? Border.all(
                          color: focusColor,
                          width: widget.focusBorderWidth,
                        )
                      : null,
                  boxShadow: _isFocused
                      ? [
                          BoxShadow(
                            color: focusColor.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: widget.child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
