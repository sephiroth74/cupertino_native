import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:flutter/cupertino.dart';

const _kDebugLog = true;

class SegmentedControlDemoPage extends StatefulWidget {
  const SegmentedControlDemoPage({super.key});

  @override
  State<SegmentedControlDemoPage> createState() => _SegmentedControlDemoPageState();
}

class _SegmentedControlDemoPageState extends State<SegmentedControlDemoPage> {
  CNControlSize controlSize = CNControlSize.regular;
  CNSegmentDistribution distribution = CNSegmentDistribution.fit;
  bool isEnabled = true;
  CNSegmentStyle segmentStyle = CNSegmentStyle.automatic;
  int selectedIndex = 0;
  Set<int> selectedIndices = {0};
  Color? tint;
  CNSegmentTrackingMode trackingMode = CNSegmentTrackingMode.selectOne;

  @override
  Widget build(BuildContext context) {
    return CNPageScaffold(
      navigationBar: const CNNavigationBar(middle: Text('SegmentedControl (AppKit)')),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return CNSegmentedControl(
                            debugLog: _kDebugLog,
                            tint: tint,
                            segments: const [
                              CNSegment(label: 'Day', systemImage: 'sun.max'),
                              CNSegment(label: 'Week', systemImage: 'calendar'),
                              CNSegment(label: 'Month', systemImage: 'calendar.badge.clock'),
                              CNSegment(label: 'Year', systemImage: 'chart.bar'),
                            ],
                            selectedIndex: selectedIndex,
                            selectedIndices: selectedIndices,
                            segmentStyle: segmentStyle,
                            trackingMode: trackingMode,
                            segmentDistribution: distribution,
                            controlSize: controlSize,
                            constraints: distribution != CNSegmentDistribution.fit
                                ? BoxConstraints.expand(width: constraints.maxWidth)
                                : null,
                            onChanged: isEnabled ? (index) {
                              setState(() {
                                debugPrint('Segment selected: $index');
                                selectedIndex = index;
                              });
                            } : null,
                            onSelectAnyChanged: isEnabled ? (indices) {
                              setState(() {
                                debugPrint('Segments selected: $indices');
                                selectedIndices = indices;
                              });
                            } : null,
                          );
                        }
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      trackingMode == CNSegmentTrackingMode.selectAny
                          ? 'Selected indices: $selectedIndices'
                          : 'Selected index: $selectedIndex',
                      style: CNTheme.of(context).typography.body,
                    ),
                  ),
                ],
              ),
            ),
            RightSideOptionContainer(
              options: {
                'Tint': ColorPicker(
                  colors: kSystemColors,
                  value: tint,
                  onChanged: (color) => setState(() => tint = color),
                ),
                'Control Size': ControlSizePicker(
                  value: controlSize,
                  onChanged: (size) => setState(() => controlSize = size),
                ),
                'Style': CNPicker(
                  pickerStyle: CNPickerStyle.menu,
                  children: CNSegmentStyle.values.map((s) => CNChildText(s.name, tag: s.name)).toList(),
                  selection: segmentStyle.name,
                  onChanged: (value) {
                    setState(() {
                      segmentStyle = CNSegmentStyle.values.firstWhere((e) => e.name == value);
                    });
                  },
                ),
                'Tracking Mode': CNPicker(
                  pickerStyle: CNPickerStyle.menu,
                  children: CNSegmentTrackingMode.values.map((m) => CNChildText(m.name, tag: m.name)).toList(),
                  selection: trackingMode.name,
                  onChanged: (value) {
                    setState(() {
                      trackingMode = CNSegmentTrackingMode.values.firstWhere((e) => e.name == value);
                    });
                  },
                ),
                'Distribution': CNPicker(
                  pickerStyle: CNPickerStyle.menu,
                  children: CNSegmentDistribution.values.map((d) => CNChildText(d.name, tag: d.name)).toList(),
                  selection: distribution.name,
                  onChanged: (value) {
                    setState(() {
                      distribution = CNSegmentDistribution.values.firstWhere((e) => e.name == value);
                    });
                  },
                ),
                'Enabled': CNToggle(isOn: isEnabled, onChanged: (value) => setState(() => isEnabled = value)),
              },
            ),
          ],
        ),
      ),
    );
  }
}
