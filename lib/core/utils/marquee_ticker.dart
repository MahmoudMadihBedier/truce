import 'dart:async';
import 'package:flutter/material.dart';
import 'package:truce/core/utils/theme.dart';

class MarqueeTicker extends StatefulWidget {
  final List<Widget> children;
  final VoidCallback? onTap;

  const MarqueeTicker({super.key, required this.children, this.onTap});

  @override
  State<MarqueeTicker> createState() => _MarqueeTickerState();
}

class _MarqueeTickerState extends State<MarqueeTicker> {
  late ScrollController _scrollController;
  Timer? _timer;
  static const double _step = 1.0;
  static const Duration _frequency = Duration(milliseconds: 30);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() {
    _timer = Timer.periodic(_frequency, (timer) {
      if (_scrollController.hasClients) {
        final double maxExtent = _scrollController.position.maxScrollExtent;
        final double currentPosition = _scrollController.offset;

        if (currentPosition >= maxExtent) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.jumpTo(currentPosition + _step);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Duplicate children to ensure continuous scrolling
    final List<Widget> items = [...widget.children, ...widget.children];

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 40,
        color: TruceTheme.primaryContainer,
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            children: items.map((child) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: child,
            )).toList(),
          ),
        ),
      ),
    );
  }
}
