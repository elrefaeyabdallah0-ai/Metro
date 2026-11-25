import 'dart:collection';

import '../data/metro_data.dart';

/// Thrown when a route cannot be planned.
class MetroException implements Exception {
  const MetroException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// One continuous ride on a single metro line.
class RouteLeg {
  const RouteLeg({
    required this.line,
    required this.stations,
    required this.direction,
  });

  final MetroLine line;
  final List<String> stations;
  final String direction;

  int get stops => stations.length - 1;
  String get from => stations.first;
  String get to => stations.last;
}

/// The complete result of a route search.
class RouteResult {
  const RouteResult({
    required this.stations,
    required this.legs,
    required this.stops,
    required this.minutes,
    required this.ticket,
  });

  final List<String> stations;
  final List<RouteLeg> legs;
  final int stops;
  final int minutes;
  final int ticket;

  String get from => stations.first;
  String get to => stations.last;

  bool get isSameStation => stations.length == 1;

  List<String> get transferStations =>
      legs.length <= 1 ? const [] : legs.skip(1).map((leg) => leg.from).toList();

  List<MetroLine> get lines {
    final seen = <String>{};
    final result = <MetroLine>[];
    for (final leg in legs) {
      if (seen.add(leg.line.id)) result.add(leg.line);
    }
    return result;
  }
}

/// A station returned by the "nearest station" search.
class NearestStationResult {
  const NearestStationResult({
    required this.station,
    required this.lines,
    required this.query,
  });

  final String station;
  final List<MetroLine> lines;
  final String query;
}

/// Route planning, station search and fare calculation for the Cairo Metro.
class MetroService {
  MetroService() {
    for (final line in metroLines) {
      for (final station in line.stations) {
        _linesByStation.putIfAbsent(station, () => <MetroLine>[]).add(line);
        _normalizedStations[normalize(station)] = station;
      }
      for (var i = 0; i < line.stations.length - 1; i++) {
        final a = line.stations[i];
        final b = line.stations[i + 1];
        _adjacency.putIfAbsent(a, () => <String>[]).add(b);
        _adjacency.putIfAbsent(b, () => <String>[]).add(a);
      }
    }
  }

  final Map<String, List<String>> _adjacency = {};
  final Map<String, List<MetroLine>> _linesByStation = {};
  final Map<String, String> _normalizedStations = {};

  /// Normalises user input so matching is case, punctuation and Arabic-friendly.
  String normalize(String value) {
    var text = value.toLowerCase().trim();
    // Arabic diacritics and tatweel.
    text = text.replaceAll(RegExp(r'[\u064B-\u0652\u0670\u0640]'), '');
    text = text.replaceAll(RegExp(r'[أإآ]'), 'ا');
    text = text.replaceAll('ى', 'ي');
    text = text.replaceAll('ة', 'ه');
    text = text.replaceAll(RegExp(r"[\-_/.,'’()]"), ' ');
    text = text.replaceAll(RegExp(r'\s+'), ' ');
    return text.trim();
  }

  /// Finds the canonical station name for a user supplied area or station.
  String? resolveStation(String input) {
    final query = normalize(input);
    if (query.isEmpty) return null;

    // 1. Exact station name.
    final exactStation = _normalizedStations[query];
    if (exactStation != null) return exactStation;

    // 2. Exact area/landmark alias.
    for (final area in metroAreas) {
      for (final term in area.searchTerms) {
        if (normalize(term) == query) return area.station;
      }
    }

    // 3. A station name that contains the query (or vice versa).
    String? bestStation;
    var bestScore = 1 << 30;
    for (final station in allStations) {
      final normalized = normalize(station);
      if (normalized.contains(query) || query.contains(normalized)) {
        final score = (normalized.length - query.length).abs();
        if (score < bestScore) {
          bestScore = score;
          bestStation = station;
        }
      }
    }
    if (bestStation != null) return bestStation;

    // 4. An area alias that contains the query (or vice versa).
    MetroArea? bestArea;
    var bestAreaScore = 1 << 30;
    for (final area in metroAreas) {
      for (final term in area.searchTerms) {
        final normalized = normalize(term);
        if (normalized.contains(query) || query.contains(normalized)) {
          final score = (normalized.length - query.length).abs();
          if (score < bestAreaScore) {
            bestAreaScore = score;
            bestArea = area;
          }
        }
      }
    }
    if (bestArea != null) return bestArea.station;

    // 5. Typo-tolerant matching.
    String? fuzzyStation;
    var fuzzyDistance = 1 << 30;
    for (final station in allStations) {
      final distance = _levenshtein(query, normalize(station));
      final limit = normalize(station).length <= 4 ? 1 : 2;
      if (distance <= limit && distance < fuzzyDistance) {
        fuzzyDistance = distance;
        fuzzyStation = station;
      }
    }
    if (fuzzyStation != null) return fuzzyStation;

    for (final area in metroAreas) {
      for (final term in area.searchTerms) {
        final distance = _levenshtein(query, normalize(term));
        final limit = normalize(term).length <= 4 ? 1 : 2;
        if (distance <= limit && distance < fuzzyDistance) {
          fuzzyDistance = distance;
          fuzzyStation = area.station;
        }
      }
    }
    return fuzzyStation;
  }

  /// Suggestions shown when an area cannot be resolved.
  List<String> suggestStations(String input, {int limit = 6}) {
    final query = normalize(input);
    if (query.isEmpty) return const [];

    final scored = <({String station, int score})>[];
    for (final station in allStations) {
      final normalized = normalize(station);
      if (normalized.contains(query) || query.contains(normalized)) {
        scored.add((station: station, score: (normalized.length - query.length).abs()));
        continue;
      }
      final distance = _levenshtein(query, normalized);
      if (distance <= 3) {
        scored.add((station: station, score: distance + 100));
      }
    }
    scored.sort((a, b) => a.score.compareTo(b.score));
    return scored.take(limit).map((entry) => entry.station).toList();
  }

  /// Finds the station that serves an area, city or landmark.
  NearestStationResult? nearestStation(String input) {
    final station = resolveStation(input);
    if (station == null) return null;
    return NearestStationResult(
      station: station,
      lines: linesForStation(station),
      query: input.trim(),
    );
  }

  List<MetroLine> linesForStation(String station) =>
      List.unmodifiable(_linesByStation[station] ?? const <MetroLine>[]);

  /// Plans the shortest route between two stations using BFS.
  RouteResult findRoute({required String from, required String to}) {
    final start = resolveStation(from);
    final end = resolveStation(to);

    if (start == null) {
      throw MetroException('Station not found: "$from". Try a station or area name.');
    }
    if (end == null) {
      throw MetroException('Station not found: "$to". Try a station or area name.');
    }

    if (start == end) {
      return RouteResult(
        stations: [start],
        legs: const [],
        stops: 0,
        minutes: 0,
        ticket: 0,
      );
    }

    final queue = Queue<String>()..add(start);
    final visited = <String>{start};
    final parent = <String, String>{};
    var found = false;

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      if (current == end) {
        found = true;
        break;
      }
      for (final neighbour in _adjacency[current] ?? const <String>[]) {
        if (visited.add(neighbour)) {
          parent[neighbour] = current;
          queue.add(neighbour);
        }
      }
    }

    if (!found) {
      throw const MetroException(
        'No route was found between these two stations.',
      );
    }

    final path = <String>[];
    String? current = end;
    while (current != null) {
      path.insert(0, current);
      current = parent[current];
    }

    final legs = _buildLegs(path);
    final stops = path.length - 1;
    return RouteResult(
      stations: List.unmodifiable(path),
      legs: List.unmodifiable(legs),
      stops: stops,
      minutes: stops * 2,
      ticket: calculateTicket(stops),
    );
  }

  int calculateTicket(int stops) {
    for (final tier in fareTiers) {
      if (tier.maxStops == null || stops <= tier.maxStops!) return tier.price;
    }
    return fareTiers.last.price;
  }

  List<RouteLeg> _buildLegs(List<String> path) {
    final legs = <RouteLeg>[];
    var index = 0;

    while (index < path.length - 1) {
      final candidates = _linesForPair(path[index], path[index + 1]);
      if (candidates.isEmpty) {
        throw MetroException(
          'Could not determine a line between ${path[index]} and ${path[index + 1]}.',
        );
      }

      final line = _chooseLine(candidates, path, index);
      var end = index + 1;
      while (end < path.length - 1 &&
          _linesForPair(path[end], path[end + 1]).contains(line)) {
        end++;
      }

      final legStations = path.sublist(index, end + 1);
      final startOnLine = line.stations.indexOf(legStations.first);
      final endOnLine = line.stations.indexOf(legStations.last);
      final direction = endOnLine >= startOnLine
          ? line.stations.last
          : line.stations.first;

      legs.add(RouteLeg(
        line: line,
        stations: List.unmodifiable(legStations),
        direction: direction,
      ));
      index = end;
    }

    return legs;
  }

  /// Prefers the line that covers the longest upcoming part of the path.
  /// This avoids picking Line 3 for a trip that branches onto Line 4.
  MetroLine _chooseLine(List<MetroLine> candidates, List<String> path, int index) {
    if (candidates.length == 1) return candidates.first;

    var best = candidates.first;
    var bestScore = -1;
    for (final line in candidates) {
      var score = 0;
      for (var i = index; i < path.length - 1; i++) {
        if (_linesForPair(path[i], path[i + 1]).contains(line)) {
          score++;
        } else {
          break;
        }
      }
      if (score > bestScore) {
        bestScore = score;
        best = line;
      }
    }
    return best;
  }

  List<MetroLine> _linesForPair(String a, String b) {
    final result = <MetroLine>[];
    for (final line in metroLines) {
      if (line.stations.contains(a) && line.stations.contains(b)) {
        result.add(line);
      }
    }
    return result;
  }

  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    var previous = List<int>.generate(b.length + 1, (i) => i);
    for (var i = 0; i < a.length; i++) {
      final current = List<int>.filled(b.length + 1, 0);
      current[0] = i + 1;
      for (var j = 0; j < b.length; j++) {
        final cost = a.codeUnitAt(i) == b.codeUnitAt(j) ? 0 : 1;
        final deletion = previous[j + 1] + 1;
        final insertion = current[j] + 1;
        final substitution = previous[j] + cost;
        current[j + 1] = deletion < insertion
            ? (deletion < substitution ? deletion : substitution)
            : (insertion < substitution ? insertion : substitution);
      }
      previous = current;
    }
    return previous[b.length];
  }
}
