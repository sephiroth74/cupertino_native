import 'package:cupertino_native/components/view_modifiers.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class ColorPicker extends StatelessWidget {
  const ColorPicker({
    super.key,
    required this.colors,
    required this.currentValue,
    required this.onValueChanged,
    this.enabled = true,
  });

  final Map<String, Color?> colors;
  final Color? currentValue;
  final bool enabled;
  final ValueChanged<int> onValueChanged;

  @override
  Widget build(BuildContext context) {
    return CNPicker(
      modifiers: CNViewModifiers(enabled: enabled, constraints: BoxConstraints.tightFor(width: 150), shrinkWrap: false),
      selectedIndex: currentValue == null ? 0 : colors.values.toList().indexOf(currentValue!),
      onValueChanged: enabled ? (index) => onValueChanged(index) : null,
      items: colors.keys.map((colorName) {
        return CNLabel(
          CNText(colorName),
          icon: CNImage(
            systemSymbolName: 'circle.fill',
            modifiers: CNViewModifiers(tint: colors[colorName]),
          ),
        );
        // return CNText(colorName);
      }).toList(),
      pickerStyle: CNPickerStyle.menu,
    );
  }
}

class FontPicker extends StatelessWidget {
  const FontPicker({super.key, required this.fonts, this.value, this.onChanged});

  final List<CNFont?> fonts;
  final ValueChanged<CNFont?>? onChanged;
  final CNFont? value;

  bool get enabled => onChanged != null;

  @override
  Widget build(BuildContext context) {
    return CNPicker(
      selectedIndex: fonts.indexWhere((font) {
        // first check if the font name matches, otherwise check if the font kind matches
        if (font == null && value == null) return true;
        if (font == null || value == null) return false;
        return font.name == value!.name || font.kind == value!.kind;
      }),
      onValueChanged: enabled ? (index) => onChanged!(fonts[index]) : null,
      items: fonts.map((font) => CNText(font != null ? (font.name ?? font.kind.name) : 'None')).toList(),
      pickerStyle: CNPickerStyle.automatic,
    );
  }
}

class ControlSizePicker extends StatelessWidget {
  const ControlSizePicker({super.key, required this.value, required this.onChanged});

  final ValueChanged<CNControlSize> onChanged;
  final CNControlSize value;

  @override
  Widget build(BuildContext context) {
    return CNPicker(
      selectedIndex: CNControlSize.values.indexOf(value),
      onValueChanged: (index) => onChanged(CNControlSize.values[index]),
      items: CNControlSize.values.map((size) => CNText(size.name)).toList(),
      pickerStyle: CNPickerStyle.automatic,
    );
  }
}

class RightSideOptionContainer extends StatelessWidget {
  const RightSideOptionContainer({super.key, this.title = 'Options', required this.options});

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
                child: Text(title!, style: CNTheme.of(context).typography.title1),
              ),
            if (options.isNotEmpty) ...[
              const SizedBox(height: 16),
              for (var entry in options.entries)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(child: Text(entry.key)),
                      SizedBox(
                        width: 175,
                        child: Align(alignment: Alignment.centerLeft, child: entry.value),
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
