import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

class PathControlDemoPage extends StatefulWidget {
  const PathControlDemoPage({super.key});

  @override
  State<PathControlDemoPage> createState() => _PathControlDemoPageState();
}

class _PathControlDemoPageState extends State<PathControlDemoPage> {
  String path = "/Users/alessandro/Documents";

  @override
  Widget build(BuildContext context) {
    bool isDirectory =
        FileSystemEntity.typeSync(path) == FileSystemEntityType.directory;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Path Control')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // CNPathControl(
            //   controlStyle: CNPathControlStyle.standard,
            //   controlSize: CNControlSize.large,
            //   url: Uri.parse(path),
            //   isDirectory: isDirectory,
            //   onPressed: (url) {
            //     print(url);
            //     setState(() {
            //       path = url;
            //     });
            //   },
            // ),
            const SizedBox(height: 12),
            CNPathControl(
              controlStyle: CNPathControlStyle.popup,
              controlSize: CNControlSize.large,
              url: Uri.parse(path),
              isDirectory: isDirectory,
              allowedTypes: ['txt', 'stl'],
              onPressed: (url) {
                print(url);
                setState(() {
                  path = url;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
