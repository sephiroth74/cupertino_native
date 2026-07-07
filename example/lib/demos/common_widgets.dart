import 'package:cupertino_native/components/view_modifiers.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:flutter/cupertino.dart';

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
          border: Border.all(color: CNTheme.of(context).separatorColor, width: 1),
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
                        child: entry.value),
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
      modifiers: CNViewModifiers(enabled: enabled),
      selectedIndex: currentValue == null ? 0 : colors.values.toList().indexOf(currentValue!),
      onValueChanged: enabled ? (index) => onValueChanged(index) : null,
      items: colors.keys.map((colorName) {
        return CNLabel(
          CNText(colorName),
          icon: CNImage(
            systemSymbolName: 'circle.fill',
            modifiers: CNViewModifiers(tint: kSystemColors[colorName]),
          ),
        );
        // return CNText(colorName);
      }).toList(),
      pickerStyle: CNPickerStyle.menu,
    );
  }
}
