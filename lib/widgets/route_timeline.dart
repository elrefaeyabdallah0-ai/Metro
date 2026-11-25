import 'package:flutter/material.dart';

import '../data/metro_data.dart';
import '../services/metro_service.dart';
import 'line_badge.dart';

/// A vertical, line-coloured timeline of the planned route.
class RouteTimeline extends StatelessWidget {
  const RouteTimeline({super.key, required this.result});

  final RouteResult result;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    for (var i = 0; i < result.legs.length; i++) {
      final leg = result.legs[i];
      if (i > 0) {
        children.add(
          _TransferRow(
            station: leg.from,
            fromLine: result.legs[i - 1].line,
            toLine: leg.line,
          ),
        );
      }

      children.add(_LegHeader(leg: leg));

      final stations = i == 0 ? leg.stations : leg.stations.skip(1).toList();
      for (var j = 0; j < stations.length; j++) {
        final isFirst = i == 0 && j == 0;
        final isLast = i == result.legs.length - 1 && j == stations.length - 1;
        children.add(
          _StationRow(
            station: stations[j],
            color: leg.line.color,
            isFirst: isFirst,
            isLast: isLast,
            isTransfer: i > 0 && j == 0,
          ),
        );
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
  }
}

class _LegHeader extends StatelessWidget {
  const _LegHeader({required this.leg});

  final RouteLeg leg;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: leg.line.color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: leg.line.color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          LineBadge(line: leg.line),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Towards ${leg.direction}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '${leg.stops} ${leg.stops == 1 ? 'stop' : 'stops'}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: leg.line.color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StationRow extends StatelessWidget {
  const _StationRow({
    required this.station,
    required this.color,
    required this.isFirst,
    required this.isLast,
    required this.isTransfer,
  });

  final String station;
  final Color color;
  final bool isFirst;
  final bool isLast;
  final bool isTransfer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 30,
          child: Column(
            children: [
              Container(
                width: 3,
                height: 8,
                color: isFirst ? Colors.transparent : color.withValues(alpha: 0.5),
              ),
              Container(
                width: isTransfer ? 16 : 12,
                height: isTransfer ? 16 : 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isTransfer ? Colors.white : color,
                  border: Border.all(
                    color: color,
                    width: isTransfer ? 4 : 2,
                  ),
                ),
              ),
              Container(
                width: 3,
                height: 24,
                color: isLast ? Colors.transparent : color.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 12),
            child: Text(
              station,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isTransfer || isFirst || isLast
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TransferRow extends StatelessWidget {
  const _TransferRow({
    required this.station,
    required this.fromLine,
    required this.toLine,
  });

  final String station;
  final MetroLine fromLine;
  final MetroLine toLine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.swap_calls, size: 20, color: theme.colorScheme.onSecondaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                children: [
                  const TextSpan(text: 'Change at '),
                  TextSpan(
                    text: station,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const TextSpan(text: ' to '),
                  TextSpan(
                    text: toLine.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: toLine.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
          LineBadge(line: fromLine, compact: true),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Icon(Icons.arrow_forward, size: 14),
          ),
          LineBadge(line: toLine, compact: true),
        ],
      ),
    );
  }
}
