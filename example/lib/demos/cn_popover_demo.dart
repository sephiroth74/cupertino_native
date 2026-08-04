import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class PopoverDemoPage extends StatefulWidget {
  const PopoverDemoPage({super.key});

  @override
  State<PopoverDemoPage> createState() => _PopoverDemoPageState();
}

class _PopoverDemoPageState extends State<PopoverDemoPage> {
  CNPopoverResult? _lastResult;

  Future<void> _showBasicPopover(BuildContext ctx) async {
    final result = await CNPopover.show(
      ctx,
      title: 'Project Actions',
      message: 'Choose what to do with the current project item.',
      actions: const [
        CNChildButton(tag: 'open', title: 'Open'),
        CNChildButton(tag: 'duplicate', title: 'Duplicate'),
        CNChildButton(
          tag: 'delete',
          title: 'Delete',
          role: CNButtonRole.destructive,
        ),
      ],
    );
    if (result != null) setState(() => _lastResult = result);
  }

  Future<void> _showTopPopover(BuildContext ctx) async {
    final result = await CNPopover.show(
      ctx,
      title: 'Info',
      message: 'This popover appears above the button.',
      preferredEdge: CNPopoverEdge.top,
      actions: const [CNChildButton(tag: 'close', title: 'Close')],
    );
    if (result != null) setState(() => _lastResult = result);
  }

  Future<void> _showTrailingPopover(BuildContext ctx) async {
    final result = await CNPopover.show(
      ctx,
      title: 'Invite Collaborators',
      message: 'Share this workspace with your team members.',
      preferredEdge: CNPopoverEdge.trailing,
      actions: const [
        CNChildButton(tag: 'share', title: 'Share'),
        CNChildButton(tag: 'later', title: 'Later', role: CNButtonRole.cancel),
      ],
    );
    if (result != null) setState(() => _lastResult = result);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Builder(
              builder: (ctx) => CNPixelPerfectContainer(
                adjustPosition: true,
                child: CNButton(
                  onPressed: () => _showBasicPopover(ctx),
                  children: [
                    CNChildLabel(
                      'Basic Popover',
                      systemImage: 'rectangle.on.rectangle',
                    ),
                  ],
                  controlSize: CNControlSize.large,
                  buttonStyle: CNButtonStyle.borderedProminent,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Builder(
              builder: (ctx) => CNPixelPerfectContainer(
                adjustPosition: true,
                child: CNButton(
                  onPressed: () => _showTopPopover(ctx),
                  children: [
                    CNChildLabel(
                      'Top Edge Popover',
                      systemImage: 'arrow.up.square',
                    ),
                  ],
                  controlSize: CNControlSize.large,
                  buttonStyle: CNButtonStyle.borderedProminent,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Builder(
              builder: (ctx) => CNPixelPerfectContainer(
                adjustPosition: true,
                child: CNButton(
                  onPressed: () => _showTrailingPopover(ctx),
                  children: [
                    CNChildLabel(
                      'Trailing Edge Popover',
                      systemImage: 'arrow.right.square',
                    ),
                  ],
                  controlSize: CNControlSize.large,
                  buttonStyle: CNButtonStyle.borderedProminent,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_lastResult != null) ...[
              Text('Selected index: ${_lastResult!.selectedIndex}'),
              Text('Selected tag: ${_lastResult!.selectedTag ?? '-'}'),
            ],
          ],
        ),
      ),
    );
  }
}
