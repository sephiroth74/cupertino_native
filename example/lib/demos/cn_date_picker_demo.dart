import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:flutter/cupertino.dart';

enum _DatePickerComponents { date, time, dateAndTime }

class DatePickerDemoPage extends StatefulWidget {
  const DatePickerDemoPage({super.key});

  @override
  State<DatePickerDemoPage> createState() => _DatePickerDemoPageState();
}

class _DatePickerDemoPageState extends State<DatePickerDemoPage> {
  CNControlSize controlSize = CNControlSize.regular;
  CNDatePicker2Style datePickerStyle = CNDatePicker2Style.automatic;
  List<CNDatePicker2Component> displayedComponents = [CNDatePicker2Component.date, CNDatePicker2Component.hourAndMinute];
  _DatePickerComponents displayedComponentsEnum = _DatePickerComponents.dateAndTime;
  bool enabled = true;
  DateTime selectedDate = DateTime.now();
  CupertinoDynamicColor? tintColor;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CNPageScaffold(
      navigationBar: const CNNavigationBar(middle: Text('Date Picker Demo')),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: CNDatePicker2(
                  selection: selectedDate,
                  controlSize: controlSize,
                  datePickerStyle: datePickerStyle,
                  displayedComponents: displayedComponents,
                  minDate: DateTime.now().subtract(const Duration(days: 365)),
                  maxDate: DateTime.now().add(const Duration(days: 365)),
                  debugLog: false,
                  onChanged: enabled
                      ? (value) {
                          setState(() {
                            selectedDate = value;
                          });
                        }
                      : null,
                ),
              ),
            ),
            RightSideOptionContainer(
              title: 'Options',
              options: {
                'Control Size': ControlSizePicker(
                  value: controlSize,
                  onChanged: (newSize) => setState(() => controlSize = newSize),
                ),
                'DatePicker Style': CNPicker2(
                  selection: datePickerStyle.name,
                  onChanged: (newStyle) =>
                      setState(() => datePickerStyle = CNDatePicker2Style.values.firstWhere((style) => style.name == newStyle)),
                  children: CNDatePicker2Style.values.map((style) => CNChildText(style.name, tag: style.name)).toList(),
                ),
                'Enabled': CNToggle2(isOn: enabled, onChanged: (value) => setState(() => enabled = value)),
                'Components': CNPicker2(
                  selection: displayedComponentsEnum.name,
                  onChanged: (newValue) => setState(() {
                    displayedComponentsEnum = _DatePickerComponents.values.firstWhere((component) => component.name == newValue);
                    switch (displayedComponentsEnum) {
                      case _DatePickerComponents.date:
                        displayedComponents = [CNDatePicker2Component.date];
                        break;
                      case _DatePickerComponents.time:
                        displayedComponents = [CNDatePicker2Component.hourAndMinute];
                        break;
                      case _DatePickerComponents.dateAndTime:
                        displayedComponents = [CNDatePicker2Component.date, CNDatePicker2Component.hourAndMinute];
                        break;
                    }
                  }),
                  children: _DatePickerComponents.values
                      .map((component) => CNChildText(component.name, tag: component.name))
                      .toList(),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}
