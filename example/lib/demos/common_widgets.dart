import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:flutter/cupertino.dart';

class BezelStylePicker extends StatelessWidget {
  const BezelStylePicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ValueChanged<CNTextFieldBezelStyle> onChanged;
  final CNTextFieldBezelStyle value;

  @override
  Widget build(BuildContext context) {
    return CNPicker(
      selection: value.name,
      children: CNTextFieldBezelStyle.values
          .map((style) => CNChildText(style.name, tag: style.name))
          .toList(),
      onChanged: (value) => onChanged(
        CNTextFieldBezelStyle.values.firstWhere((e) => e.name == value),
      ),
      pickerStyle: CNPickerStyle.automatic,
    );
  }
}

class ColorPicker<T extends Color> extends StatelessWidget {
  const ColorPicker({
    super.key,
    required this.colors,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final Map<String, T?> colors;
  final bool enabled;
  final ValueChanged<T?> onChanged;
  final T? value;

  @override
  Widget build(BuildContext context) {
    return CNPicker(
      selection: value == null
          ? colors.keys.first.toString()
          : colors.entries.firstWhere((entry) => entry.value == value).key,
      children: colors.entries.map((entry) {
        return CNChildLabel(
          entry.key,
          systemImage: 'circle.fill',
          tint: entry.value,
          symbolRenderingMode: CNSymbolRenderingMode.monochrome,
          tag: entry.key,
        );
      }).toList(),
      onChanged: enabled ? (tag) => onChanged(colors[tag]) : null,
      pickerStyle: CNPickerStyle.menu,
    );
  }
}

class ControlSizePicker extends StatelessWidget {
  const ControlSizePicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ValueChanged<CNControlSize> onChanged;
  final CNControlSize value;

  @override
  Widget build(BuildContext context) {
    return CNPicker(
      selection: value.name,
      children: CNControlSize.values
          .map((size) => CNChildText(size.name, tag: size.name))
          .toList(),
      onChanged: (value) =>
          onChanged(CNControlSize.values.firstWhere((e) => e.name == value)),
      pickerStyle: CNPickerStyle.automatic,
    );
  }
}

class FontPicker extends StatelessWidget {
  const FontPicker({
    super.key,
    required this.fonts,
    this.value,
    this.onChanged,
    this.debugLog = false,
  });

  final bool debugLog;
  final List<CNFont?> fonts;
  final ValueChanged<CNFont?>? onChanged;
  final CNFont? value;

  bool get enabled => onChanged != null;

  @override
  Widget build(BuildContext context) {
    return CNPicker(
      debugLog: debugLog,
      selection: value?.name ?? value?.kind.name ?? 'none',
      children: fonts.map((font) {
        return CNChildText(
          font?.name ?? font?.kind.name ?? 'None',
          tag: font?.name ?? font?.kind.name ?? 'none',
        );
      }).toList(),
      onChanged: enabled
          ? (tag) => onChanged!(
              fonts.firstWhere(
                (font) => (font?.name ?? font?.kind.name ?? 'none') == tag,
              ),
            )
          : null,
      pickerStyle: CNPickerStyle.automatic,
    );
  }
}

class RightSideOptionContainer extends StatelessWidget {
  const RightSideOptionContainer({
    super.key,
    this.title = 'Options',
    required this.options,
  });

  final Map<String, Widget> options;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 350,
        decoration: BoxDecoration(
          color: CNTheme.of(context).fillPrimaryColor,
          // border: Border.all(color: CNTheme.of(context).separatorColor, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  title!,
                  style: CNTheme.of(context).typography.title2,
                ),
              ),
            if (options.isNotEmpty) ...[
              const SizedBox(height: 16),
              for (var entry in options.entries)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(entry.key, style: TextStyle(fontSize: 12)),
                      ),
                      SizedBox(
                        width: 175,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: entry.value,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class SizeSliderPicker extends StatelessWidget {
  const SizeSliderPicker({
    super.key,
    required this.value,
    this.min = kFontSizeMin,
    this.max = kFontSizeMax,
    required this.onChanged,
    this.debugLog = false,
    this.step,
  });

  final bool debugLog;
  final double max;
  final double min;
  final ValueChanged<double>? onChanged;
  final double? step;
  final double value;

  bool get enabled => onChanged != null;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          width: 40,
          child: Text(
            value.toStringAsFixed(0).padRight(2),
            style: TextStyle(
              color: enabled ? null : CupertinoColors.inactiveGray,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 2),
        Expanded(
          child: CNSlider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
            debugLog: debugLog,
            step: step,
          ),
        ),
      ],
    );
  }
}
