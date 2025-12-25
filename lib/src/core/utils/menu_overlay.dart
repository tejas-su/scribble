import 'package:flutter/material.dart';

///Show a menu overlay with options to delete, bookmark, share, and archive
///[restoreNote] is true if the note is archived or deleted,
///setting it to true will show restore and delete permanently options
///[onDelete] is the callback function to be called when delete is pressed
///[onBookmark] is the callback function to be called when bookmark is pressed
///[onShare] is the callback function to be called when share is pressed
///[onArchive] is the callback function to be called when archive is pressed
///[onRestore] is the callback function to be called when restore is pressed
///[deletePermanently] is the callback function to be called when delete permanently is pressed
void showMenuOverlay({
  required BuildContext context,
  required RelativeRect rect,
  bool restoreNote = false,
  VoidCallback? onDelete,
  VoidCallback? onBookmark,
  VoidCallback? onShare,
  VoidCallback? onArchive,
  VoidCallback? onRestore,
  VoidCallback? deletePermanently,
}) {
  // Create the overlay entry
  final OverlayState overlayState = Overlay.of(context);
  late OverlayEntry overlayEntry;

  void removeOverlay() {
    overlayEntry.remove();
  }

  const double menuWidth = 150.0;
  const double menuHeight = 157.0;
  const double padding = 8.0;
  final Size screenSize = MediaQuery.of(context).size;

  // Calculate optimal position
  double left = rect.left;
  double top = rect.top;

  // Check horizontal overflow
  if (left + menuWidth + padding > screenSize.width) {
    // Menu would overflow on the right, position from right edge
    left = screenSize.width - menuWidth - padding;
  }

  // Check vertical overflow
  if (top + menuHeight + padding > screenSize.height) {
    // Menu would overflow on the bottom, position from bottom edge
    top = screenSize.height - menuHeight - padding;
  }

  // Ensure menu doesn't go off the left edge
  if (left < padding) {
    left = padding;
  }

  // Ensure menu doesn't go off the top edge
  if (top < padding) {
    top = padding;
  }

  overlayEntry = OverlayEntry(
    builder: (context) => Stack(
      children: [
        // Transparent barrier to detect taps outside
        Positioned.fill(
          child: GestureDetector(
            onTap: removeOverlay,
            child: Container(color: Colors.transparent),
          ),
        ),
        // Menu container
        Positioned(
          left: left,
          top: top,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: menuWidth,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                spacing: 4,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    // If restoreNote is true, show restore and delete permanently options
                    restoreNote
                    ? [
                        // Restore option
                        _MenuOption(
                          label: 'Restore',
                          onTap: () {
                            removeOverlay();
                            onRestore!();
                          },
                        ),
                        // Delete permanently option
                        _MenuOption(
                          label: 'Delete',
                          onTap: () {
                            removeOverlay();
                            deletePermanently!();
                          },
                        ),
                      ]
                    :
                      // If restoreNote is false, show delete, bookmark, share, and archive options
                      [
                        // Delete option
                        _MenuOption(
                          label: 'Delete',
                          onTap: () {
                            removeOverlay();
                            onDelete!();
                          },
                        ),
                        // Bookmark option
                        _MenuOption(
                          label: 'Bookmark',
                          onTap: () {
                            removeOverlay();
                            onBookmark!();
                          },
                        ),
                        // Share option
                        _MenuOption(
                          label: 'Share',
                          onTap: () {
                            removeOverlay();
                            onShare!();
                          },
                        ),
                        // Archive option
                        _MenuOption(
                          label: 'Archive',
                          onTap: () {
                            removeOverlay();
                            onArchive!();
                          },
                        ),
                      ],
              ),
            ),
          ),
        ),
      ],
    ),
  );

  // Insert the overlay entry into the overlay
  overlayState.insert(overlayEntry);
}

class _MenuOption extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _MenuOption({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.transparent,
        ),
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
