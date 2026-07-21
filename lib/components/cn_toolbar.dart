// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../channel/params.dart';
import 'cn_child.dart';

/// Placement of a toolbar item group.
enum CNToolbarPlacement {
  automatic,
  principal,
  navigation,
  status,
  primaryAction,
  secondaryAction,
  confirmationAction,
  destructiveAction,
  cancellationAction,
}

/// Title display mode for the toolbar.
enum CNToolbarTitleDisplayMode {
  automatic,
  inline,
  large,
}

/// A toolbar item group containing children.
class CNToolbarItemGroup {
  const CNToolbarItemGroup({
    required this.placement,
    required this.children,
    this.label,
  });

  /// The child views within this group.
  final List<CNChild> children;

  /// Optional label for the group.
  final CNChild? label;

  /// Where this group is placed in the toolbar.
  final CNToolbarPlacement placement;

  Map<String, dynamic> toPayload(BuildContext context) {
    return {
      'placement': placement.name,
      'children': children.map((c) => c.toChildPayload(context)).toList(),
      if (label != null) 'label': label!.toChildPayload(context),
    };
  }
}

/// Configuration for the native toolbar.
class CNToolbarConfig {
  const CNToolbarConfig({
    this.title,
    this.titleDisplayMode = CNToolbarTitleDisplayMode.automatic,
    this.groups = const [],
    this.searchable = false,
    this.toolbarBackground,
    this.onSearchChanged,
    this.onItemPressed,
  });

  /// The toolbar item groups.
  final List<CNToolbarItemGroup> groups;

  /// Callback when a toolbar button is pressed (identified by tag).
  final ValueChanged<String>? onItemPressed;

  /// Callback when search text changes.
  final ValueChanged<String>? onSearchChanged;

  /// Whether to show the search field.
  final bool searchable;

  /// Navigation title (rendered as a CNChild).
  final CNChild? title;

  /// Title display mode.
  final CNToolbarTitleDisplayMode titleDisplayMode;

  /// Background color for the toolbar (ARGB int).
  final Color? toolbarBackground;
}

/// A widget that configures the native macOS toolbar for the window.
///
/// Wrap your top-level content with [CNToolbar] to set up the toolbar.
/// Changes to the configuration are automatically synced to native.
class CNToolbar extends StatefulWidget {
  const CNToolbar({
    super.key,
    required this.config,
    required this.child,
  });

  /// The child widget (your app content).
  final Widget child;

  /// Toolbar configuration.
  final CNToolbarConfig config;

  @override
  State<CNToolbar> createState() => _CNToolbarState();
}

class _CNToolbarState extends State<CNToolbar> {
  static const MethodChannel _channel = MethodChannel('cupertino_native');

  @override
  void didUpdateWidget(covariant CNToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncToolbar();
  }

  @override
  void dispose() {
    _clearToolbar();
    _channel.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler(_handleNativeCall);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncToolbar());
  }

  Future<void> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'toolbarItemPressed':
        final tag = call.arguments as String?;
        if (tag != null) {
          widget.config.onItemPressed?.call(tag);
        }
      case 'toolbarSearchChanged':
        final text = call.arguments as String? ?? '';
        widget.config.onSearchChanged?.call(text);
    }
  }

  void _syncToolbar() {
    if (defaultTargetPlatform != TargetPlatform.macOS) return;

    final config = widget.config;
    _channel.invokeMethod<void>('makeToolbar', {
      if (config.title != null) 'title': config.title!.toChildPayload(context),
      'titleDisplayMode': config.titleDisplayMode.name,
      'searchable': config.searchable,
      'groups': config.groups.map((g) => g.toPayload(context)).toList(),
      if (config.toolbarBackground != null)
        'toolbarBackground': resolveColorToArgb(config.toolbarBackground, context),
    });
  }

  void _clearToolbar() {
    if (defaultTargetPlatform != TargetPlatform.macOS) return;
    _channel.invokeMethod<void>('clearToolbar');
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
