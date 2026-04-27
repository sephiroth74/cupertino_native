import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class SplitViewDemoPage extends StatefulWidget {
  const SplitViewDemoPage({super.key});

  @override
  State<SplitViewDemoPage> createState() => _SplitViewDemoPageState();
}

class _SplitViewDemoPageState extends State<SplitViewDemoPage> {
  final CNSplitViewController _controller = CNSplitViewController();
  final TextEditingController _nativeTextController = TextEditingController(
    text: 'Native NSTextView embedded in Split View',
  );

  CNSplitAxis _axis = CNSplitAxis.horizontal;
  bool _snapEnabled = true;
  bool _showNativeTextView = true;
  bool _enableMacOSDividerEffects = true;
  double _previewScale = 0.35;
  String _metricsText = 'No metrics yet';

  @override
  void dispose() {
    _controller.dispose();
    _nativeTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paneBackground = CupertinoDynamicColor.resolve(
      CupertinoColors.systemGrey6,
      context,
    );

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Split View')),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CupertinoSlidingSegmentedControl<CNSplitAxis>(
                    groupValue: _axis,
                    children: const {
                      CNSplitAxis.horizontal: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('Horizontal'),
                      ),
                      CNSplitAxis.vertical: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('Vertical'),
                      ),
                    },
                    onValueChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _axis = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Snap'),
                      const SizedBox(width: 8),
                      CupertinoSwitch(
                        value: _snapEnabled,
                        onChanged: (value) {
                          setState(() {
                            _snapEnabled = value;
                          });
                        },
                      ),
                      const Spacer(),
                      Text(
                        _metricsText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Native TextView'),
                      const SizedBox(width: 8),
                      CupertinoSwitch(
                        value: _showNativeTextView,
                        onChanged: (value) {
                          setState(() {
                            _showNativeTextView = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('macOS Divider Effects'),
                      const SizedBox(width: 8),
                      CupertinoSwitch(
                        value: _enableMacOSDividerEffects,
                        onChanged: (value) {
                          setState(() {
                            _enableMacOSDividerEffects = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      CNButton(
                        label: '30 / 70',
                        onPressed: () => _controller.setFraction(0.3),
                        style: CNButtonStyle.filled,
                      ),
                      CNButton(
                        label: '50 / 50',
                        onPressed: () => _controller.setFraction(0.5),
                        style: CNButtonStyle.filled,
                      ),
                      CNButton(
                        label: 'Collapse First',
                        onPressed: _controller.collapseFirst,
                        style: CNButtonStyle.gray,
                      ),
                      CNButton(
                        label: 'Collapse Second',
                        onPressed: _controller.collapseSecond,
                        style: CNButtonStyle.gray,
                      ),
                      CNButton(
                        label: 'Expand Both',
                        onPressed: () {
                          _controller.expandFirst();
                          _controller.expandSecond();
                        },
                        style: CNButtonStyle.gray,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tip: double-click divider to reset. Keyboard: Alt+Arrow to resize, Alt+1/Alt+2 to toggle panes.',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: paneBackground,
                padding: const EdgeInsets.all(12),
                child: CNSplitView(
                  axis: _axis,
                  controller: _controller,
                  initialFraction: 0.35,
                  minFraction: 0.2,
                  maxFraction: 0.8,
                  snapFractions: _snapEnabled
                      ? const <double>[0.25, 0.5, 0.75]
                      : const <double>[],
                  snapThreshold: 0.04,
                  snapReleaseThreshold: 0.065,
                  dividerInteractiveThickness: 18,
                  dividerDoubleTapAction: CNSplitDividerDoubleTapAction.reset,
                  dividerSemanticLabel: 'Demo split view divider',
                  macOSDividerStyle: CNSplitMacOSDividerStyle.grabber,
                  enableMacOSDividerVisualEffects: _enableMacOSDividerEffects,
                  first: CNSplitPane(
                    minExtent: 140,
                    child: _PaneCard(
                      title: 'Sidebar Pane',
                      subtitle: 'Scrollable + interactive controls',
                      child: ListView.builder(
                        itemCount: 30,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text('Item ${index + 1}'),
                        ),
                      ),
                    ),
                  ),
                  second: CNSplitPane(
                    minExtent: 200,
                    child: _PaneCard(
                      title: 'Content Pane',
                      subtitle: 'Forms, animation, and optional platform view',
                      child: ListView(
                        children: [
                          const Text('Gesture-heavy / mixed content test'),
                          const SizedBox(height: 10),
                          CupertinoTextField(
                            placeholder: 'Type here (Flutter text field)',
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Text('Preview scale'),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CupertinoSlider(
                                  min: 0.0,
                                  max: 1.0,
                                  value: _previewScale,
                                  onChanged: (value) {
                                    setState(() {
                                      _previewScale = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            height: 48 + (_previewScale * 80),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemBlue.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Animated preview ${(_previewScale * 100).round()}%',
                            ),
                          ),
                          if (_showNativeTextView) ...[
                            const SizedBox(height: 12),
                            CNTextView(
                              controller: _nativeTextController,
                              placeholder: 'Native NSTextView in split pane',
                              height: 120,
                              onChanged: (_) {},
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  onChanged: (metrics) {
                    setState(() {
                      _metricsText =
                          'f:${metrics.firstExtent.toStringAsFixed(0)} '
                          's:${metrics.secondExtent.toStringAsFixed(0)}';
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaneCard extends StatelessWidget {
  const _PaneCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final background = CupertinoDynamicColor.resolve(
      CupertinoColors.systemBackground,
      context,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = constraints.maxHeight;
          final compact = maxHeight < 88;
          final showSubtitle = maxHeight >= 58;
          final showBody = maxHeight >= 96;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: compact ? 15 : 17,
                  ),
                ),
                if (showSubtitle) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
                if (showBody) ...[
                  const SizedBox(height: 10),
                  Expanded(child: child),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
