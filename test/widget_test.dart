import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/main.dart';

void main() {
  testWidgets('shows the Cairo Metro trip planner', (WidgetTester tester) async {
    await tester.pumpWidget(const MetroApp());

    expect(find.text('Plan your trip'), findsOneWidget);
    expect(find.text('Where are you going?'), findsOneWidget);
    expect(find.text('Calculate route'), findsOneWidget);
  });
}
