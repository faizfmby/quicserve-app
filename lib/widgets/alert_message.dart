import 'package:flutter/material.dart';

class AlertMessage extends StatefulWidget {
  final String message;
  final Duration duration;
  final Color backgroundColor;

  const AlertMessage({
    super.key,
    required this.message,
    this.duration = const Duration(seconds: 2),
    this.backgroundColor = Colors.black87,
  });

  @override
  State<AlertMessage> createState() => _AlertMessageState();

  // Success
  static void showSuccess(BuildContext context, String message) {
    show(context, message: message, backgroundColor: Colors.green);
  }

  // Error
  static void showError(BuildContext context, String message) {
    show(context, message: message, backgroundColor: Colors.red);
  }

  // Shared Handler
  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    Color backgroundColor = Colors.black87,
  }) {
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => AlertMessage(
        message: message,
        duration: duration,
        backgroundColor: backgroundColor,
      ),
    );

    overlay.insert(entry);

    Future.delayed(duration + const Duration(milliseconds: 300), () {
      // Use WidgetsBinding to remove safely in next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        entry.remove();
      });
    });
  }
}

class _AlertMessageState extends State<AlertMessage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _playAnimation();
  }

  Future<void> _playAnimation() async {
    await _controller.forward();
    await Future.delayed(widget.duration);
    await _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: SlideTransition(
            position: _offsetAnimation,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Text(
                    widget.message,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
