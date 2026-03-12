import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';

class CheckboxDemoPage extends StatefulWidget {
  const CheckboxDemoPage({super.key});

  @override
  State<CheckboxDemoPage> createState() => _CheckboxDemoPageState();
}

class _CheckboxDemoPageState extends State<CheckboxDemoPage> {
  CNCheckboxState _checkboxValue = CNCheckboxState.off;
  bool _checkboxesEnabled = true;
  bool _allowMixedState = false;
  CNControlSize _size = CNControlSize.regular;

  @override
  void dispose() {
    super.dispose();
  }

  void _toggleCheckbox(CNCheckboxState newValue) {
    debugPrint('Checkbox toggled: $newValue');
    setState(() {
      if (newValue == CNCheckboxState.mixed) {
        if (_allowMixedState) {
          _checkboxValue = newValue;
        } else {
          _checkboxValue = CNCheckboxState.on;
        }
      } else {
        _checkboxValue = newValue;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Checkbox Demo'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // control sizes
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Tristate'),
                const SizedBox(width: 16),
                CNSwitch(
                  value: _allowMixedState,
                  onChanged: (v) =>
                      setState(() => _allowMixedState = v == true),
                  controlSize: CNControlSize.small,
                ),
                const SizedBox(width: 32),
                const Text('Enabled'),
                const SizedBox(width: 16),
                CNSwitch(
                  value: _checkboxesEnabled,
                  onChanged: (v) =>
                      setState(() => _checkboxesEnabled = v == true),
                  controlSize: CNControlSize.small,
                ),
                const SizedBox(width: 32),
                const Text('Size'),
                const SizedBox(width: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 150,
                    maxWidth: 250,
                  ),
                  child: CNComboButton(
                    title: _size.name.toUpperCase(),
                    style: CNComboButtonStyle.split,
                    menu: CNMenu(
                      items: [
                        CNMenuItem(
                          title: 'Mini',
                          tag: 0,
                          state: _size == CNControlSize.mini
                              ? CNMenuItemState.on
                              : CNMenuItemState.off,
                          image: CNImage(systemSymbolName: "1.calendar"),
                        ),
                        CNMenuItem(
                          title: 'Small',
                          tag: 1,
                          state: _size == CNControlSize.small
                              ? CNMenuItemState.on
                              : CNMenuItemState.off,
                          image: CNImage(
                            systemSymbolName: "2.calendar",
                            symbolConfiguration: CNSymbolConfiguration.palette([
                              CupertinoColors.systemRed,
                              CupertinoColors.systemYellow,
                              CupertinoColors.systemGreen,
                            ]),
                          ),
                        ),
                        CNMenuItem(
                          title: 'Regular',
                          tag: 2,
                          state: _size == CNControlSize.regular
                              ? CNMenuItemState.on
                              : CNMenuItemState.off,
                          image: CNImage(
                            systemSymbolName: "3.calendar",
                            symbolConfiguration:
                                CNSymbolConfiguration.monochrome(
                                  CupertinoColors.systemGreen,
                                ),
                          ),
                        ),
                        CNMenuItem(
                          title: 'Large',
                          tag: 3,
                          state: _size == CNControlSize.large
                              ? CNMenuItemState.on
                              : CNMenuItemState.off,
                          image: CNImage(
                            systemSymbolName: "4.calendar",
                            symbolConfiguration:
                                CNSymbolConfiguration.hierarchical(
                                  CupertinoColors.systemBlue,
                                ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: (sender) {
                      debugPrint('onPressed($sender)');
                    },
                    onMenuItemSelected: (value) {
                      debugPrint(
                        'Size selected: ${value.title} (tag: ${value.tag})',
                      );

                      setState(() {
                        switch (value.tag) {
                          case 0:
                            _size = CNControlSize.mini;
                            break;
                          case 1:
                            _size = CNControlSize.small;
                            break;
                          case 2:
                            _size = CNControlSize.regular;
                            break;
                          case 3:
                            _size = CNControlSize.large;
                            break;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text('Basic ${_checkboxValue.name.toUpperCase()}'),
                Spacer(),
                CNCheckbox(
                  allowMixedState: _allowMixedState,
                  title: 'Default checkbox',
                  state: _checkboxValue,
                  controlSize: _size,
                  onChanged: _checkboxesEnabled ? _toggleCheckbox : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Colored ${_checkboxValue.name.toUpperCase()}'),
                Spacer(),
                CNCheckbox(
                  allowMixedState: _allowMixedState,
                  title: 'Colored checkbox',
                  color: CupertinoColors.systemMint,
                  state: _checkboxValue,
                  controlSize: _size,
                  onChanged: _checkboxesEnabled ? _toggleCheckbox : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Simple ${_checkboxValue.name.toUpperCase()}'),
                Spacer(),
                CNCheckbox(
                  allowMixedState: _allowMixedState,
                  state: _checkboxValue,
                  controlSize: _size,
                  onChanged: _checkboxesEnabled ? _toggleCheckbox : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Row(
            //   children: [
            //     Text('Colored ${_coloredCheckboxValue ? 'ON' : 'OFF'}'),
            //     Spacer(),
            //     CNCheckbox(
            //       value: _coloredCheckboxValue,
            //       controlSize: _size,
            //       color: CupertinoColors.systemPink,
            //       onChanged: (v) => setState(() => _coloredCheckboxValue = v),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 48),
            // Row(
            //   children: [
            //     Text('Disabled'),
            //     Spacer(),
            //     CNCheckbox(value: false, onChanged: null, controlSize: _size),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
