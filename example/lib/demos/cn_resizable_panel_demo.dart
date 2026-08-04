import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

/// Demonstrates [CNPageScaffold]'s horizontal split-view layout.
///
/// The scaffold's `children` are laid out left-to-right: each [CNResizablePane]
/// sizes to its own width, and the single [CNContentArea] fills the remaining
/// space. This mirrors `appkit_ui_elements`' `AppKitScaffold` children layout.
class ResizablePanelDemoPage extends StatelessWidget {
  const ResizablePanelDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CNPageScaffold(
      children: [
        CNResizablePane(
          minSize: 180,
          startSize: 200,
          windowBreakpoint: 700,
          resizableSide: CNResizableSide.right,
          builder: (_, _) {
            return const Center(child: Text('Left Resizable Pane'));
          },
        ),
        CNContentArea(
          builder: (_, _) {
            return Column(
              children: [
                const Flexible(
                  fit: FlexFit.loose,
                  child: Center(child: Text('Content Area')),
                ),
                CNResizablePane(
                  minSize: 50,
                  startSize: 200,
                  builder: (_, _) {
                    return const Center(child: Text('Bottom Resizable Pane'));
                  },
                  resizableSide: CNResizableSide.top,
                ),
              ],
            );
          },
        ),
        const CNResizablePane.noScrollBar(
          minSize: 180,
          startSize: 200,
          windowBreakpoint: 700,
          resizableSide: CNResizableSide.left,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: Text('Right non-scrollable Resizable Pane')),
          ),
        ),
      ],
    );
  }
}
