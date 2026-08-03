import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/material.dart';

/// A simple icon button widget that can be used in the toolbar.
class CnIconButton extends StatelessWidget {
  /// Creates a [CnIconButton].
  CnIconButton({
    super.key,
    required this.size,
    this.icon,
    this.selectedIcon,
    this.systemSymbolName,
    this.selectedSystemSymbolName,
    this.onPressed,
    this.onLongPress,
    this.onHover,
    this.isSelected = false,
  }) : assert(icon != null || systemSymbolName != null, 'Either icon or systemSymbolName must be provided.'),
       assert(!(icon != null && systemSymbolName != null), 'Only one of icon or systemSymbolName can be provided.'),
       assert(
         !(selectedIcon != null && selectedSystemSymbolName != null),
         'Only one of selectedIcon or selectedSystemSymbolName can be provided.',
       );

  /// The callback to be invoked when the button is hovered.
  final Function(bool)? onHover;

  /// The icon to display inside the button. Cannot be used with [systemSymbolName].
  final IconData? icon;

  /// Whether the button is selected.
  final bool isSelected;

  /// The callback to be invoked when the button is long-pressed.
  final VoidCallback? onLongPress;

  /// The callback to be invoked when the button is pressed.
  final VoidCallback? onPressed;

  /// The icon to display when the button is selected. Cannot be used with [systemSymbolName].
  final IconData? selectedIcon;

  /// The system symbol name to display when the button is selected. Cannot be used with [selectedIcon].
  final String? selectedSystemSymbolName;

  /// The size of the button.
  final double size;

  /// The system symbol name to display inside the button. Cannot be used with [icon].
  final String? systemSymbolName;

  final WidgetStatesController _controller = WidgetStatesController();

  @override
  Widget build(BuildContext context) {
    final theme = CNTheme.of(context);
    return MouseRegion(
      onEnter: (event) => _controller.value = _controller.value = {..._controller.value, WidgetState.hovered},
      onExit: (event) => _controller.value = _controller.value = {..._controller.value}..remove(WidgetState.hovered),
      child: Builder(
        builder: (context) {
          final iconButton = IconButton(
            constraints: BoxConstraints.tightFor(width: size, height: size),
            icon: Icon(icon),
            iconSize: size / 2,
            alignment: Alignment.center,
            selectedIcon: selectedIcon != null ? Icon(selectedIcon) : null,
            isSelected: isSelected,
            splashColor: Colors.transparent,
            statesController: _controller,
            style: ButtonStyle(
              padding: WidgetStateProperty.all(EdgeInsets.zero),
              animationDuration: const Duration(milliseconds: 100),
              shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(size / 8))),
              splashFactory: NoSplash.splashFactory,
              iconColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered)) {
                  return theme.accentColor?.withLuminance(0.3);
                }
                return CNColors.label.resolveFromContext(context);
              }),
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered)) {
                  return theme.fillSecondaryColor;
                }
                return null;
              }),
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) {
                  return theme.fillPrimaryColor;
                }
                return null;
              }),
            ),
            onPressed: onPressed,
            onLongPress: onLongPress,
            onHover: onHover,
          );

          if (icon != null) {
            return iconButton;
          }

          final symbolName = isSelected ? (selectedSystemSymbolName ?? systemSymbolName!) : systemSymbolName!;

          return Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                right: 0,
                bottom: 0,
                child: ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) {
                    return CNImage(
                      debugLog: false,
                      shrink: false,
                      systemSymbolName: symbolName,
                      foregroundColor: _controller.value.contains(WidgetState.hovered)
                          ? theme.accentColor?.withLuminance(0.3)
                          : CNColors.label.resolveFromContext(context),
                      font: CNFont.system(CNFontSize.points(size / 2 - (size / 2 * 0.1))), // size - (padding based on size)
                      constraints: BoxConstraints.tightFor(width: size, height: size),
                    );
                  },
                ),
              ),
              iconButton,
            ],
          );
        },
      ),
    );
  }
}
