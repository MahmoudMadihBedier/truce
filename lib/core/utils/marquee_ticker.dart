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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() async {
    while (_scrollController.hasClients) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (_scrollController.hasClients) {
        final maxExtent = _scrollController.position.maxScrollExtent;
        final currentPosition = _scrollController.offset;
        if (currentPosition >= maxExtent) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.animateTo(
            currentPosition + 1,
            duration: const Duration(milliseconds: 50),
            curve: Curves.linear,
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 40,
        color: TruceTheme.primaryContainer,
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return Row(
              children: widget.children.map((child) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: child,
              )).toList(),
            );
          },
        ),
      ),
    );
  }
}
