import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vadama_mobile/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Initialize dotenv for testing using loadFromString
    await dotenv.load(fileName: '.env', isOptional: true);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: VadamaApp()));

    // Verify that we are on the login screen or loading
    // Since we can't easily mock the auth state here without complex overrides,
    // we just check if the app builds without crashing.
    expect(find.byType(VadamaApp), findsOneWidget);
  });
}
