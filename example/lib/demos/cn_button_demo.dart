import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:flutter/cupertino.dart';

const _kDebugLog = false;

class ButtonDemoPage extends StatefulWidget {
  const ButtonDemoPage({super.key});

  @override
  State<ButtonDemoPage> createState() => _ButtonDemoPageState();
}

enum ButtonType { titleOnly, titleAndIcon, titleAndProgressCircle, titleAndProgressLinear }

class _ButtonDemoPageState extends State<ButtonDemoPage> {
  CNButtonStyle buttonStyle = CNButtonStyle.automatic;
  CNControlSize controlSize = CNControlSize.large;
  CNFont? font;
  double fontSize = kFontSizeDefault;
  bool isEnabled = true;
  bool isProgressRunning = false;
  double labelIconToTitleSpacing = 8;
  double labelReservedIconWidth = 2;
  FlutterPixelGeometry? lastGeometry;
  int progressMax = 100;
  int progressValue = 0;
  CNProgressViewStyle progressViewStyle = CNProgressViewStyle.linear;
  Color? tintColor;

  // ignore: unused_field
  String _last = 'None';

  void startProgress() {
    progressValue = 0;
    isProgressRunning = true;
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return false;
      setState(() {
        if (!mounted) {
          return;
        }
        progressValue++;
        if (progressValue > progressMax) {
          progressValue = 0;
        }
      });
      return isProgressRunning && mounted;
    });
  }

  void stopProgress() {
    isProgressRunning = false;
  }

  void _set(String what) {
    setState(() {
      debugPrint('Button pressed: $what');
      _last = what;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CNPageScaffold(
      navigationBar: const CNNavigationBar(middle: Text('Button')),
      child: CNContentArea(
        builder: (context, scrollController) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        CNPixelPerfectContainer(
                          adjustPosition: true,
                          onGeometryChanged: (geometry) {
                            debugPrint('PixelPerfectContainer geometry changed: $geometry');
                            setState(() {
                              lastGeometry = geometry;
                            });
                          },
                          child: CNButton(
                            onPressed: isEnabled ? () => _set('Default') : null,
                            buttonStyle: buttonStyle,
                            controlSize: controlSize,
                            tint: tintColor,
                            debugLog: _kDebugLog,
                            children: [CNChildText('Text Only', font: font)],
                          ),
                        ),
                        const SizedBox(height: 16),
                        CNPixelPerfectContainer(
                          adjustPosition: true,
                          child: CNButton(
                            onPressed: isEnabled ? () => _set('Default.2') : null,
                            buttonStyle: buttonStyle,
                            controlSize: controlSize,
                            tint: tintColor,
                            debugLog: false,
                            children: [
                              CNChildImage(
                                'square.and.arrow.up',
                                font: font,
                                symbolRenderingMode: CNSymbolRenderingMode.hierarchical,
                                paddings: EdgeInsets.symmetric(horizontal: labelReservedIconWidth),
                              ),
                              CNChildText(
                                'Icon and Text',
                                paddings: EdgeInsets.only(left: labelIconToTitleSpacing),
                                font: font,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        CNPixelPerfectContainer(
                          adjustPosition: true,
                          child: CNButton(
                            onPressed: isEnabled ? () => _set('Default.3') : null,
                            buttonStyle: buttonStyle,
                            controlSize: controlSize,
                            tint: tintColor,
                            debugLog: false,
                            children: [
                              const CNChildProgressView(style: CNProgressViewStyle.circular, controlSize: CNControlSize.small),
                              CNChildImage(
                                'square.and.arrow.down.badge.checkmark.fill',
                                font: font,
                                symbolRenderingMode: CNSymbolRenderingMode.hierarchical,
                                paddings: EdgeInsets.symmetric(horizontal: labelReservedIconWidth),
                              ),
                              CNChildText(
                                'Icon and Text',
                                paddings: EdgeInsets.only(left: labelIconToTitleSpacing),
                                font: font,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        CNPixelPerfectContainer(
                          adjustPosition: true,
                          child: CNButton(
                            onPressed: isEnabled
                                ? () {
                                    _set('Default.5');
                                    if (isProgressRunning) {
                                      stopProgress();
                                    } else {
                                      startProgress();
                                    }
                                  }
                                : null,
                            buttonStyle: buttonStyle,
                            controlSize: controlSize,
                            tint: tintColor,
                            debugLog: false,
                            children: [
                              CNChildProgressView(
                                tint: CNColors.fillSecondary,
                                value: progressValue.toDouble(),
                                total: progressMax.toDouble(),
                                style: CNProgressViewStyle.linear,
                                controlSize: CNControlSize.small,
                                constraints: BoxConstraints.tightFor(width: 80),
                              ),
                              CNChildText(
                                'Icon and Progress',
                                font: font,
                                paddings: EdgeInsets.only(left: labelIconToTitleSpacing),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (lastGeometry != null) ...[
                          DefaultTextStyle(
                            style: CNTheme.of(context).typography.caption1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Last geometry: ${lastGeometry!.x}, ${lastGeometry!.y}, ${lastGeometry!.width}, ${lastGeometry!.height}',
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Physical geometry: ${lastGeometry!.physicalX}, ${lastGeometry!.physicalY}, ${lastGeometry!.physicalWidth}, ${lastGeometry!.physicalHeight}',
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Window geometry: ${lastGeometry!.windowX}, ${lastGeometry!.windowY}, ${lastGeometry!.windowWidth}, ${lastGeometry!.windowHeight}',
                                ),
                                const SizedBox(height: 4),
                                Text('Device pixel ratio: ${lastGeometry!.devicePixelRatio}'),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              RightSideOptionContainer(
                options: {
                  'Control Size': ControlSizePicker(value: controlSize, onChanged: (size) => setState(() => controlSize = size)),
                  'Button Style': CNPicker(
                    selection: buttonStyle.name,
                    onChanged: (value) =>
                        setState(() => buttonStyle = CNButtonStyle.values.firstWhere((style) => style.name == value)),
                    children: CNButtonStyle.values.map((style) => CNChildText(style.name, tag: style.name)).toList(),
                  ),
                  'Tint Color': ColorPicker(
                    colors: kSystemColors,
                    value: tintColor,
                    onChanged: (color) => setState(() => tintColor = color),
                  ),
                  'Enabled': CNToggle(isOn: isEnabled, onChanged: (value) => setState(() => isEnabled = value), debugLog: false),
                  'Font': FontPicker(
                    fonts: kAvailableFonts,
                    value: font,
                    onChanged: (font) => setState(() => this.font = font?.copyWith(size: CNFontSize.points(fontSize))),
                  ),
                  'Font Size': SizeSliderPicker(
                    min: kFontSizeMin,
                    max: kFontSizeMax,
                    value: fontSize,
                    onChanged: font != null
                        ? (value) => setState(() {
                            fontSize = value;
                            font = font?.copyWith(size: CNFontSize.points(fontSize));
                          })
                        : null,
                  ),
                  'Icon Width': SizeSliderPicker(
                    min: 0,
                    max: 32,
                    value: labelReservedIconWidth,
                    onChanged: (value) => setState(() => labelReservedIconWidth = value),
                  ),
                  'Icon Spacing': SizeSliderPicker(
                    min: 0,
                    max: 32,
                    value: labelIconToTitleSpacing,
                    onChanged: (value) => setState(() => labelIconToTitleSpacing = value),
                  ),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
