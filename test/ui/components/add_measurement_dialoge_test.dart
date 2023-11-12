import 'package:blood_pressure_app/components/dialoges/add_measurement.dart';
import 'package:blood_pressure_app/components/settings/color_picker_list_tile.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'settings/color_picker_list_tile_test.dart';

void main() {
  group('AddMeasurementDialoge', () {
    testWidgets('should show everything on initial page', (widgetTester) async {
      await widgetTester.pumpWidget(_materialApp(
        AddMeasurementDialoge(
          settings: Settings(),
        )
      ));
      expect(find.text('SAVE'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('Systolic'), findsAny);
      expect(find.text('Diastolic'), findsAny);
      expect(find.text('Pulse'), findsAny);
      expect(find.byType(ColorSelectionListTile), findsOneWidget);
    });
    testWidgets('should prefill initialRecord values', (widgetTester) async {
      await widgetTester.pumpWidget(_materialApp(
          AddMeasurementDialoge(
            settings: Settings(),
            initialRecord: BloodPressureRecord(
              DateTime.now(), 123, 56, 43, 'Test note',
              needlePin: const MeasurementNeedlePin(Colors.teal)
            ),
          )
      ));
      await widgetTester.pumpAndSettle();
      expect(find.text('SAVE'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('Test note'), findsOneWidget);
      expect(find.text('123'), findsOneWidget);
      expect(find.text('56'), findsOneWidget);
      expect(find.text('43'), findsOneWidget);
      expect(find.byType(ColorSelectionListTile), findsOneWidget);
      expect(find.byType(ColorSelectionListTile).evaluate().first.widget, isA<ColorSelectionListTile>().
      having((p0) => p0.initialColor, 'ColorSelectionListTile should have correct initial color', Colors.teal));
    });
  });
  group('showAddMeasurementDialoge', () {
    testWidgets('should return null on cancel', (widgetTester) async {
      dynamic result = 'not null';
      await widgetTester.pumpWidget(_materialApp(
          Builder(
            builder: (BuildContext context) => TextButton(onPressed: () async {
              result = await showAddMeasurementDialoge(context, Settings(),
                  BloodPressureRecord(
                      DateTime.now(), 123, 56, 43, 'Test note',
                      needlePin: const MeasurementNeedlePin(Colors.teal)
                  ));
            }, child: const Text('TEST')),
      )));
      await widgetTester.tap(find.text('TEST'));
      await widgetTester.pumpAndSettle();

      expect(find.byType(AddMeasurementDialoge), findsOneWidget);
      await widgetTester.tap(find.byIcon(Icons.close));
      await widgetTester.pumpAndSettle();
      expect(find.byType(AddMeasurementDialoge), findsNothing);

      expect(result, null);
    });
    testWidgets('should return values on cancel', (widgetTester) async {
      dynamic result = 'not null';
      final record = BloodPressureRecord(
          DateTime.now(), 123, 56, 43, 'Test note',
          needlePin: const MeasurementNeedlePin(Colors.teal)
      );
      await widgetTester.pumpWidget(_materialApp(
          Builder(
            builder: (BuildContext context) => TextButton(onPressed: () async {
              result = await showAddMeasurementDialoge(context, Settings(), record);
            }, child: const Text('TEST')),
          )));
      await widgetTester.tap(find.text('TEST'));
      await widgetTester.pumpAndSettle();

      expect(find.byType(AddMeasurementDialoge), findsOneWidget);
      await widgetTester.tap(find.text('SAVE'));
      await widgetTester.pumpAndSettle();
      expect(find.byType(AddMeasurementDialoge), findsNothing);

      expect(result, isA<BloodPressureRecord>().having(
              (p0) => (p0.creationTime, p0.systolic, p0.diastolic, p0.pulse, p0.notes, p0.needlePin!.color),
          'should return initial values as they were not modified',
          (record.creationTime, record.systolic, record.diastolic, record.pulse, record.notes, record.needlePin!.color)));
    });
    testWidgets('should be able to input values', (WidgetTester widgetTester) async {
      dynamic result = 'not null';
      await widgetTester.pumpWidget(_materialApp(
          Builder(
            builder: (BuildContext context) => TextButton(onPressed: () async {
              result = await showAddMeasurementDialoge(context, Settings());
            }, child: const Text('TEST')),
          )));
      await widgetTester.tap(find.text('TEST'));
      await widgetTester.pumpAndSettle();

      await widgetTester.enterText(find.ancestor(of: find.text('Systolic').first, matching: find.byType(TextFormField)), '123');
      await widgetTester.enterText(find.ancestor(of: find.text('Diastolic').first, matching: find.byType(TextFormField)), '67');
      await widgetTester.enterText(find.ancestor(of: find.text('Pulse').first, matching: find.byType(TextFormField)), '89');
      await widgetTester.enterText(find.ancestor(of: find.text('Note (optional)').first, matching: find.byType(TextFormField)), 'Test note');

      await widgetTester.tap(find.byType(ColorSelectionListTile));
      await widgetTester.pumpAndSettle();
      await widgetTester.tap(find.byElementPredicate(findColored(Colors.red)));
      await widgetTester.pumpAndSettle();

      expect(find.text('SAVE'), findsOneWidget);
      await widgetTester.tap(find.text('SAVE'));
      await widgetTester.pumpAndSettle();

      expect(result, isA<BloodPressureRecord>());
      BloodPressureRecord castResult = result;
      expect(castResult.systolic, 123);
      expect(castResult.diastolic, 67);
      expect(castResult.pulse, 89);
      expect(castResult.notes, 'Test note');
      expect(castResult.needlePin?.color, Colors.red);
    });
    testWidgets('should not allow invalid values', (widgetTester) async {
      await widgetTester.pumpWidget(_materialApp(Container()));
      late final BuildContext buildContext;

      await widgetTester.pumpWidget(_materialApp(
          Builder(
            builder: (BuildContext context) {
              buildContext = context;
              return TextButton(onPressed: () async {
                await showAddMeasurementDialoge(context, Settings());
              }, child: const Text('TEST'));
            },
          )));
      await widgetTester.tap(find.text('TEST'));
      await widgetTester.pumpAndSettle();
      final localizations = AppLocalizations.of(buildContext)!;

      expect(find.byType(AddMeasurementDialoge), findsOneWidget);
      expect(find.text(localizations.errNaN), findsNothing);
      expect(find.text(localizations.errLt30), findsNothing);
      expect(find.text(localizations.errUnrealistic), findsNothing);

      await widgetTester.enterText(find.ancestor(of: find.text('Systolic').first, matching: find.byType(TextFormField)), '123');
      await widgetTester.enterText(find.ancestor(of: find.text('Diastolic').first, matching: find.byType(TextFormField)), '67');

      await widgetTester.tap(find.text('SAVE'));
      await widgetTester.pumpAndSettle();
      expect(find.byType(AddMeasurementDialoge), findsOneWidget);
      expect(find.text(localizations.errNaN), findsOneWidget);

      await widgetTester.enterText(find.ancestor(of: find.text('Pulse').first, matching: find.byType(TextFormField)), '20');
      await widgetTester.tap(find.text('SAVE'));
      await widgetTester.pumpAndSettle();
      expect(find.byType(AddMeasurementDialoge), findsOneWidget);
      expect(find.text(localizations.errNaN), findsNothing);
      expect(find.text(localizations.errLt30), findsOneWidget);

      await widgetTester.enterText(find.ancestor(of: find.text('Pulse').first, matching: find.byType(TextFormField)), '60');
      await widgetTester.enterText(find.ancestor(of: find.text('Diastolic').first, matching: find.byType(TextFormField)), '500');
      await widgetTester.tap(find.text('SAVE'));
      await widgetTester.pumpAndSettle();
      expect(find.byType(AddMeasurementDialoge), findsOneWidget);
      expect(find.text(localizations.errNaN), findsNothing);
      expect(find.text(localizations.errLt30), findsNothing);
      expect(find.text(localizations.errUnrealistic), findsOneWidget);

      await widgetTester.enterText(find.ancestor(of: find.text('Diastolic').first, matching: find.byType(TextFormField)), '80');
      await widgetTester.tap(find.text('SAVE'));
      await widgetTester.pumpAndSettle();
      expect(find.byType(AddMeasurementDialoge), findsNothing);
      expect(find.text(localizations.errNaN), findsNothing);
      expect(find.text(localizations.errLt30), findsNothing);
      expect(find.text(localizations.errUnrealistic), findsNothing);
    });
    testWidgets('should allow invalid values when setting is set', (widgetTester) async {
      await widgetTester.pumpWidget(_materialApp(
          Builder(
            builder: (BuildContext context) => TextButton(onPressed: () async {
              await showAddMeasurementDialoge(context, Settings(validateInputs: false, allowMissingValues: true));
            }, child: const Text('TEST')),
          )));
      await widgetTester.tap(find.text('TEST'));
      await widgetTester.pumpAndSettle();

      await widgetTester.enterText(find.ancestor(of: find.text('Systolic').first, matching: find.byType(TextFormField)), '2');
      await widgetTester.enterText(find.ancestor(of: find.text('Diastolic').first, matching: find.byType(TextFormField)), '500');
      await widgetTester.tap(find.text('SAVE'));
      await widgetTester.pumpAndSettle();
      expect(find.byType(AddMeasurementDialoge), findsNothing);
    });
    testWidgets('should respect settings.allowManualTimeInput', (widgetTester) async {
      await widgetTester.pumpWidget(_materialApp(
          Builder(
            builder: (BuildContext context) => TextButton(onPressed: () async {
              await showAddMeasurementDialoge(context, Settings(validateInputs: false, allowMissingValues: true));
            }, child: const Text('TEST')),
          )));
      await widgetTester.tap(find.text('TEST'));
      await widgetTester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsNothing);
    });
  });
}

Widget _materialApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [AppLocalizations.delegate,],
    locale: const Locale('en'),
    home: Scaffold(body:child),
  );
}