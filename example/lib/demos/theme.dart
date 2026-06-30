import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class ThemeDemoPage extends StatelessWidget {
  const ThemeDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = CNTheme.of(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('Theme Tokens', style: theme.typography.headline)),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              header: const Text('Typography'),
              children: [
                _StyleRow(label: 'Large Title', style: theme.typography.largeTitle),
                _StyleRow(label: 'Title 1', style: theme.typography.title1),
                _StyleRow(label: 'Title 2', style: theme.typography.title2),
                _StyleRow(label: 'Title 3', style: theme.typography.title3),
                _StyleRow(label: 'Headline', style: theme.typography.headline),
                _StyleRow(label: 'Body', style: theme.typography.body),
                _StyleRow(label: 'Callout', style: theme.typography.callout),
                _StyleRow(label: 'Subheadline', style: theme.typography.subheadline),
                _StyleRow(label: 'Footnote', style: theme.typography.footnote),
                _StyleRow(label: 'Caption 1', style: theme.typography.caption1),
                _StyleRow(label: 'Caption 2', style: theme.typography.caption2),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: const Text('Semantic Colors'),
              children: [
                _ColorRow(label: 'Primary', color: theme.primaryColor),
                _ColorRow(label: 'Secondary', color: theme.secondaryColor),
                _ColorRow(label: 'Destructive', color: theme.destructiveColor),
                _ColorRow(label: 'Canvas', color: theme.canvasColor),
                _ColorRow(label: 'Grouped Background', color: theme.groupedBackgroundColor),
                _ColorRow(label: 'Label', color: theme.labelColor),
                _ColorRow(label: 'Secondary Label', color: theme.secondaryLabelColor),
                _ColorRow(label: 'Separator', color: theme.separatorColor),
                _ColorRow(label: 'Fill Primary', color: theme.fillPrimaryColor),
                _ColorRow(label: 'Fill Secondary', color: theme.fillSecondaryColor),
                _ColorRow(label: 'Fill Tertiary', color: theme.fillTertiaryColor),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: const Text('Palette'),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: MacOS26Colors.accents.map((c) {
                      final resolved = c.resolveFrom(context);
                      return _Swatch(color: resolved);
                    }).toList(),
                  ),
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: const Text('Materials'),
              children: [
                _MaterialRow(label: 'Ultra Thin', material: theme.materialUltraThin),
                _MaterialRow(label: 'Thin', material: theme.materialThin),
                _MaterialRow(label: 'Medium', material: theme.materialMedium),
                _MaterialRow(label: 'Thick', material: theme.materialThick),
                _MaterialRow(label: 'Ultra Thick', material: theme.materialUltraThick),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StyleRow extends StatelessWidget {
  const _StyleRow({required this.label, required this.style});

  final String label;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(label, style: style),
    );
  }
}

class _ColorRow extends StatelessWidget {
  const _ColorRow({required this.label, required this.color});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _Swatch(color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
          Text('#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}'),
        ],
      ),
    );
  }
}

class _MaterialRow extends StatelessWidget {
  const _MaterialRow({required this.label, required this.material});

  final String label;
  final CNGlassMaterial material;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text('blur ${material.blurRadius.toStringAsFixed(0)}'),
          const SizedBox(width: 8),
          Text('opacity ${material.opacity.toStringAsFixed(2)}'),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: CupertinoColors.separator.resolveFrom(context)),
      ),
    );
  }
}
