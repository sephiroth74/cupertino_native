import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class TabViewDemoPage extends StatelessWidget {
  const TabViewDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Tab View Demo')),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CNTabView(
            controlSize: CNControlSize.regular,
            controller: CNTabController(selectedIndex: 0),
            enabled: true,
            children: [
              CNTab(CNPickerItem.text('Option 1'), child: Center(child: Text('Content for Tab 1'))),
              CNTab(CNPickerItem.text('Option 2'), child: Center(child: Text('Content for Tab 2'))),
              CNTab(CNPickerItem.text('Option 3'), child: Center(child: Text('Content for Tab 3'))),
              CNTab(CNPickerItem.text('Option 4'), child: Center(child: Text('Content for Tab 4'))),
            ],
          ),
        ),
      ),
    );
  }
}
