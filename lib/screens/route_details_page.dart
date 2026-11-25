import 'package:flutter/material.dart';

import '../data/metro_data.dart';
import '../services/metro_service.dart';
import '../widgets/line_badge.dart';
import '../widgets/stat_card.dart';
import 'nearest_station_page.dart';

class RouteDetailsPage extends StatelessWidget {
  const RouteDetailsPage({super.key, required this.result});

  final RouteResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('More info')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TripHeader(result: result),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth < 480
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 24) / 3;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: width,
                            child: StatCard(
                              icon: Icons.commit,
                              value: '${result.stops}',
                              label: result.stops == 1 ? 'stop' : 'stops',
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: StatCard(
                              icon: Icons.schedule,
                              value: '${result.minutes} min',
                              label: 'estimated time',
                              color: const Color(0xFF00897B),
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: StatCard(
                              icon: Icons.confirmation_number_outlined,
                              value: '${result.ticket} EGP',
                              label: 'ticket price',
                              color: const Color(0xFFEF6C00),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.directions, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Directions',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          for (var i = 0; i < result.legs.length; i++)
                            _LegStep(
                              leg: result.legs[i],
                              index: i,
                              isLast: i == result.legs.length - 1,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.list_alt, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                'All stations',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${result.stations.length} stations',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          for (var i = 0; i < result.stations.length; i++)
                            _StationListTile(
                              station: result.stations[i],
                              number: i + 1,
                              isTransfer:
                                  result.transferStations.contains(result.stations[i]),
                              lines: _linesForStation(result, result.stations[i]),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FareCard(stops: result.stops, ticket: result.ticket),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final nearestButton = OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const NearestStationPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.near_me_outlined),
                        label: const Text('Find nearest station'),
                      );
                      final backButton = FilledButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Plan another route'),
                      );
                      if (constraints.maxWidth < 480) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            nearestButton,
                            const SizedBox(height: 10),
                            backButton,
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(child: nearestButton),
                          const SizedBox(width: 12),
                          Expanded(child: backButton),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<MetroLine> _linesForStation(RouteResult result, String station) {
    final lines = <MetroLine>[];
    for (final leg in result.legs) {
      if (leg.stations.contains(station) && !lines.contains(leg.line)) {
        lines.add(leg.line);
      }
    }
    return lines;
  }
}

class _TripHeader extends StatelessWidget {
  const _TripHeader({required this.result});

  final RouteResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D47A1), Color(0xFF1E88E5)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR TRIP',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white70,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  result.from,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward, color: Colors.white),
              ),
              Expanded(
                child: Text(
                  result.to,
                  textAlign: TextAlign.end,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            result.legs.length == 1
                ? 'Direct trip on ${result.legs.first.line.name}'
                : '${result.legs.length} rides · transfer at ${result.transferStations.join(', ')}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 12),
          LineBadgeRow(lines: result.lines, compact: false, onDark: true),
        ],
      ),
    );
  }
}

class _LegStep extends StatelessWidget {
  const _LegStep({
    required this.leg,
    required this.index,
    required this.isLast,
  });

  final RouteLeg leg;
  final int index;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: leg.line.color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 72,
                  color: leg.line.color.withValues(alpha: 0.3),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    LineBadge(line: leg.line),
                    const SizedBox(width: 8),
                    Text(
                      '${leg.stops} ${leg.stops == 1 ? 'stop' : 'stops'}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Board at ${leg.from}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ride towards ${leg.direction}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Get off at ${leg.to}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!isLast) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.swap_calls,
                        size: 16,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Change here to continue your trip.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StationListTile extends StatelessWidget {
  const _StationListTile({
    required this.station,
    required this.number,
    required this.isTransfer,
    required this.lines,
  });

  final String station;
  final int number;
  final bool isTransfer;
  final List<MetroLine> lines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(
              '$number',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: lines.isEmpty
                  ? theme.colorScheme.outlineVariant
                  : lines.first.color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              station,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isTransfer ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
          if (isTransfer) ...[
            Text(
              'transfer',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            if (lines.isNotEmpty) LineBadgeRow(lines: lines),
          ],
        ],
      ),
    );
  }
}

class _FareCard extends StatelessWidget {
  const _FareCard({required this.stops, required this.ticket});

  final int stops;
  final int ticket;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payments_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Ticket price',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  '$ticket EGP',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Your trip is $stops ${stops == 1 ? 'stop' : 'stops'}, so the fare is $ticket EGP.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            for (final tier in fareTiers)
              _FareRow(
                label: tier.label,
                price: tier.price,
                active: tier.price == ticket,
              ),
          ],
        ),
      ),
    );
  }
}

class _FareRow extends StatelessWidget {
  const _FareRow({
    required this.label,
    required this.price,
    required this.active,
  });

  final String label;
  final int price;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: active
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.6)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: active ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$price EGP',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: active ? theme.colorScheme.primary : null,
            ),
          ),
          if (active) ...[
            const SizedBox(width: 6),
            Icon(Icons.check_circle, size: 16, color: theme.colorScheme.primary),
          ],
        ],
      ),
    );
  }
}
