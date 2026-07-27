import 'package:flutter/widgets.dart';

/// A content area that fills the remaining space in a [CNPageScaffold].
class CNContentArea extends StatelessWidget {
  /// Creates a content area with an optional builder and constraints.
  const CNContentArea({required this.builder, this.constraints}) : super(key: const Key('cn_scaffold_content_area'));

  /// The builder function that is called to build the content area.
  final ScrollableWidgetBuilder? builder;

  /// Optional constraints to apply to the content area.
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: constraints ?? const BoxConstraints.expand(),
      child: SafeArea(left: false, right: false, child: builder!(context, ScrollController())),
    );
  }
}
