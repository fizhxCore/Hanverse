import 'package:flutter/material.dart';

/// Badge kecil "AI" dengan animasi pulsing lembut, dipasang di AppBar
/// biar keliatan aplikasi ini punya fitur AI.
class AiBadge extends StatefulWidget {
  const AiBadge({super.key});

  @override
  State<AiBadge> createState() => _AiBadgeState();
}

class _AiBadgeState extends State<AiBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(right: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withOpacity(_pulse.value),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withOpacity(0.25 * _pulse.value),
                blurRadius: 8 * _pulse.value,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, size: 14, color: scheme.onPrimaryContainer),
              const SizedBox(width: 4),
              Text(
                'AI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
