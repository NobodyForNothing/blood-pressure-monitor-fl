import 'package:blood_pressure_app/data_util/blood_pressure_builder.dart';
import 'package:blood_pressure_app/data_util/entry_context.dart';
import 'package:blood_pressure_app/data_util/repository_builder.dart';
import 'package:blood_pressure_app/features/measurement_list/compact_measurement_list.dart';
import 'package:blood_pressure_app/features/measurement_list/measurement_list.dart';
import 'package:blood_pressure_app/features/statistics/measurement_graph.dart';
import 'package:blood_pressure_app/model/storage/intervall_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:blood_pressure_app/screens/settings_screen.dart';
import 'package:blood_pressure_app/screens/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:provider/provider.dart';

/// Is true during the first [AppHome.build] before creating the widget.
bool _appStart = true;

/// Central screen of the app with graph and measurement list that is the center
/// of navigation.
class AppHome extends StatelessWidget {
  /// Create a home screen.
  const AppHome({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    // direct use of settings possible as no listening is required
    if (_appStart) {
      if (Provider.of<Settings>(context, listen: false).startWithAddMeasurementPage) {
        SchedulerBinding.instance.addPostFrameCallback((_) => context.createEntry());
      }
    }
    _appStart = false;

    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
        if (orientation == Orientation.landscape) {
          return MeasurementGraph(
            height: MediaQuery.of(context).size.height,
          );
        }
        return Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Consumer<IntervallStoreManager>(builder: (context, intervalls, child) =>
              Column(children: [
                /*MeasurementListRow(
                  settings: Settings(), data: (BloodPressureRecord(time: DateTime(2023),
                  sys:Pressure.mmHg(1), dia: Pressure.mmHg(2), pul: 3), Note(time: DateTime(2023), note: 'testTxt',), [])),*/
                const MeasurementGraph(),
                Expanded(
                  child: BloodPressureBuilder(
                    rangeType: IntervallStoreManagerLocation.mainPage,
                    onData: (context, records) => RepositoryBuilder<MedicineIntake, MedicineIntakeRepository>(
                      rangeType: IntervallStoreManagerLocation.mainPage,
                      onData: (BuildContext context, List<MedicineIntake> intakes) => RepositoryBuilder<Note, NoteRepository>(
                        rangeType: IntervallStoreManagerLocation.mainPage,
                        onData: (BuildContext context, List<Note> notes) {
                          final entries = FullEntryList.merged(records, notes, intakes);
                          entries.sort((a, b) => b.time.compareTo(a.time)); // newest first
                          if (context.select<Settings, bool>((s) => s.compactList)) {
                            return CompactMeasurementList(
                              data: entries,
                            );
                          }
                          return MeasurementList(
                            entries: entries,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],),),
            ),
        );
      },
      ),
      floatingActionButton: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.landscape && MediaQuery.of(context).size.height < 500) {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
            return const SizedBox.shrink();
          }
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
          return Consumer<Settings>(builder: (context, settings, child) => Column(
            verticalDirection: VerticalDirection.up,
            children: [
              SizedBox.square(
                dimension: 75,
                child: FittedBox(
                  child: FloatingActionButton(
                    heroTag: 'floatingActionAdd',
                    tooltip: localizations.addMeasurement,
                    autofocus: true,
                    onPressed: context.createEntry,
                    child: const Icon(Icons.add,),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              FloatingActionButton(
                heroTag: 'floatingActionStatistics',
                tooltip: localizations.statistics,
                backgroundColor: const Color(0xFF6F6F6F),
                onPressed: () {
                  _buildTransition(context, const StatisticsScreen(), settings.animationSpeed);
                },
                child: const Icon(Icons.insights, color: Colors.black),
              ),
              const SizedBox(
                height: 10,
              ),
              FloatingActionButton(
                heroTag: 'floatingActionSettings',
                tooltip: localizations.settings,
                backgroundColor: const Color(0xFF6F6F6F),
                child: const Icon(Icons.settings, color: Colors.black),
                onPressed: () {
                  _buildTransition(context, const SettingsPage(), settings.animationSpeed);
                },
              ),
            ],
          ),);
        },),
    );
  }
}

// TODO: consider removing duration override that only occurs in one on home.
void _buildTransition(BuildContext context, Widget page, int duration) {
  Navigator.push(context,
    _TimedMaterialPageRouter(
      transitionDuration: Duration(milliseconds: duration),
      builder: (context) => page,
    ),
  );
}

class _TimedMaterialPageRouter extends MaterialPageRoute {
  _TimedMaterialPageRouter({
    required super.builder,
    required this.transitionDuration,});

  @override
  final Duration transitionDuration;
}