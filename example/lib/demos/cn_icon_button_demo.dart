import 'dart:math';

import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:cupertino_native_example/demos/icon_catalog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

const _kCountMax = 500.0;
const _kCountMin = 25.0;
const _kCountStep = 25.0;

class IconButtonDemoPage extends StatefulWidget {
  const IconButtonDemoPage({super.key});

  @override
  State<IconButtonDemoPage> createState() => _IconButtonDemoPageState();
}

class _IconButtonDemoPageState extends State<IconButtonDemoPage> {
  Color? backgroundColor;
  Color? borderColor;
  double borderWidth = 0;
  Color? foregroundColor;
  double iconSizeRatio = 0.75;
  bool isEnabled = true;
  bool isSelected = false;
  String? lastCopied;
  double maxCount = 100;
  final Set<String> selectedNames = <String>{};
  CNIconButtonShape shape = CNIconButtonShape.roundedRectangle;
  double size = 48;
  IconSource source = IconSource.sfSymbol;

  /// The slice of the current family that is actually rendered.
  List<String> get visibleNames {
    final names = source.names;
    return names.sublist(0, min(maxCount.round(), names.length));
  }

  Widget _iconTile(String name) {
    final theme = CNTheme.of(context);
    final tileWidth = max(size + 32, 96.0);
    // SF Symbols travel as a name resolved natively; the Flutter families
    // travel as an IconData glyph. CNIconButton takes exactly one of the two.
    final isSymbol = source == IconSource.sfSymbol;

    return SizedBox(
      width: tileWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CNPixelPerfectContainer(
            child: CNIconButton(
              size: size,
              icon: isSymbol ? null : source.iconData(name),
              systemSymbolName: isSymbol ? name : null,
              isSelected: isSelected || selectedNames.contains(name),
              shape: shape,
              iconSizeRatio: iconSizeRatio > 0 ? iconSizeRatio : null,
              foregroundColor: foregroundColor,
              backgroundColor: backgroundColor,
              borderColor: borderColor,
              borderWidth: borderWidth,
              onTap: isEnabled ? () => _copyName(name) : null,
              onLongPress: isEnabled
                  ? () => setState(() {
                      if (!selectedNames.remove(name)) selectedNames.add(name);
                    })
                  : null,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: theme.typography.caption2,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _copyName(String name) {
    Clipboard.setData(ClipboardData(text: name));
    setState(() => lastCopied = name);
  }

  @override
  Widget build(BuildContext context) {
    final names = visibleNames;

    return CNContentArea(
      builder: (context, scrollController) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  clipBehavior: Clip.hardEdge,
                  alignment: WrapAlignment.start,
                  spacing: 16,
                  runSpacing: 16,
                  children: names.map(_iconTile).toList(),
                ),
              ),
            ),
            RightSideOptionContainer(
              options: {
                'Source': CNPicker(
                  selection: source.label,
                  onChanged: (value) => setState(() {
                    source = IconSource.values.firstWhere(
                      (s) => s.label == value,
                    );
                    selectedNames.clear();
                  }),
                  children: IconSource.values
                      .map((s) => CNChildText(s.label, tag: s.label))
                      .toList(),
                  pickerStyle: CNPickerStyle.automatic,
                ),
                'Showing': Text(
                  '${names.length} of ${source.length}',
                  style: const TextStyle(fontSize: 12),
                ),
                'Max Count': SizeSliderPicker(
                  min: _kCountMin,
                  max: _kCountMax,
                  step: _kCountStep,
                  value: maxCount,
                  onChanged: (value) => setState(() => maxCount = value),
                ),
                'Size': SizeSliderPicker(
                  min: 24,
                  max: 96,
                  value: size,
                  onChanged: (value) => setState(() => size = value),
                ),
                'Icon Ratio': SizeSliderPicker(
                  min: 0,
                  max: 100,
                  step: 5,
                  value: (iconSizeRatio * 100),
                  onChanged: (value) =>
                      setState(() => iconSizeRatio = value / 100.0),
                ),
                'Border Width': SizeSliderPicker(
                  min: 0,
                  max: 6,
                  value: borderWidth,
                  onChanged: (value) => setState(() => borderWidth = value),
                ),
                'Shape': CNPicker(
                  selection: shape.name,
                  onChanged: (value) => setState(
                    () => shape = CNIconButtonShape.values.firstWhere(
                      (s) => s.name == value,
                    ),
                  ),
                  children: CNIconButtonShape.values
                      .map((s) => CNChildText(s.name, tag: s.name))
                      .toList(),
                ),
                'Foreground': ColorPicker(
                  colors: kSystemColors,
                  value: foregroundColor,
                  onChanged: (color) => setState(() => foregroundColor = color),
                ),
                'Background': ColorPicker(
                  colors: kSystemColors,
                  value: backgroundColor,
                  onChanged: (color) => setState(() => backgroundColor = color),
                ),
                'Border Color': ColorPicker(
                  colors: kSystemColors,
                  value: borderColor,
                  onChanged: (color) => setState(() => borderColor = color),
                ),
                'Selected': CNToggle(
                  isOn: isSelected,
                  onChanged: (v) => setState(() => isSelected = v),
                ),
                'Enabled': CNToggle(
                  isOn: isEnabled,
                  onChanged: (v) => setState(() => isEnabled = v),
                ),
                'Copied': Text(
                  lastCopied ?? 'tap to copy · long-press to select',
                  style: CNTheme.of(context).typography.caption2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              },
            ),
          ],
        );
      },
    );
  }
}
