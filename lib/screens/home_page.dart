import 'package:flutter/material.dart';

import '../services/location_service.dart';
import '../services/metro_service.dart';
import '../widgets/line_badge.dart';
import '../widgets/route_timeline.dart';
import '../widgets/stat_card.dart';
import '../widgets/station_field.dart';
import 'nearest_station_page.dart';
import 'route_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MetroService _metro = MetroService();
  final LocationService _location = const LocationService();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final GlobalKey _resultKey = GlobalKey();

  RouteResult? _result;
  String? _error;
  bool _openingMap = false;

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _calculate() {
    FocusScope.of(context).unfocus();
    final from = _fromController.text.trim();
    final to = _toController.text.trim();

    if (from.isEmpty || to.isEmpty) {
      setState(() {
        _result = null;
        _error = 'Enter both a starting station and a destination.';
      });
      return;
    }

    try {
      final result = _metro.findRoute(from: from, to: to);
      setState(() {
        _result = result;
        _error = null;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = _resultKey.currentContext;
        if (context != null) {
          Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            alignment: 0.05,
          );
        }
      });
    } on MetroException catch (error) {
      setState(() {
        _result = null;
        _error = error.message;
      });
    }
  }

  void _swapStations() {
    final from = _fromController.text;
    _fromController.text = _toController.text;
    _toController.text = from;
    setState(() {
      _result = null;
      _error = null;
    });
  }

  Future<void> _openMap() async {
    setState(() => _openingMap = true);
    try {
      final result = await _location.openCurrentLocationInMaps();
      if (!mounted) return;
      if (result.usedFallback) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${result.message ?? 'Your location is unavailable.'} Showing Cairo instead.',
            ),
          ),
        );
      }
    } on LocationException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps.')),
      );
    } finally {
      if (mounted) setState(() => _openingMap = false);
    }
  }

  Future<void> _openNearestStation() async {
    final station = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const NearestStationPage()),
    );
    if (station == null || !mounted) return;
    setState(() {
      _fromController.text = station;
      _result = null;
      _error = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting station set to $station.')),
    );
  }

  void _openMoreInfo() {
    final result = _result;
    if (result == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RouteDetailsPage(result: result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cairo Metro'),
        actions: [
          IconButton(
            tooltip: 'Nearest station',
            onPressed: _openNearestStation,
            icon: const Icon(Icons.near_me_outlined),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _HeroHeader(),
                  const SizedBox(height: 16),
                  _PlannerCard(
                    fromController: _fromController,
                    toController: _toController,
                    onSwap: _swapStations,
                    onCalculate: _calculate,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    _ErrorBanner(message: _error!),
                  ],
                  if (_result != null) ...[
                    const SizedBox(height: 16),
                    _buildResult(theme, _result!),
                  ],
                  const SizedBox(height: 20),
                  _FareNote(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResult(ThemeData theme, RouteResult result) {
    if (result.isSameStation) {
      return Card(
        key: _resultKey,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You are already at ${result.from}. Choose a different destination.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      key: _resultKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TripSummary(result: result),
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
                    Icon(Icons.alt_route, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Your route',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${result.stops} ${result.stops == 1 ? 'stop' : 'stops'}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                RouteTimeline(result: result),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final mapButton = OutlinedButton.icon(
              onPressed: _openingMap ? null : _openMap,
              icon: _openingMap
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.map_outlined),
              label: Text(_openingMap ? 'Opening map…' : 'My location on map'),
            );
            final infoButton = FilledButton.icon(
              onPressed: _openMoreInfo,
              icon: const Icon(Icons.info_outline),
              label: const Text('More info'),
            );

            if (constraints.maxWidth < 480) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  mapButton,
                  const SizedBox(height: 10),
                  infoButton,
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: mapButton),
                const SizedBox(width: 12),
                Expanded(child: infoButton),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

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
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.subway, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan your trip',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pick a start and destination to see the route, travel time and ticket price.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlannerCard extends StatelessWidget {
  const _PlannerCard({
    required this.fromController,
    required this.toController,
    required this.onSwap,
    required this.onCalculate,
  });

  final TextEditingController fromController;
  final TextEditingController toController;
  final VoidCallback onSwap;
  final VoidCallback onCalculate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Where are you going?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Type a station name, or an area such as “Nasr City”.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: StationField(
                          controller: fromController,
                          label: 'From',
                          icon: Icons.trip_origin,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 4, right: 4),
                        child: IconButton(
                          tooltip: 'Swap stations',
                          onPressed: onSwap,
                          icon: const Icon(Icons.swap_horiz),
                        ),
                      ),
                      Expanded(
                        child: StationField(
                          controller: toController,
                          label: 'To',
                          icon: Icons.place_outlined,
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    StationField(
                      controller: fromController,
                      label: 'From',
                      icon: Icons.trip_origin,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: onSwap,
                        icon: const Icon(Icons.swap_vert, size: 18),
                        label: const Text('Swap'),
                      ),
                    ),
                    StationField(
                      controller: toController,
                      label: 'To',
                      icon: Icons.place_outlined,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onCalculate,
              icon: const Icon(Icons.route),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text('Calculate route'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripSummary extends StatelessWidget {
  const _TripSummary({required this.result});

  final RouteResult result;

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FROM',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        result.from,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward, color: theme.colorScheme.primary),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'TO',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        result.to,
                        textAlign: TextAlign.end,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LineBadgeRow(lines: result.lines, compact: false),
            if (result.transferStations.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.swap_calls,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Transfer at ${result.transferStations.join(', ')}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FareNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Ticket prices: 9 EGP (1–9 stops), 12 EGP (10–16), '
              '15 EGP (17–23), 20 EGP (24+).',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
