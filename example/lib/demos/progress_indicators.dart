import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';

class ProgressIndicatorsPageDemo extends StatefulWidget {
  const ProgressIndicatorsPageDemo({Key? key}) : super(key: key);

  @override
  State<ProgressIndicatorsPageDemo> createState() =>
      _ProgressIndicatorsPageDemoState();
}

class _ProgressIndicatorsPageDemoState
    extends State<ProgressIndicatorsPageDemo> {
  double _progressValue = 0.5;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Slider')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const Text('Indeterminate'),
            const SizedBox(height: 12),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CNProgressIndicator.circular(
                    indeterminate: true,
                    size: CNControlSize.regular,
                  ),
                  const SizedBox(width: 48),
                  CNProgressIndicator.circular(
                    indeterminate: true,
                    size: CNControlSize.small,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: CNProgressIndicator.bar(
                      indeterminate: true,
                      size: CNControlSize.regular,
                    ),
                  ),
                  const SizedBox(width: 48),
                  Expanded(
                    child: CNProgressIndicator.bar(
                      indeterminate: true,
                      size: CNControlSize.small,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text('Determinate'),
            const SizedBox(height: 12),

            CNSlider(
              value: _progressValue,
              onChanged: (value) {
                setState(() {
                  _progressValue = value;
                });
              },
            ),

            const SizedBox(height: 12),

            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CNProgressIndicator.circular(
                    indeterminate: false,
                    value: _progressValue,
                    size: CNControlSize.regular,
                  ),
                  const SizedBox(width: 48),
                  CNProgressIndicator.circular(
                    indeterminate: false,
                    value: _progressValue,
                    size: CNControlSize.small,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: CNProgressIndicator.bar(
                      indeterminate: false,
                      value: _progressValue,
                      size: CNControlSize.regular,
                    ),
                  ),
                  const SizedBox(width: 48),
                  Expanded(
                    child: CNProgressIndicator.bar(
                      indeterminate: false,
                      value: _progressValue,
                      size: CNControlSize.small,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
