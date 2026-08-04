import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../app/cn_content_area.dart';
import '../components/cn_toolbar.dart';

/// Key marking the single [CNContentArea] among a scaffold's [CNPageScaffold.children].
const Key kCNScaffoldContentAreaKey = Key('cn_scaffold_content_area');

/// Desktop-aware page scaffold for Cupertino Native apps.
///
/// Reserves top space for an optional [toolBar] and overlays the bar on top of
/// the body, mirroring `appkit_ui_elements`' `AppKitScaffold`.
///
/// Two body modes, mutually exclusive:
///  * [child] — a single body widget that fills the whole content area.
///  * [children] — a horizontal split-view of resizable panes plus exactly one
///    [CNContentArea]. Each pane sizes to its own width; the content area fills
///    the remaining space. This mirrors `AppKitScaffold`'s `children` layout.
class CNPageScaffold extends StatelessWidget {
  /// Creates a page scaffold with an optional Flutter toolbar.
  ///
  /// Provide exactly one of [child] or [children].
  const CNPageScaffold({
    super.key,
    this.toolBar,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.child,
    this.children,
  }) : assert(
         (child == null) != (children == null),
         'CNPageScaffold requires exactly one of child or children.',
       );

  /// Background color for the page.
  ///
  /// If null, the page is transparent (the enclosing window paints the background).
  final Color? backgroundColor;

  /// Single body widget filling the content area. Mutually exclusive with [children].
  final Widget? child;

  /// Horizontal split-view body: resizable panes plus exactly one [CNContentArea].
  /// Mutually exclusive with [child].
  final List<Widget>? children;

  /// Whether the body should avoid bottom insets like the keyboard.
  final bool resizeToAvoidBottomInset;

  /// Optional Flutter toolbar overlaid at the top of the page.
  final CNToolbar? toolBar;

  /// Single-child body: the [child] fills the content area beneath the toolbar.
  Widget _buildSingleChild(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    Widget paddedContent = child!;

    if (toolBar != null) {
      // Reserve exactly the toolbar height, overriding any incoming top inset
      // (mirrors AppKitScaffold). This makes the scaffold a "replace" surface: a
      // pushed page owns the whole toolbar strip rather than stacking beneath a
      // parent's bar. The toolbar itself is drawn flush at the window top below.
      final topPadding = toolBar!.preferredSize.height;
      final bottomPadding = resizeToAvoidBottomInset ? mediaQuery.viewInsets.bottom : 0.0;

      paddedContent = MediaQuery(
        data: mediaQuery.copyWith(
          padding: mediaQuery.padding.copyWith(top: topPadding),
          viewInsets: resizeToAvoidBottomInset ? mediaQuery.viewInsets.copyWith(bottom: 0.0) : mediaQuery.viewInsets,
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: paddedContent,
        ),
      );
    } else if (resizeToAvoidBottomInset) {
      paddedContent = MediaQuery(
        data: mediaQuery.copyWith(viewInsets: mediaQuery.viewInsets.copyWith(bottom: 0)),
        child: Padding(
          padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
          child: paddedContent,
        ),
      );
    }

    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(color: backgroundColor),
        child: Stack(
          children: [
            paddedContent,
            if (toolBar != null) _positionedToolBar(),
          ],
        ),
      ),
    );
  }

  /// Split-view body: [children] laid out horizontally (panes + content area).
  Widget _buildSplitView(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = toolBar?.preferredSize.height ?? 0.0;

    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(color: backgroundColor),
        child: Stack(
          children: [
            // Reserve the toolbar strip by overriding the top inset (mirrors
            // AppKitScaffold). Panes read this via SafeArea so their content
            // clears the bar while their frames still span the full height.
            Positioned.fill(
              child: MediaQuery(
                data: mediaQuery.copyWith(padding: EdgeInsets.only(top: topPadding)),
                child: _CNScaffoldBody(children: children!),
              ),
            ),
            if (toolBar != null) _positionedToolBar(),
          ],
        ),
      ),
    );
  }

  /// The toolbar, drawn flush at the window top over the body.
  Widget _positionedToolBar() {
    // Drawn flush at the window top (mirrors AppKitScaffold). Combined with the
    // height-only content reservation, a pushed page's toolbar fully replaces
    // any parent bar rather than stacking below it.
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: toolBar!.preferredSize.height,
      child: toolBar!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return children != null ? _buildSplitView(context) : _buildSingleChild(context);
  }
}

/// Lays out scaffold [children] in a horizontal row: each non-content child
/// sizes to its intrinsic width; the single [CNContentArea] (keyed
/// [kCNScaffoldContentAreaKey]) fills the remaining width. Ported from
/// `appkit_ui_elements`' `AppKitScaffold`.
class _CNScaffoldBody extends MultiChildRenderObjectWidget {
  const _CNScaffoldBody({super.children});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderCNScaffoldBody(contentAreaIndex: _contentAreaIndex());
  }

  @override
  void updateRenderObject(BuildContext context, _RenderCNScaffoldBody renderObject) {
    renderObject.contentAreaIndex = _contentAreaIndex();
  }

  int? _contentAreaIndex() {
    final index = children.indexWhere((e) => e.key == kCNScaffoldContentAreaKey);
    return index > -1 ? index : null;
  }
}

class _CNScaffoldParentData extends ContainerBoxParentData<RenderBox> {
  double width = 0.0;
}

class _RenderCNScaffoldBody extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, _CNScaffoldParentData>, RenderBoxContainerDefaultsMixin<RenderBox, _CNScaffoldParentData> {
  _RenderCNScaffoldBody({this.contentAreaIndex});

  /// Index of the [CNContentArea] child (fills remaining width), or null.
  int? contentAreaIndex;

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  void performLayout() {
    final fullHeight = constraints.biggest.height;
    final fullWidth = constraints.biggest.width;

    // Sum the intrinsic widths of every child except the content area, so the
    // content area can claim the leftover width.
    final measurable = getChildrenAsList();
    if (contentAreaIndex != null) measurable.removeAt(contentAreaIndex!);
    double panesWidth = 0;
    for (final pane in measurable) {
      pane.layout(const BoxConstraints.tightFor(), parentUsesSize: true);
      panesWidth += pane.size.width;
    }

    // Lay children out left-to-right, accumulating x offsets.
    double x = 0.0;
    int index = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as _CNScaffoldParentData;
      if (index == contentAreaIndex) {
        final contentWidth = math.max(300.0, fullWidth - panesWidth);
        child.layout(
          BoxConstraints(maxWidth: contentWidth, minHeight: fullHeight, maxHeight: fullHeight).normalize(),
          parentUsesSize: true,
        );
      } else {
        child.layout(const BoxConstraints.tightFor(), parentUsesSize: true);
      }
      childParentData.width = child.size.width;
      childParentData.offset = Offset(x, 0);
      x += child.size.width;
      index++;
      child = childParentData.nextSibling;
    }

    size = Size(fullWidth, fullHeight);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _CNScaffoldParentData) child.parentData = _CNScaffoldParentData();
  }
}
