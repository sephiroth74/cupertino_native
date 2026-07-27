import 'package:flutter/widgets.dart';

class CNContentArea extends StatelessWidget {
  const CNContentArea({required this.builder, this.minWidth = 300})
    : super(key: const Key('cn_scaffold_content_area'));

  /// The builder function that is called to build the content area.
  final ScrollableWidgetBuilder? builder;

  /// The minimum width of the content area.
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.expand().copyWith(minWidth: minWidth),
      child: SafeArea(left: false, right: false, child: builder!(context, ScrollController())),
    );
  }
}
