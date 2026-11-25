import 'package:flutter/material.dart';

import '../services/location_service.dart';
import '../services/metro_service.dart';
import '../widgets/line_badge.dart';

class NearestStationPage extends StatefulWidget {
  const NearestStationPage({super.key});

  @override
  State<NearestStationPage> createState() => _NearestStationPageState();
}

class _NearestStationPageState extends State<NearestStationPage> {
  static const List<String> _quickAreas = [
    'Nasr City',
    'Maadi',
    'Ghamra',
    'Heliopolis',
    'Downtown',
    'Giza',
    'Shubra',
    'New Cairo',
  ];

  final MetroService _metro = MetroService();
  final LocationService _location = const LocationService();
  final TextEditingController _controller = TextEditingController();

  NearestStationResult? _result;
  String? _error;
  List<String> _suggestions = const [];
  bool _openingMap = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search([String? value]) {
    FocusScope.of(context).unfocus();
    if (value != null) _controller.text = value;
    final query = _controller.text.trim();

    if (query.isEmpty) {
      setState(() {
        _result = null;
        _error = 'Type an area, city or landmark first.';
        _suggestions = const [];
      });
      return;
    }

    final result = _metro.nearestStation(query);
    if (result == null) {
      setState(() {
        _result = null;
        _error = 'No station was found for “$query”.';
        _suggestions = _metro.suggestStations(query);
      });
      return;
    }

    setState(() {
      _result = result;
      _error = null;
      _suggestions = const [];
    });
  }

  Future<void> _openInMaps() async {
    final result = _result;
    if (result == null) return;
    setState(() => _openingMap = true);
    try {
      await _location.openStationInMaps(result.station);
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

  void _useAsStart() {
    final result = _result;
    if (result == null) return;
    Navigator.of(context).pop(result.station);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Nearest station')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _NearestHeader(),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Enter your area',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'We match cities, districts and famous landmarks to the closest metro station.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _controller,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) => _search(),
                            decoration: InputDecoration(
                              labelText: 'Area, city or landmark',
                              hintText: 'e.g. Nasr City',
                              prefixIcon: const Icon(Icons.location_city_outlined),
                              suffixIcon: IconButton(
                                tooltip: 'Search',
                                onPressed: _search,
                                icon: const Icon(Icons.search),
                              ),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final area in _quickAreas)
                                ActionChip(
                                  label: Text(area),
                                  onPressed: () => _search(area),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _search,
                            icon: const Icon(Icons.near_me),
                            label: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Text('Find nearest station'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    _NearestError(
                      message: _error!,
                      suggestions: _suggestions,
                      onSuggestion: _search,
                    ),
                  ],
                  if (_result != null) ...[
                    const SizedBox(height: 16),
                    _NearestResultCard(
                      result: _result!,
                      openingMap: _openingMap,
                      onOpenMap: _openInMaps,
                      onUseAsStart: _useAsStart,
                    ),
                  ],
                  const SizedBox(height: 18),
                  Text(
                    'Tip: the nearest station is an approximate match based on the area name. '
                    'Use the map button to get directions to the station.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NearestHeader extends StatelessWidget {
  const _NearestHeader();

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
          colors: [Color(0xFF00695C), Color(0xFF26A69A)],
        ),
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
            child: const Icon(Icons.near_me, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find your closest station',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Type where you are and we will tell you which metro station to use.',
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

class _NearestResultCard extends StatelessWidget {
  const _NearestResultCard({
    required this.result,
    required this.openingMap,
    required this.onOpenMap,
    required this.onUseAsStart,
  });

  final NearestStationResult result;
  final bool openingMap;
  final VoidCallback onOpenMap;
  final VoidCallback onUseAsStart;

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
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00695C).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFF00695C),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NEAREST STATION',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        result.station,
                        style: theme.textTheme.titleLarge?.copyWith(
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
            const SizedBox(height: 10),
            Text(
              'Closest match for “${result.query}”.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final mapButton = OutlinedButton.icon(
                  onPressed: openingMap ? null : onOpenMap,
                  icon: openingMap
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.map_outlined),
                  label: Text(openingMap ? 'Opening…' : 'Open in Google Maps'),
                );
                final startButton = FilledButton.icon(
                  onPressed: onUseAsStart,
                  icon: const Icon(Icons.trip_origin),
                  label: const Text('Use as starting station'),
                );
                if (constraints.maxWidth < 520) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      startButton,
                      const SizedBox(height: 10),
                      mapButton,
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: startButton),
                    const SizedBox(width: 12),
                    Expanded(child: mapButton),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NearestError extends StatelessWidget {
  const _NearestError({
    required this.message,
    required this.suggestions,
    required this.onSuggestion,
  });

  final String message;
  final List<String> suggestions;
  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Did you mean:',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final station in suggestions)
                  ActionChip(
                    label: Text(station),
                    onPressed: () => onSuggestion(station),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
