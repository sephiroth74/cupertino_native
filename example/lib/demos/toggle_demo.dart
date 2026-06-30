import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cupertino_native/cupertino_native.dart';

class ToggleDemo extends StatefulWidget {
  const ToggleDemo({super.key});

  @override
  State<ToggleDemo> createState() => _ToggleDemoState();
}

class _ToggleDemoState extends State<ToggleDemo> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _soundEnabled = false;
  bool _autoSave = true;
  bool _automaticStyle = false;
  bool _checkboxStyle = true;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Toggle Demo')),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Switch Style Toggle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16),
                child: CNToggle(
                  value: _darkMode,
                  label: 'Dark Mode',
                  systemSymbolName: 'moon.fill',
                  toggleStyle: CNToggleStyle.switch_,
                  onChanged: (value) {
                    setState(() {
                      _darkMode = value;
                    });
                    _showNotification('Dark Mode ${value ? "enabled" : "disabled"}');
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text('Button Style Toggle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16),
                child: CNToggle(
                  value: _notifications,
                  label: 'Notifications',
                  systemSymbolName: 'bell.fill',
                  toggleStyle: CNToggleStyle.button,
                  onChanged: (value) {
                    setState(() {
                      _notifications = value;
                    });
                    _showNotification('Notifications ${value ? "enabled" : "disabled"}');
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text('Multiple Toggles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CNToggle(
                      value: _soundEnabled,
                      label: 'Sound',
                      systemSymbolName: 'speaker.wave.2.fill',
                      toggleStyle: CNToggleStyle.switch_,
                      onChanged: (value) {
                        setState(() {
                          _soundEnabled = value;
                        });
                        _showNotification('Sound ${value ? "enabled" : "disabled"}');
                      },
                    ),
                    const SizedBox(height: 16),
                    CNToggle(
                      value: _autoSave,
                      label: 'Auto-Save',
                      systemSymbolName: 'checkmark.circle.fill',
                      toggleStyle: CNToggleStyle.switch_,
                      onChanged: (value) {
                        setState(() {
                          _autoSave = value;
                        });
                        _showNotification('Auto-Save ${value ? "enabled" : "disabled"}');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Icon Only Toggles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CNToggle(
                      value: _darkMode,
                      systemSymbolName: 'moon.fill',
                      toggleStyle: CNToggleStyle.button,
                      onChanged: (value) {
                        setState(() {
                          _darkMode = value;
                        });
                      },
                    ),
                    CNToggle(
                      value: _notifications,
                      systemSymbolName: 'bell.fill',
                      toggleStyle: CNToggleStyle.button,
                      onChanged: (value) {
                        setState(() {
                          _notifications = value;
                        });
                      },
                    ),
                    CNToggle(
                      value: _soundEnabled,
                      systemSymbolName: 'speaker.wave.2.fill',
                      toggleStyle: CNToggleStyle.button,
                      onChanged: (value) {
                        setState(() {
                          _soundEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Checkbox Style Toggle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16),
                child: CNToggle(
                  value: _checkboxStyle,
                  label: 'Enable Feature',
                  toggleStyle: CNToggleStyle.checkbox,
                  onChanged: (value) {
                    setState(() {
                      _checkboxStyle = value;
                    });
                    _showNotification('Checkbox toggle: ${value ? "enabled" : "disabled"}');
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text('Automatic Style Toggle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16),
                child: CNToggle(
                  value: _automaticStyle,
                  label: 'Automatic Style',
                  systemSymbolName: 'gear',
                  toggleStyle: CNToggleStyle.automatic,
                  onChanged: (value) {
                    setState(() {
                      _automaticStyle = value;
                    });
                    _showNotification('Automatic toggle: ${value ? "enabled" : "disabled"}');
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text('All Styles Comparison', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CNToggle(
                      value: _darkMode,
                      label: 'Switch Style',
                      systemSymbolName: 'switch.2',
                      toggleStyle: CNToggleStyle.switch_,
                      onChanged: (value) {
                        setState(() {
                          _darkMode = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    CNToggle(
                      value: _notifications,
                      label: 'Button Style',
                      systemSymbolName: 'button.rounded.fill',
                      toggleStyle: CNToggleStyle.button,
                      onChanged: (value) {
                        setState(() {
                          _notifications = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    CNToggle(
                      value: _checkboxStyle,
                      label: 'Checkbox Style',
                      systemSymbolName: 'checkmark.square',
                      toggleStyle: CNToggleStyle.checkbox,
                      onChanged: (value) {
                        setState(() {
                          _checkboxStyle = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    CNToggle(
                      value: _automaticStyle,
                      label: 'Automatic Style',
                      systemSymbolName: 'dial.high.fill',
                      toggleStyle: CNToggleStyle.automatic,
                      onChanged: (value) {
                        setState(() {
                          _automaticStyle = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(milliseconds: 800)));
  }
}
