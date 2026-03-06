import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';

class SliderDemoPage extends StatefulWidget {
  const SliderDemoPage({super.key});

  @override
  State<SliderDemoPage> createState() => _SliderDemoPageState();
}

class _SliderDemoPageState extends State<SliderDemoPage> {
  double _defaultSliderValue = .5;
  double _coloredSliderValue = 50;
  CNControlSize _size = CNControlSize.regular;

  void _onSliderChange(double v) {
    setState(() {
      _defaultSliderValue = v;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Slider')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Size'),
                const SizedBox(width: 16),
                CNPopupMenuButton.icon(
                  buttonIcon: CNSymbol('gearshape', size: 12),
                  items: [
                    CNPopupMenuItem(
                      label: 'Mini',
                      checked: _size == CNControlSize.mini,
                    ),
                    CNPopupMenuItem(
                      label: 'Small',
                      checked: _size == CNControlSize.small,
                    ),
                    CNPopupMenuItem(
                      label: 'Regular',
                      checked: _size == CNControlSize.regular,
                    ),
                    CNPopupMenuItem(
                      label: 'Large',
                      checked: _size == CNControlSize.large,
                    ),
                    CNPopupMenuItem(
                      label: 'Extra Large',
                      checked: _size == CNControlSize.extraLarge,
                    ),
                  ],
                  onSelected: (v) =>
                      setState(() => _size = CNControlSize.values[v]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Default'),
                Spacer(),
                Text('Value: ${_defaultSliderValue.toStringAsFixed(2)}'),
              ],
            ),
            CNSlider(
              value: _defaultSliderValue,
              onChanged: (v) => setState(() => _defaultSliderValue = v),
              controlSize: _size,
            ),
            const SizedBox(height: 16),
            Text('Step Slider'),
            CNSlider(
              value: _defaultSliderValue,
              onChanged: (v) => setState(() => _defaultSliderValue = v),
              tickMarks: 20,
              allowsTickMarkValuesOnly: true,
              tickMarkPosition: CNSliderTickmarkPosition.below,
              controlSize: _size,
            ),
            const SizedBox(height: 16),
            Text('Non Continuous'),
            CNSlider(
              value: _defaultSliderValue,
              isContinuous: false,
              onChanged: (v) => setState(() => _defaultSliderValue = v),
              controlSize: _size,
            ),
            const SizedBox(height: 16),
            Text('Tinted'),

            CNSlider(
              value: _defaultSliderValue,
              isContinuous: false,
              onChanged: (v) => setState(() => _defaultSliderValue = v),
              controlSize: _size,
              color: CupertinoColors.activeGreen,
            ),
            const SizedBox(height: 16),
            Text('Disabled'),

            CNSlider(
              value: _defaultSliderValue,
              isContinuous: false,
              onChanged: null,
              controlSize: _size,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                SizedBox(
                  height: 150,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text('Vertical'),
                      const SizedBox(height: 16.0),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 100,
                            child: CNSlider.vertical(
                              value: _defaultSliderValue,
                              isContinuous: true,
                              onChanged: _onSliderChange,
                              controlSize: _size,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          SizedBox(
                            height: 100,
                            child: CNSlider.vertical(
                              value: _defaultSliderValue,
                              isContinuous: true,
                              onChanged: _onSliderChange,
                              controlSize: _size,
                              tickMarks: 10,
                              allowsTickMarkValuesOnly: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),

                SizedBox(
                  height: 150,
                  child: Column(
                    children: [
                      Text('Circular'),
                      const SizedBox(height: 16.0),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CNSlider.circular(
                            value: _defaultSliderValue,
                            onChanged: _onSliderChange,
                            controlSize: _size,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
