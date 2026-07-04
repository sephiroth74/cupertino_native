import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';

class ProgressIndicatorsPageDemo extends StatefulWidget {
  const ProgressIndicatorsPageDemo({super.key});

  @override
  State<ProgressIndicatorsPageDemo> createState() => _ProgressIndicatorsPageDemoState();
}

class _ProgressIndicatorsPageDemoState extends State<ProgressIndicatorsPageDemo> {
  double _progressValue = 0.5;

  @override
  Widget build(BuildContext context) {
    return CNPageScaffold(
      navigationBar: const CNNavigationBar(middle: Text('Progress View')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const Text('Automatic + Extra Large + Tint'),
            const SizedBox(height: 12),
            Center(
              child: CNProgressView(
                value: _progressValue,
                progressViewStyle: CNProgressViewStyle.linear,
                controlSize: CNControlSize.extraLarge,
                tint: CupertinoColors.activeOrange,
              ),
            ),

            const SizedBox(height: 12),
            const Text('Linear progress view'),
            const SizedBox(height: 12),
            CNProgressView(progressViewStyle: CNProgressViewStyle.linear, controlSize: CNControlSize.regular),

            const SizedBox(height: 12),
            const Text('Circular progress view with determinate value'),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: CNProgressView(
                progressViewStyle: CNProgressViewStyle.circular,
                controlSize: CNControlSize.regular,
                value: _progressValue,
              ),
            ),
            const SizedBox(height: 12),

            // const SizedBox(height: 16),
            const Text('Indeterminate circular progress view'),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  CNProgressView(controlSize: CNControlSize.small, progressViewStyle: CNProgressViewStyle.circular),
                  const SizedBox(width: 12),
                  CNProgressView(
                    controlSize: CNControlSize.regular,
                    progressViewStyle: CNProgressViewStyle.circular,
                    tint: MacOS26Colors.brown,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text('Determinate value'),
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
                  Expanded(
                    child: CNProgressView(
                      value: _progressValue,
                      progressViewStyle: CNProgressViewStyle.linear,
                      controlSize: CNControlSize.regular,
                    ),
                  ),
                  const SizedBox(width: 24),
                  CNProgressView(
                    width: 100,
                    value: _progressValue,
                    progressViewStyle: CNProgressViewStyle.linear,
                    controlSize: CNControlSize.small,
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
