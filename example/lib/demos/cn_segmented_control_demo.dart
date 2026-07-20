import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class SegmentedControl2DemoPage extends StatefulWidget {
  const SegmentedControl2DemoPage({super.key});

  @override
  State<SegmentedControl2DemoPage> createState() => _SegmentedControl2DemoPageState();
}

class _SegmentedControl2DemoPageState extends State<SegmentedControl2DemoPage> {
  int _disabledIndex = 1;
  int _labelsIndex = 0;
  int _shrinkIndex = 0;
  int _symbolsIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CNPageScaffold(
      navigationBar: const CNNavigationBar(middle: Text('Segmented Control 2')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            Row(
              children: [const Text('Labels'), const Spacer(), Text('Selected: $_labelsIndex')],
            ),
            const SizedBox(height: 12),
            CNSegmentedControl2(
              debugLog: true,
              labels: const ['One', 'Two', 'Three'],
              selectedIndex: _labelsIndex,
              onValueChanged: (i) => setState(() => _labelsIndex = i),
              shrink: false,
            ),

            const SizedBox(height: 48),

            Row(
              children: [const Text('Symbols'), const Spacer(), Text('Selected: $_symbolsIndex')],
            ),
            const SizedBox(height: 12),
            CNSegmentedControl2(
              symbols: const ['list.clipboard', 'leaf.arrow.trianglehead.clockwise', 'figure.walk.diamond'],
              selectedIndex: _symbolsIndex,
              onValueChanged: (i) => setState(() => _symbolsIndex = i),
              shrink: false,
            ),

            const SizedBox(height: 48),

            Row(
              children: [const Text('Disabled'), const Spacer(), Text('Selected: $_disabledIndex')],
            ),
            const SizedBox(height: 12),
            CNSegmentedControl2(
              labels: const ['Alpha', 'Beta', 'Gamma'],
              selectedIndex: _disabledIndex,
              enabled: false,
              onValueChanged: (i) => setState(() => _disabledIndex = i),
              shrink: false,
            ),

            const SizedBox(height: 48),

            Row(
              children: [const Text('Shrink'), const Spacer(), Text('Selected: $_shrinkIndex')],
            ),
            const SizedBox(height: 12),
            CNSegmentedControl2(
              labels: const ['Day', 'Week', 'Month'],
              selectedIndex: _shrinkIndex,
              onValueChanged: (i) => setState(() => _shrinkIndex = i),
              shrink: true,
            ),
          ],
        ),
      ),
    );
  }
}
