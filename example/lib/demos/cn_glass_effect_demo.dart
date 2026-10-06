import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/glass_effect_options.dart';
import 'package:flutter/cupertino.dart';

/// Demonstrates the shared SwiftUI `.glassEffect(_:in:)` support: a Liquid
/// Glass layer behind any SwiftUI-backed CN widget, including the native
/// toolbar items.
class GlassEffectDemoPage extends StatefulWidget {
  const GlassEffectDemoPage({super.key});

  @override
  State<GlassEffectDemoPage> createState() => _GlassEffectDemoPageState();
}

class _GlassEffectDemoPageState extends State<GlassEffectDemoPage> {
  GlassEffectOptions glass = const GlassEffectOptions(enabled: true);
  /// Keeps the native bezel inside the glass via explicit bordered styles
  /// (by default the glass replaces it).
  bool nativeBezel = false;

  String selection = 'system';
  double sliderValue = 0.5;

  static const _menuItems = [
    CNChildButton(tag: 'copy', title: 'Copy', systemImage: 'doc.on.doc'),
    CNChildButton(
      tag: 'paste',
      title: 'Paste',
      systemImage: 'doc.on.clipboard',
    ),
  ];

  List<CNChild> get _themeItems => [
    CNChildLabel('System', systemImage: 'sun.lefthalf.filled', tag: 'system'),
    CNChildLabel('Light', systemImage: 'sun.max', tag: 'light'),
    CNChildLabel('Dark', systemImage: 'moon', tag: 'dark'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = CNTheme.of(context);

    return CNContentArea(
      builder: (context, scrollController) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                children: [
                  Text('Live preview', style: theme.typography.title2),
                  const SizedBox(height: 4),
                  Text(
                    'The same glass effect is applied to native SwiftUI widgets. '
                    'It is rendered by SwiftUI on the native view — not by Flutter.',
                    style: theme.typography.subheadline.copyWith(
                      color: theme.secondaryLabelColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GlassBackdrop(
                    options: glass,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          CNPicker(
                            pickerStyle: CNPickerStyle.menu,
                            buttonStyle: nativeBezel
                                ? CNButtonStyle.bordered
                                : null,
                            glassEffect: glass.effect(),
                            paddings: glass.paddings(),
                            selection: selection,
                            onChanged: (v) => setState(() => selection = v),
                            children: _themeItems,
                          ),
                          CNMenu(
                            menuStyle: nativeBezel
                                ? CNMenuStyle.borderedButton
                                : CNMenuStyle.automatic,
                            glassEffect: glass.effect(),
                            paddings: glass.paddings(),
                            label: const [
                              CNChildLabel('Edit', systemImage: 'pencil'),
                            ],
                            items: _menuItems,
                            onItemPressed: (tag) =>
                                debugPrint('Glass menu item pressed: $tag'),
                          ),
                          CNButton(
                            buttonStyle: nativeBezel
                                ? CNButtonStyle.bordered
                                : CNButtonStyle.automatic,
                            glassEffect: glass.effect(),
                            paddings: glass.paddings(),
                            onPressed: () => debugPrint('Glass button pressed'),
                            children: const [
                              CNChildLabel(
                                'Share',
                                systemImage: 'square.and.arrow.up',
                              ),
                            ],
                          ),
                          CNText(
                            'Glass text',
                            glassEffect: glass.effect(minPadding: 8),
                            paddings: glass.paddings(),
                          ),
                          SizedBox(
                            width: 220,
                            child: CNSlider(
                              value: sliderValue,
                              shrink: false,
                              glassEffect: glass.effect(minPadding: 8),
                              paddings: glass.paddings(),
                              onChanged: (v) => setState(() => sliderValue = v),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('Toolbar items', style: theme.typography.title2),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: glass.enabled && glass.backdrop
                            ? kGlassBackdropGradient
                            : null,
                      ),
                      child: SizedBox(
                        height: kCNToolbarHeight,
                        child: CNToolbar(
                          automaticallyImplyLeading: false,
                          backgroundColor: CNColors.transparent,
                          dividerColor: CNColors.transparent,
                          actions: [
                            CNToolbarIconButton(
                              'sidebar.left',
                              glassEffect: glass.effect(),
                              paddings: glass.paddings(),
                              onPressed: () =>
                                  debugPrint('Glass icon button pressed'),
                            ),
                            CNToolbarNativeButton(
                              buttonStyle: nativeBezel
                                  ? CNButtonStyle.bordered
                                  : CNButtonStyle.automatic,
                              glassEffect: glass.effect(),
                              paddings: glass.paddings(),
                              onPressed: () =>
                                  debugPrint('Glass toolbar button pressed'),
                              children: const [
                                CNChildLabel(
                                  'Share',
                                  systemImage: 'square.and.arrow.up',
                                ),
                              ],
                            ),
                            CNToolbarPicker(
                              buttonStyle: nativeBezel
                                  ? CNButtonStyle.bordered
                                  : null,
                              glassEffect: glass.effect(),
                              paddings: glass.paddings(),
                              selection: selection,
                              onChanged: (v) => setState(() => selection = v),
                              children: _themeItems,
                            ),
                            CNToolbarPullDownButton(
                              menuStyle: nativeBezel
                                  ? CNMenuStyle.borderedButton
                                  : CNMenuStyle.automatic,
                              glassEffect: glass.effect(),
                              paddings: glass.paddings(),
                              label: const [
                                CNChildLabel('Edit', systemImage: 'pencil'),
                              ],
                              items: _menuItems,
                              onItemPressed: (tag) =>
                                  debugPrint('Glass pull-down pressed: $tag'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            RightSideOptionContainer(
              options: {
                ...glassEffectOptionEntries(
                  glass,
                  (v) => setState(() => glass = v),
                ),
                // Explicit bordered styles keep the native bezel inside the glass.
                'Native Bezel': CNToggle(
                  isOn: nativeBezel,
                  onChanged: (v) => setState(() => nativeBezel = v),
                ),
              },
            ),
          ],
        );
      },
    );
  }
}
