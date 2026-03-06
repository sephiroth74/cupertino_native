import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class LevelIndicatorDemoPage extends StatefulWidget {
  const LevelIndicatorDemoPage({super.key});

  @override
  State<LevelIndicatorDemoPage> createState() => _LevelIndicatorDemoPageState();
}

class _LevelIndicatorDemoPageState extends State<LevelIndicatorDemoPage> {
  // CNLevelIndicatorController controller = CNLevelIndicatorController(value: 3, minValue: 0, maxValue: 5);
  double _value = 5.0;
  double _minValue = 0.0;
  double _maxValue = 10.0;

  void _onLevelChange(double v) {
    setState(() {
      _value = v;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Level Indicators'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 1,
                  child: CNLevelIndicator(
                    levelIndicatorStyle:
                        CNLevelIndicatorStyle.continuousCapacity,
                    onChanged: _onLevelChange,
                    value: _value,
                    minValue: _minValue,
                    maxValue: _maxValue,
                    fillColor: CupertinoColors.systemGreen,
                    warningColor: CupertinoColors.systemYellow,
                    criticalColor: CupertinoColors.systemRed,
                    warningValue: 6.0,
                    criticalValue: 9.0,
                  ),
                ),
                const Spacer(flex: 1),
                SizedBox(
                  width: 150,
                  child: Builder(
                    builder: (context) => Text(
                      'Value: ${_value.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  flex: 1,
                  child: CNLevelIndicator(
                    value: _value,
                    minValue: _minValue,
                    maxValue: _maxValue,
                    levelIndicatorStyle: CNLevelIndicatorStyle.discreteCapacity,
                    onChanged: _onLevelChange,
                  ),
                ),
                const Spacer(flex: 1),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  flex: 1,
                  child: CNLevelIndicator(
                    value: _value,
                    minValue: _minValue,
                    maxValue: _maxValue,
                    levelIndicatorStyle: CNLevelIndicatorStyle.rating,
                    onChanged: _onLevelChange,
                  ),
                ),
                const Spacer(flex: 1),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  flex: 1,
                  child: CNLevelIndicator(
                    value: _value,
                    minValue: _minValue,
                    maxValue: _maxValue,
                    levelIndicatorStyle: CNLevelIndicatorStyle.relevancy,
                    onChanged: _onLevelChange,
                  ),
                ),
                const Spacer(flex: 1),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
