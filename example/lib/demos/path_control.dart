import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

class PathControlDemoPage extends StatefulWidget {
  const PathControlDemoPage({super.key});

  @override
  State<PathControlDemoPage> createState() => _PathControlDemoPageState();
}

class _PathControlDemoPageState extends State<PathControlDemoPage> {
  final _memoizer = AsyncMemoizer<void>();

  String _pathControlPath = '/Users';
  bool _pathControlIsDirectory = true;

  Future<void> _fetchInitialDirectory() async {
    return _memoizer.runOnce(() async {
      _pathControlPath = (await getDownloadsDirectory())?.path ?? '/';
      _pathControlIsDirectory = true;
    });
  }

  void _handlePressed(String url) {
    setState(() {
      _pathControlPath = url;
      _pathControlIsDirectory = FileSystemEntity.typeSync(url) == FileSystemEntityType.directory;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Path Control')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Path control styles'),
            const SizedBox(height: 12),
            FutureBuilder<void>(
              future: _fetchInitialDirectory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const SizedBox(height: 48);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CNPathControl(
                      editable: true,
                      controlStyle: CNPathControlStyle.popup,
                      controlSize: CNControlSize.large,
                      url: Uri.parse(_pathControlPath),
                      isDirectory: _pathControlIsDirectory,
                      onPressed: _handlePressed,
                    ),
                    const SizedBox(height: 12),
                    CNPathControl(
                      controlStyle: CNPathControlStyle.standard,
                      controlSize: CNControlSize.large,
                      url: Uri.parse(_pathControlPath),
                      isDirectory: _pathControlIsDirectory,
                      onPressed: _handlePressed,
                    ),
                    const SizedBox(height: 16),
                    Text('Selected path: $_pathControlPath'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
