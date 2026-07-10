import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/domain/ports/export_port.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/infrastructure/preferences/app_preferences.dart';
import 'package:open_bike/plugins/plugin_interfaces.dart';
import 'package:open_bike/plugins/plugin_manifest.dart';
import 'package:open_bike/plugins/plugin_registry.dart';
import 'package:open_bike/presentation/state/providers.dart';
import 'package:open_bike/presentation/widgets/connections_section.dart';

// ---------------------------------------------------------------------------
// Fakes — stand-in for a private-package plugin (Records/OpenCoach) so the
// Connections UI can be exercised without any real OAuth/network calls.
// ---------------------------------------------------------------------------

class FakeExportPlugin implements ExportPlugin {
  FakeExportPlugin({
    required String id,
    required String name,
    List<String> capabilities = const ['oauth2'],
  }) : _manifest = PluginManifest(
          id: id,
          name: name,
          version: '1.0.0',
          type: PluginType.export,
          capabilities: capabilities,
        );

  final PluginManifest _manifest;
  bool _authenticated = false;

  @override
  PluginManifest get manifest => _manifest;

  @override
  bool get isAuthenticated => _authenticated;

  @override
  Future<void> authenticate() async => _authenticated = true;

  @override
  Future<void> disconnect() async => _authenticated = false;

  @override
  Future<String> export(Ride ride,
      {ExportFormat format = ExportFormat.fit, Watts? ftp}) async {
    return 'exported';
  }
}

Future<AppPreferences> _fakePrefs() async {
  SharedPreferences.setMockInitialValues({});
  return AppPreferences(await SharedPreferences.getInstance());
}

Future<void> _pump(
  WidgetTester tester,
  PluginRegistry registry,
  AppPreferences prefs,
) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        pluginRegistryProvider.overrideWithValue(registry),
        appPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MaterialApp(
        home: Scaffold(body: ConnectionsSection()),
      ),
    ),
  );
}

void main() {
  group('ConnectionsSection', () {
    testWidgets('shows a placeholder when no plugins are registered',
        (tester) async {
      await _pump(tester, PluginRegistry(), await _fakePrefs());

      expect(find.text('No export plugins configured.'), findsOneWidget);
    });

    testWidgets('renders a row per registered plugin (data-driven)',
        (tester) async {
      final registry = PluginRegistry()
        ..registerExport(FakeExportPlugin(id: 'records', name: 'Records'))
        ..registerExport(FakeExportPlugin(id: 'opencoach', name: 'OpenCoach'));

      await _pump(tester, registry, await _fakePrefs());

      expect(find.text('Records'), findsOneWidget);
      expect(find.text('OpenCoach'), findsOneWidget);
    });

    testWidgets('unauthenticated oauth2 plugin shows Connect / Not connected',
        (tester) async {
      final registry = PluginRegistry()
        ..registerExport(FakeExportPlugin(id: 'fake-oauth', name: 'Fake Service'));

      await _pump(tester, registry, await _fakePrefs());

      expect(find.text('Connect'), findsOneWidget);
      expect(find.text('Not connected'), findsOneWidget);
    });

    testWidgets('tapping Connect authenticates and flips to Disconnect',
        (tester) async {
      final plugin = FakeExportPlugin(id: 'fake-oauth', name: 'Fake Service');
      final registry = PluginRegistry()..registerExport(plugin);

      await _pump(tester, registry, await _fakePrefs());
      await tester.tap(find.text('Connect'));
      await tester.pumpAndSettle();

      expect(plugin.isAuthenticated, isTrue);
      expect(find.text('Disconnect'), findsOneWidget);
      expect(find.text('Connected'), findsOneWidget);
    });

    testWidgets('tapping Disconnect clears authentication', (tester) async {
      final plugin = FakeExportPlugin(id: 'fake-oauth', name: 'Fake Service');
      final registry = PluginRegistry()..registerExport(plugin);

      await _pump(tester, registry, await _fakePrefs());
      await tester.tap(find.text('Connect'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Disconnect'));
      await tester.pumpAndSettle();

      expect(plugin.isAuthenticated, isFalse);
      expect(find.text('Connect'), findsOneWidget);
      expect(find.text('Not connected'), findsOneWidget);
    });

    testWidgets('non-oauth2 plugin shows Available with no connect action',
        (tester) async {
      final registry = PluginRegistry()
        ..registerExport(FakeExportPlugin(
          id: 'fake-file',
          name: 'Fake File Export',
          capabilities: const ['file-export'],
        ));

      await _pump(tester, registry, await _fakePrefs());

      expect(find.text('Available'), findsWidgets);
      expect(find.text('Connect'), findsNothing);
    });

    testWidgets('auto-upload switch is disabled until connected',
        (tester) async {
      final plugin = FakeExportPlugin(id: 'fake-oauth', name: 'Fake Service');
      final registry = PluginRegistry()..registerExport(plugin);

      await _pump(tester, registry, await _fakePrefs());

      final before = tester.widget<Switch>(find.byType(Switch));
      expect(before.onChanged, isNull);

      await tester.tap(find.text('Connect'));
      await tester.pumpAndSettle();

      final after = tester.widget<Switch>(find.byType(Switch));
      expect(after.onChanged, isNotNull);
    });

    testWidgets('toggling auto-upload persists via AppPreferences',
        (tester) async {
      final plugin = FakeExportPlugin(id: 'fake-oauth', name: 'Fake Service');
      final registry = PluginRegistry()..registerExport(plugin);
      final prefs = await _fakePrefs();

      await _pump(tester, registry, prefs);
      await tester.tap(find.text('Connect'));
      await tester.pumpAndSettle();

      expect(prefs.isAutoUploadEnabled('fake-oauth'), isFalse);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(prefs.isAutoUploadEnabled('fake-oauth'), isTrue);
    });
  });
}
