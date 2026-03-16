import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Wraps a page with swipe-back gesture (swipe from left edge) and optional back button.
/// Use for pages navigated via context.go() that need a way to return to /home.
class SwipeBackWrapper extends StatelessWidget {
  final Widget child;
  final bool showBackButton;

  const SwipeBackWrapper({
    super.key,
    required this.child,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // Swipe right to go back
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          _goBack(context);
        }
      },
      child: child,
    );
  }

  void _goBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/home');
    }
  }
}

/// Mixin for screens that need swipe-back and back button functionality
mixin SwipeBackMixin<T extends StatefulWidget> on State<T> {
  void handleGoBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/home');
    }
  }

  Widget buildBackButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () => handleGoBack(context),
    );
  }

  Widget wrapWithSwipeBack(Widget child) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          handleGoBack(context);
        }
      },
      child: child,
    );
  }
}
