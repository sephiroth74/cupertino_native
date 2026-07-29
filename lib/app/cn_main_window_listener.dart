import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:macos_window_utils/macos/ns_window_delegate.dart';
import 'package:macos_window_utils/ns_window_delegate_handler/ns_window_delegate_handler.dart';
import 'package:macos_window_utils/window_manipulator.dart';

// ignore: public_member_api_docs
typedef MainWindowWidgetBuilder = Widget Function(BuildContext context, bool isMainWindow);

/// A widget that listens to the main window state and rebuilds when it changes.
class MainWindowStreamBuilder extends StatefulWidget {
  /// Creates a [MainWindowStreamBuilder].
  const MainWindowStreamBuilder({super.key, required this.builder});

  /// The builder function that is called when the main window state changes.
  final MainWindowWidgetBuilder builder;

  @override
  State<MainWindowStreamBuilder> createState() => _MainWindowStreamBuilderState();
}

class _MainWindowStreamBuilderState extends State<MainWindowStreamBuilder> {
  NSWindowDelegateHandle? handle;
  bool isMainWindow = true;

  @override
  void dispose() {
    super.dispose();
    handle?.removeFromHandler();
    handle = null;
  }

  @override
  void initState() {
    super.initState();
    handle = WindowManipulator.addNSWindowDelegate(
      _MainWindowStateListenerNSWindowDelegate(onMainWindowChanged: _onMainWindowChanged),
    );

    Future.microtask(() async {
      await _initIsWindowMain(isMainWindow);
    });
  }

  Future<void> _initIsWindowMain(bool oldIsMainWindow) async {
    isMainWindow = await WindowManipulator.isMainWindow();
    if (mounted && isMainWindow != oldIsMainWindow) {
      setState(() {});
    }
  }

  void _onMainWindowChanged(bool isMainWindow) {
    setState(() {
      this.isMainWindow = isMainWindow;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, isMainWindow);
  }
}

class _MainWindowStateListenerNSWindowDelegate extends NSWindowDelegate {
  _MainWindowStateListenerNSWindowDelegate({required this.onMainWindowChanged});

  final Function(bool isMainWindow)? onMainWindowChanged;

  @override
  void windowDidBecomeMain() {
    super.windowDidBecomeMain();
    debugPrint('MainWindowStreamBuilder: windowDidBecomeMain');
    onMainWindowChanged?.call(true);
  }

  @override
  void windowDidResignMain() {
    super.windowDidResignMain();
    debugPrint('MainWindowStreamBuilder: windowDidResignMain');
    onMainWindowChanged?.call(false);
  }
}
