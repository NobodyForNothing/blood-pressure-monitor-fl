/// Widgets related to organizing input fields in list like structures.
///
/// While any list or column can host the list tile widgets that are part of this library, [TitledColumn] can be used to
/// further structure settings lists.
///
/// List tiles from flutter and this library currently used by the app are:
/// - [ListTile]
/// - [SwitchListTile]
/// - [ColorSelectionListTile]
/// - [DropDownListTile]
/// - [SliderListTile]
/// - [InputListTile]
/// - [NumberInputListTile]
///
/// List tiles that find no use in the app:
/// - [CheckboxListTile]
/// - [RadioListTile]
library settings_widgets;

import 'package:blood_pressure_app/components/settings/settings_widgets.dart';
import 'package:flutter/material.dart';

export 'color_picker_list_tile.dart';
export 'dropdown_list_tile.dart';
export 'input_list_tile.dart';
export 'number_input_list_tile.dart';
export 'slider_list_tile.dart';
export 'titled_column.dart';
