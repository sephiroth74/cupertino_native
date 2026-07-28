import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:flutter/cupertino.dart';

class DatePickerDemoPage extends StatefulWidget {
  const DatePickerDemoPage({super.key});

  @override
  State<DatePickerDemoPage> createState() => _DatePickerDemoPageState();
}

enum _DatePickerComponents { date, time, dateAndTime }

class _DatePickerDemoPageState extends State<DatePickerDemoPage> {
  CNControlSize controlSize = CNControlSize.regular;
  CNDatePickerStyle datePickerStyle = CNDatePickerStyle.automatic;
  List<CNDatePickerComponent> displayedComponents = [CNDatePickerComponent.date, CNDatePickerComponent.hourAndMinute];
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
                child: CNDatePicker(
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
                'DatePicker Style': CNPicker(
                  selection: datePickerStyle.name,
                  onChanged: (newStyle) =>
                      setState(() => datePickerStyle = CNDatePickerStyle.values.firstWhere((style) => style.name == newStyle)),
                  children: CNDatePickerStyle.values.map((style) => CNChildText(style.name, tag: style.name)).toList(),
                ),
                'Enabled': CNToggle(isOn: enabled, onChanged: (value) => setState(() => enabled = value)),
                'Components': CNPicker(
                  selection: displayedComponentsEnum.name,
                  onChanged: (newValue) => setState(() {
                    displayedComponentsEnum = _DatePickerComponents.values.firstWhere((component) => component.name == newValue);
                    switch (displayedComponentsEnum) {
                      case _DatePickerComponents.date:
                        displayedComponents = [CNDatePickerComponent.date];
                        break;
                      case _DatePickerComponents.time:
                        displayedComponents = [CNDatePickerComponent.hourAndMinute];
                        break;
                      case _DatePickerComponents.dateAndTime:
                        displayedComponents = [CNDatePickerComponent.date, CNDatePickerComponent.hourAndMinute];
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
