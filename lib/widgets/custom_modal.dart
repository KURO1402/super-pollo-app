import 'package:flutter/material.dart';

extension ModalExtension on BuildContext {
  void showCustomModal({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    bool isSuccess = false,
    VoidCallback? onClose,
    Duration? autoCloseDuration,
  }) {
    final overlay = Overlay.of(this);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        title: title,
        message: message,
        icon: icon,
        color: color,
        onDismiss: () {
          entry.remove();
          onClose?.call();
        },
        duration: autoCloseDuration ?? const Duration(seconds: 3),
      ),
    );

    overlay.insert(entry);
  }
}

class _ToastWidget extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback onDismiss;
  final Duration duration;

  const _ToastWidget({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.onDismiss,
    required this.duration,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward();
    Future.delayed(widget.duration, _dismiss);
  }

  void _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _dismiss,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1a0a02),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(widget.icon, color: widget.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.message,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.close,
                      color: Colors.white.withOpacity(0.3),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
