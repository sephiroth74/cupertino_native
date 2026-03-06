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
              children: [
                const Text('Default'),
                Spacer(),
                Text('Value: ${_defaultSliderValue.toStringAsFixed(1)}'),
              ],
            ),

            CNSlider(
              value: _defaultSliderValue,
              onChanged: (v) => setState(() => _defaultSliderValue = v),
              allowsTickMarkValuesOnly: true,
              thickMarks: 20,
            ),

            const SizedBox(height: 48),

            // SizedBox(
            //   child: CNSlider(
            //     size: CNControlSize.large,
            //     value: _defaultSliderValue,
            //     onChanged: (v) => setState(() => _defaultSliderValue = v),
            //     thickMarks: 20,
            //     thickMarkPosition: CNSliderTickmarkPosition.above,
            //   ),
            // ),

            // const SizedBox(height: 48),

            // SizedBox(
            //   child: CNSlider(
            //     size: CNControlSize.large,
            //     value: _defaultSliderValue,
            //     onChanged: (v) => setState(() => _defaultSliderValue = v),
            //     thickMarks: 40,
            //     thickMarkPosition: CNSliderTickmarkPosition.below,
            //   ),
            // ),

            // SizedBox(
            //   child: CNSlider.circular(
            //     size: CNControlSize.extraLarge,
            //     value: _defaultSliderValue,
            //     thickMarks: 10,
            //     onChanged: (v) => setState(() => _defaultSliderValue = v),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
