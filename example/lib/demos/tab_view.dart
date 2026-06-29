import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class TabViewDemoPage extends StatelessWidget {
  const TabViewDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Tab View Demo'),
      ),
      child: SafeArea(
        child: CNTabView(),
      ),
    );
  }
}