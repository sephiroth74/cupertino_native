import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/glass_effect_options.dart';
import 'package:flutter/cupertino.dart';

const _kDebugLog = false;

class SecureTextFieldDemoPage extends StatefulWidget {
  const SecureTextFieldDemoPage({super.key});

  @override
  State<SecureTextFieldDemoPage> createState() =>
      _SecureTextFieldDemoPageState();
}

class _SecureTextFieldDemoPageState extends State<SecureTextFieldDemoPage> {
  final TextEditingController _controller = TextEditingController(text: '');
  GlassEffectOptions _glass = const GlassEffectOptions();
  String _valueInfo = '';

  @override
  void dispose() {
    _controller.removeListener(_updateValueInfo);
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateValueInfo);
    _updateValueInfo();
  }

  void _updateValueInfo() {
    if (!mounted) return;
    setState(() {
      _valueInfo = 'Length: ${_controller.text.length}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 12),
                GlassBackdrop(
                  options: _glass,
                  child: CNSecureField(
                    glassEffect: _glass.effect(),
                    paddings: _glass.paddings(),
                    prompt: 'Enter password...',
                    autofocus: true,
                    controller: _controller,
                    textFieldStyle: CNTextFieldStyle.roundedBorder,
                    constraints: BoxConstraints(maxWidth: 400),
                    controlSize: CNControlSize.large,
                    onSubmitted: (value) {
                      debugPrint('Submitted value: $value');
                      _controller.text = value;
                    },
                    onChanged: (value) {
                      debugPrint('Changed value: $value');
                      _controller.text = value;
                    },
                    debugLog: _kDebugLog,
                  ),
                ),
                const SizedBox(height: 16),
                Text(_valueInfo),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    CNButton(
                      children: [const CNChildText('Set Value')],
                      onPressed: () {
                        _controller.text = 's3cr3t-passw0rd';
                      },
                    ),
                    CNButton(
                      children: [const CNChildText('Clear')],
                      onPressed: () {
                        _controller.clear();
                      },
                      buttonStyle: CNButtonStyle.borderedProminent,
                      tint: CNColors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
          RightSideOptionContainer(
            options: glassEffectOptionEntries(
              _glass,
              (v) => setState(() => _glass = v),
            ),
          ),
        ],
      ),
    );
  }
}
