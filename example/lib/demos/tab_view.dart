import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class TabViewDemoPage extends StatelessWidget {
  const TabViewDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CNPageScaffold(
      navigationBar: const CNNavigationBar(middle: Text('Tab View Demo')),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CNTabView(
            controlSize: CNControlSize.regular,
            controller: CNTabController(selectedIndex: 0),
            enabled: true,
            children: [
              CNTab(CNText('Option 1'), child: Center(child: Text('Content for Tab 1'))),
              CNTab(CNText('Option 2'), child: Center(child: Text('Content for Tab 2'))),
              CNTab(CNText('Option 3'), child: Center(child: Text('Content for Tab 3'))),
              CNTab(CNText('Option 4'), child: Center(child: Text('Content for Tab 4'))),
            ],
          ),
        ),
      ),
    );
  }
}
