import 'package:flutter/material.dart';

import '../data/metro_data.dart';

class LineBadge extends StatelessWidget {
  const LineBadge({
    super.key,
    required this.line,
    this.compact = false,
    this.onDark = false,
  });

  final MetroLine line;
  final bool compact;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: onDark ? Colors.white : line.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: onDark ? Colors.white : line.color.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        compact ? line.id : line.name,
        style: TextStyle(
          color: line.color,
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class LineBadgeRow extends StatelessWidget {
  const LineBadgeRow({
    super.key,
    required this.lines,
    this.compact = true,
    this.onDark = false,
  });

  final List<MetroLine> lines;
  final bool compact;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final line in lines)
          LineBadge(line: line, compact: compact, onDark: onDark),
      ],
    );
  }
}
