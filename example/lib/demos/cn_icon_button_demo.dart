import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:flutter/cupertino.dart';

class IconButtonDemoPage extends StatefulWidget {
  const IconButtonDemoPage({super.key});

  @override
  State<IconButtonDemoPage> createState() => _IconButtonDemoPageState();
}

class _IconButtonDemoPageState extends State<IconButtonDemoPage> {
  Duration animationDuration = const Duration(milliseconds: 100);
  Color? backgroundColor;
  Color? borderColor;
  double borderWidth = 0;
  Color? foregroundColor;
  double iconSizeRatio = 0.75;
  bool isEnabled = true;
  bool isSelected = false;
  CNIconButtonShape shape = CNIconButtonShape.roundedRectangle;
  double size = 48;
  int tapCount = 0;

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(text, style: CNTheme.of(context).typography.headline);
  }

  @override
  Widget build(BuildContext context) {
    return CNContentArea(
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(context, 'Playground'),
                      const SizedBox(height: 16),
                      Center(
                        child: CNIconButton(
                          size: size,
                          systemSymbolName: 'square.and.arrow.up',
                          selectedSystemSymbolName: 'checkmark',
                          isSelected: isSelected,
                          shape: shape,
                          iconSizeRatio: iconSizeRatio > 0
                              ? iconSizeRatio
                              : null,
                          foregroundColor: foregroundColor,
                          backgroundColor: backgroundColor,
                          borderColor: borderColor,
                          borderWidth: borderWidth,
                          animationDuration: animationDuration,
                          onTap: isEnabled
                              ? () => setState(() => tapCount++)
                              : null,
                          onLongPress: isEnabled
                              ? () => setState(() => isSelected = !isSelected)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          'Tapped $tapCount time${tapCount == 1 ? '' : 's'} · long-press toggles selection',
                          style: CNTheme.of(context).typography.caption1,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _sectionTitle(context, 'Shapes'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          for (final s in CNIconButtonShape.values) ...[
                            Column(
                              children: [
                                CNIconButton(
                                  size: 44,
                                  systemSymbolName: 'star.fill',
                                  shape: s,
                                  borderColor: CNTheme.of(
                                    context,
                                  ).separatorColor,
                                  borderWidth: 1,
                                  onTap: () {},
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  s.name,
                                  style: CNTheme.of(
                                    context,
                                  ).typography.caption2,
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                          ],
                        ],
                      ),
                      const SizedBox(height: 32),
                      _sectionTitle(context, 'Flutter icon vs. SF Symbol'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          CNIconButton(
                            size: 44,
                            icon: CupertinoIcons.heart_fill,
                            onTap: () {},
                            iconSizeRatio: iconSizeRatio > 0
                                ? iconSizeRatio
                                : null,
                          ),
                          const SizedBox(width: 20),
                          CNIconButton(
                            size: 44,
                            systemSymbolName: 'heart.fill',
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _sectionTitle(
                        context,
                        'Scoped CNIconButtonTheme (accent-tinted, capsule)',
                      ),
                      const SizedBox(height: 12),
                      CNIconButtonTheme(
                        data: const CNIconButtonThemeData(
                          shape: CNIconButtonShape.capsule,
                          backgroundColor: Color(0x1A007AFF),
                          hoveredBackgroundColor: Color(0x33007AFF),
                          foregroundColor: Color(0xFF007AFF),
                          hoveredForegroundColor: Color(0xFF0055CC),
                          iconSizeRatio: 0.45,
                        ),
                        child: Row(
                          children: [
                            CNIconButton(
                              size: 44,
                              systemSymbolName: 'bold',
                              onTap: () {},
                            ),
                            const SizedBox(width: 12),
                            CNIconButton(
                              size: 44,
                              systemSymbolName: 'italic',
                              onTap: () {},
                            ),
                            const SizedBox(width: 12),
                            CNIconButton(
                              size: 44,
                              systemSymbolName: 'underline',
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              RightSideOptionContainer(
                options: {
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
                    onChanged: (color) =>
                        setState(() => foregroundColor = color),
                  ),
                  'Background': ColorPicker(
                    colors: kSystemColors,
                    value: backgroundColor,
                    onChanged: (color) =>
                        setState(() => backgroundColor = color),
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
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
