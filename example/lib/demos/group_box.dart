import 'package:cupertino_native/cupertino_native.dart';

import 'package:flutter/cupertino.dart';

class GroupBoxDemoPage extends StatelessWidget {
  const GroupBoxDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('GroupBox Demo')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('GroupBox with title and content'),
            const SizedBox(height: 8),
            GroupBox(
              label: const Text('GroupBox Title', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 8),
                  Text('This is the content of the GroupBox.'),
                  Text('You can add more widgets here.'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('GroupBox with only content'),
            const SizedBox(height: 8),
            GroupBox(
              style: GroupBoxStyle.border,
              label: CNLabel(text: 'Optional Title', icon: CNSymbol('paperclip'), font: const CNFont.label(CNFontSize.points(20))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [SizedBox(height: 8), Text('This GroupBox has no title.'), Text('It only contains content.')],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
