import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

class CNTabView extends StatefulWidget {
  @override
  State<CNTabView> createState() => _CNTabViewState();
}

class _CNTabViewState extends State<CNTabView> {
  double _pickerHeight = 0;
  final GlobalKey _pickerKey = GlobalKey();
  double _pickerWidth = 0;

  @override
  void initState() {
    super.initState();
  }

  void _updatePickerSize() {
    final RenderBox? renderBox =
        _pickerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _pickerHeight = renderBox.size.height;
          _pickerWidth = renderBox.size.width;
        });
      });
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: CupertinoColors.separator, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: NotificationListener<SizeChangedLayoutNotification>(
        onNotification: (notification) {
          _updatePickerSize();
          return true;
        },
        child: Stack(
          fit: StackFit.loose,
          children: [
            Container(
              padding: EdgeInsets.only(top: _pickerHeight > 0 ? _pickerHeight / 2 : 0),
              child: GroupBox(
                borderDecoration: BoxDecoration(
                  color: CupertinoColors.extraLightBackgroundGray.withAlpha(127),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: Text('Tab View Content')),
                )),
            ),
            // Background per il picker
            if (_pickerHeight > 0)
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: _pickerWidth, // Ajusta según el ancho del picker
                  height: _pickerHeight,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground,
                    borderRadius: BorderRadius.circular(_pickerHeight / 2),
                  ),
                ),
              ),
            // Picker con key per misurare l'altezza
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                key: _pickerKey,
                child: SizeChangedLayoutNotifier(
                  child: CNPicker(
                    items: CNPickerStyle.values
                        .map((e) => CNPickerItem.text(e.name))
                        .toList(),
                    selectedIndex: 0,
                    shrinkWrap: true,
                    pickerStyle: CNPickerStyle.segmented,
                    controlSize: CNControlSize.large,
                    onValueChanged: (value) {},
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
