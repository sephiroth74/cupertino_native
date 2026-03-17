import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';

class DatePickerDemoPage extends StatefulWidget {
  const DatePickerDemoPage({super.key});

  @override
  State<DatePickerDemoPage> createState() => _DatePickerDemoPageState();
}

class _DatePickerDemoPageState extends State<DatePickerDemoPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Date Picker Demo')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              width: 400,
              child: CNDatePicker(
                datePickerMode: CNDatePickerMode.range,
                datePickerStyle: CNDatePickerStyle.clockAndCalendar,
                datePickerElements: [CNDatePickerElements.yearMonthDay, CNDatePickerElements.hourMinuteSecond],
                isBordered: true,
                minDate: DateTime(2020, 1, 1),
                maxDate: DateTime(2030, 12, 31),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
