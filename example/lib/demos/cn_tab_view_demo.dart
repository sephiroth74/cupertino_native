import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:flutter/cupertino.dart';

class TabViewDemoPage extends StatefulWidget {
  const TabViewDemoPage({super.key});

  @override
  State<TabViewDemoPage> createState() => _TabViewDemoPageState();
}

class _TabViewDemoPageState extends State<TabViewDemoPage> {
  CNTabContentMode contentMode = CNTabContentMode.indexedStack;
  CNControlSize controlSize = CNControlSize.regular;
  CNSegmentDistribution distribution = CNSegmentDistribution.fit;
  bool isEnabled = true;
  CNSegmentStyle segmentStyle = CNSegmentStyle.automatic;
  CNTabPosition tabPosition = CNTabPosition.top;

  late final CNTabController _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = CNTabController(length: 4);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: CNColors.groupedBackgroundColor,
                  border: Border.all(color: CNTheme.of(context).separatorColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CNTabView(
                  controller: _controller,
                  tabs: const [
                    CNSegment(label: 'General', systemImage: 'gear'),
                    CNSegment(label: 'Appearance', systemImage: 'paintbrush'),
                    CNSegment(label: 'Privacy', systemImage: 'lock.shield'),
                    CNSegment(label: 'Advanced', systemImage: 'wrench.and.screwdriver'),
                  ],
                  tabPosition: tabPosition,
                  contentMode: contentMode,
                  segmentStyle: segmentStyle,
                  segmentDistribution: distribution,
                  controlSize: controlSize,
                  enabled: isEnabled,
                  tabPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  contentPadding: const EdgeInsets.all(16),
                  children: [
                    _TabContent(
                      title: 'General',
                      icon: CupertinoIcons.gear,
                      description: 'General application settings and preferences.',
                    ),
                    _TabContent(
                      title: 'Appearance',
                      icon: CupertinoIcons.paintbrush,
                      description: 'Customize the look and feel of the application.',
                    ),
                    _TabContent(
                      title: 'Privacy',
                      icon: CupertinoIcons.lock_shield,
                      description: 'Manage your privacy and security settings.',
                    ),
                    _TabContent(
                      title: 'Advanced',
                      icon: CupertinoIcons.wrench,
                      description: 'Advanced configuration options for power users.',
                    ),
                  ],
                ),
              ),
            ),
          ),
          RightSideOptionContainer(
            options: {
              'Tab Position': CNPicker(
                pickerStyle: CNPickerStyle.menu,
                children: CNTabPosition.values.map((p) => CNChildText(p.name, tag: p.name)).toList(),
                selection: tabPosition.name,
                onChanged: (value) {
                  setState(() {
                    tabPosition = CNTabPosition.values.firstWhere((e) => e.name == value);
                  });
                },
              ),
              'Content Mode': CNPicker(
                pickerStyle: CNPickerStyle.menu,
                children: CNTabContentMode.values.map((m) => CNChildText(m.name, tag: m.name)).toList(),
                selection: contentMode.name,
                onChanged: (value) {
                  setState(() {
                    contentMode = CNTabContentMode.values.firstWhere((e) => e.name == value);
                  });
                },
              ),
              'Control Size': ControlSizePicker(value: controlSize, onChanged: (size) => setState(() => controlSize = size)),
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
    );
  }
}

class _TabContent extends StatelessWidget {
  const _TabContent({required this.title, required this.icon, required this.description});

  final String description;
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: CNTheme.of(context).userAccentColor),
          const SizedBox(height: 16),
          Text(title, style: CNTheme.of(context).typography.title1),
          const SizedBox(height: 8),
          Text(description, style: CNTheme.of(context).typography.body),
          const SizedBox(height: 8),
          CNButton(
            onPressed: () {
              debugPrint('Button pressed in $title tab');
            },
            buttonStyle: CNButtonStyle.borderedProminent,
            children: const [CNChildText('Perform Action')],
          ),
        ],
      ),
    );
  }
}
