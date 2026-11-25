import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/services/metro_service.dart';

void main() {
  late MetroService metro;

  setUp(() {
    metro = MetroService();
  });

  group('route planning', () {
    test('plans a direct trip on Line 1', () {
      final result = metro.findRoute(from: 'Maadi', to: 'Ghamra');

      expect(result.stops, 12);
      expect(result.minutes, 24);
      expect(result.ticket, 12);
      expect(result.legs, hasLength(1));
      expect(result.legs.single.line.id, 'L1');
      expect(result.legs.single.direction, 'New Marg');
      expect(result.stations.first, 'Maadi');
      expect(result.stations.last, 'Ghamra');
    });

    test('plans a trip with a transfer', () {
      final result = metro.findRoute(
        from: 'Maadi',
        to: 'Shubra Al Khaimah',
      );

      expect(result.legs, hasLength(2));
      expect(result.transferStations, ['Al-Shohadaa']);
      expect(result.stops, 18);
      expect(result.ticket, 15);
      expect(result.legs.first.line.id, 'L1');
      expect(result.legs.last.line.id, 'L2');
    });

    test('resolves an area name and transfers at Attaba', () {
      final result = metro.findRoute(
        from: 'Nasr City',
        to: 'Cairo University',
      );

      expect(result.from, 'Stadium');
      expect(result.legs, hasLength(2));
      expect(result.transferStations, ['Attaba']);
    });

    test('uses the shortest route through the shared trunk', () {
      final result = metro.findRoute(
        from: 'Adly Mansour',
        to: 'Cairo University',
      );

      expect(result.legs, hasLength(2));
      expect(result.transferStations, ['Attaba']);
      expect(result.stops, 24);
    });

    test('keeps a Line 4 branch trip on Line 4', () {
      final result = metro.findRoute(
        from: 'Adly Mansour',
        to: 'Tawfikia',
      );

      expect(result.legs, hasLength(1));
      expect(result.legs.single.line.id, 'L4');
      expect(result.stops, 23);
    });

    test('handles a full end-to-end trip', () {
      final result = metro.findRoute(from: 'New Marg', to: 'Helwan');

      expect(result.stops, 34);
      expect(result.minutes, 68);
      expect(result.ticket, 20);
      expect(result.legs, hasLength(1));
    });

    test('returns a zero-stop result for the same station', () {
      final result = metro.findRoute(from: 'Sadat', to: 'Sadat');

      expect(result.stops, 0);
      expect(result.isSameStation, isTrue);
      expect(result.legs, isEmpty);
    });

    test('throws a friendly error for an unknown station', () {
      expect(
        () => metro.findRoute(from: 'Nowhere', to: 'Sadat'),
        throwsA(isA<MetroException>()),
      );
    });
  });

  group('fare calculation', () {
    test('uses the correct fare tiers', () {
      expect(metro.calculateTicket(1), 9);
      expect(metro.calculateTicket(9), 9);
      expect(metro.calculateTicket(10), 12);
      expect(metro.calculateTicket(16), 12);
      expect(metro.calculateTicket(17), 15);
      expect(metro.calculateTicket(23), 15);
      expect(metro.calculateTicket(24), 20);
      expect(metro.calculateTicket(60), 20);
    });
  });

  group('nearest station', () {
    test('matches a district name', () {
      final result = metro.nearestStation('Nasr City');

      expect(result, isNotNull);
      expect(result!.station, 'Stadium');
      expect(result.lines.map((line) => line.id), contains('L3'));
    });

    test('matches an Arabic district name', () {
      final result = metro.nearestStation('المعادي');

      expect(result, isNotNull);
      expect(result!.station, 'Maadi');
    });

    test('matches a station name directly', () {
      final result = metro.nearestStation('ghamra');

      expect(result, isNotNull);
      expect(result!.station, 'Ghamra');
    });

    test('handles small typos', () {
      final result = metro.nearestStation('Maadi');

      expect(result, isNotNull);
      expect(result!.station, 'Maadi');
    });

    test('returns null for an unknown area', () {
      expect(metro.nearestStation('Atlantis'), isNull);
    });
  });
}
