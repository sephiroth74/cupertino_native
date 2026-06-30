import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

/// Controls the selected tab index of a [CNTabView].
class CNTabController extends ChangeNotifier {
  /// Creates a [CNTabController] with an optional initial selected index.
  CNTabController({int selectedIndex = 0}) : _selectedIndex = selectedIndex;

  int _selectedIndex;

  /// The index of the currently selected tab.
  int get selectedIndex => _selectedIndex;

  set selectedIndex(int value) {
    if (_selectedIndex == value) return;
    _selectedIndex = value;
    notifyListeners();
  }
}

/// Represents a single tab in a [CNTabView].
class CNTab {
  /// Creates a [CNTab] with a required [item] and [child].
  const CNTab(this.item, {required this.child});

  /// The widget displayed when this tab is selected.
  final Widget child;

  /// The picker item used as the tab label (text or icon).
  final CNPickerItem item;
}

/// A macOS-native-style tab view using [CNPicker] as a segmented control header.
///
/// Uses [CNTabController] to manage the selected tab and [CNTab] to define
/// individual tabs with labels and content.
class CNTabView extends StatefulWidget {
  /// Creates a [CNTabView] with a list of [children] tabs and an optional [controller].
  CNTabView({
    super.key,
    required this.children,
    CNTabController? controller,
    this.enabled = true,
    this.controlSize = CNControlSize.regular,
  }) : controller = controller ?? CNTabController();

  /// The list of tabs to display.
  final List<CNTab> children;

  /// Size of the segmented control.
  final CNControlSize controlSize;

  /// Controls which tab is selected.
  final CNTabController controller;

  /// Whether the tab selector is interactive.
  final bool enabled;

  @override
  State<CNTabView> createState() => _CNTabViewState();
}

class _CNTabViewState extends State<CNTabView> {
  late CNTabController _controller;
  final GlobalKey _pickerKey = GlobalKey();
  Size _pickerSize = Size.zero;

  @override
  void didUpdateWidget(covariant CNTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTabChanged);
      _controller = widget.controller;
      _controller.addListener(_onTabChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTabChanged);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measurePicker());
  }

  void _onTabChanged() {
    setState(() {});
  }

  void _measurePicker() {
    final box = _pickerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && mounted) {
      final size = box.size;
      if (size != _pickerSize) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() => _pickerSize = size);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickerItems = widget.children.map((t) => t.item).toList();
    final halfPickerHeight = _pickerSize.height / 2;
    final double borderRadius;

    switch (widget.controlSize) {
      case CNControlSize.mini:
        borderRadius = 2.0;
        break;

      case CNControlSize.small:
        borderRadius = 4.0;
        break;
      case CNControlSize.regular:
        borderRadius = 6.0;
        break;
      case CNControlSize.large:
      case CNControlSize.extraLarge:
        borderRadius = halfPickerHeight;
        break;
    }

    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (notification) {
        _measurePicker();
        return true;
      },
      child: Stack(
        fit: StackFit.loose,
        children: [
          // GroupBox content area — top padding reserves space for the picker
          Padding(
            padding: EdgeInsets.only(top: halfPickerHeight),
            child: GroupBox(
              padding: EdgeInsets.only(top: halfPickerHeight + 8, left: 16, right: 16, bottom: 16),
              borderDecoration: BoxDecoration(
                color: CNTheme.of(context).fillTertiaryColor,
                border: Border.all(color: CNTheme.of(context).separatorColor.withAlpha(25), width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IndexedStack(index: _controller.selectedIndex, children: widget.children.map((t) => t.child).toList()),
            ),
          ),

          // Opaque background that covers the GroupBox border under the picker.
          // Only rendered once the picker size is known.
          if (_pickerSize != Size.zero)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: _pickerSize.width,
                  height: _pickerSize.height,
                  decoration: BoxDecoration(
                    color: CNTheme.of(context).groupedBackgroundColor,
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
              ),
            ),

          // The segmented control picker
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              key: _pickerKey,
              child: SizeChangedLayoutNotifier(
                child: CNPicker(
                  items: pickerItems,
                  selectedIndex: _controller.selectedIndex,
                  pickerStyle: CNPickerStyle.segmented,
                  controlSize: widget.controlSize,
                  shrinkWrap: true,
                  enabled: widget.enabled,
                  onValueChanged: (index) {
                    _controller.selectedIndex = index;
                    _measurePicker();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
