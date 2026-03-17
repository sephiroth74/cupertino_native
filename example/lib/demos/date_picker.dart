import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';

class DatePickerDemoPage extends StatefulWidget {
  const DatePickerDemoPage({super.key});

  @override
  State<DatePickerDemoPage> createState() => _DatePickerDemoPageState();
}

class _DatePickerDemoPageState extends State<DatePickerDemoPage> {
  DateTime selectedDate = DateTime.now();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Date Picker Demo'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                constraints: BoxConstraints.expand(
                  width: double.infinity,
                  height: 200,
                ),
                child: CNDatePicker(
                  width: 300,
                  datePickerMode: CNDatePickerMode.range,
                  datePickerStyle: CNDatePickerStyle.clockAndCalendar,
                  datePickerElements: [CNDatePickerElements.yearMonthDay, CNDatePickerElements.hourMinute],
                  isBordered: true,
                  dateValue: selectedDate,
                  minDate: DateTime(2020, 1, 1),
                  maxDate: DateTime(2030, 12, 31),
                  locale: const Locale('en', 'US'),
                  font: CNFont.system(
                    CNFontSize.preset(CNFontSizePreset.system),
                    weight: CNFontWeight.bold,
                  ),
                  onDateChanged: (date, interval) {
                    debugPrint('Selected date: $date, interval: $interval');
                    setState(() {
                      selectedDate = date;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
