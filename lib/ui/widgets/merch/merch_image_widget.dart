import 'package:flutter/material.dart';
import '../../../core/constants/merch_config.dart';
import '../../../backend/domain/models/merch_item.dart';

/// Displays merch product images loaded from remote URLs (via asset_metadata),
/// with a PageView carousel for multiple photos and automatic fallback to
/// placeholder icons when no images are available or loaded.
///
/// [imageUrls]   — ordered list of public image URLs for this item.
///                 Pass an empty list to always show the placeholder icon.
/// [showCarousel] — true in detail screen (enables paging + dot indicators +
///                  tap-to-lightbox); false in grid cards (first image only, no dots).
/// [iconSize]    — size of the fallback Material Icon.
class MerchImageWidget extends StatefulWidget {
  final MerchItem item;
  final List<String> imageUrls;
  final bool showCarousel;
  final double iconSize;

  const MerchImageWidget({
    super.key,
    required this.item,
    required this.imageUrls,
    this.showCarousel = false,
    this.iconSize = 60,
  });

  @override
  State<MerchImageWidget> createState() => _MerchImageWidgetState();
}

class _MerchImageWidgetState extends State<MerchImageWidget> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openLightbox(BuildContext context, List<String> urls, int initialIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      barrierDismissible: true,
      builder: (_) => _LightboxDialog(
        urls: urls,
        initialIndex: initialIndex,
        accentColor: MerchConfig.getAccentColor(widget.item.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final validUrls = widget.imageUrls.where((u) => u.isNotEmpty).toList();

    if (validUrls.isEmpty) {
      return _buildPlaceholder();
    }

    // Grid card (no carousel): show first image only, BoxFit.cover for clean thumbnail
    if (!widget.showCarousel) {
      return _buildImage(validUrls.first, cover: true);
    }

    // Detail screen, single image: show with tap-to-lightbox
    if (validUrls.length == 1) {
      return GestureDetector(
        onTap: () => _openLightbox(context, validUrls, 0),
        child: MouseRegion(
          cursor: SystemMouseCursors.zoomIn,
          child: _buildImage(validUrls.first, cover: false),
        ),
      );
    }

    // Detail screen, multi-image carousel with dots, caption, tap-to-lightbox
    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: () => _openLightbox(context, validUrls, _currentPage),
                child: MouseRegion(
                  cursor: SystemMouseCursors.zoomIn,
                  child: PageView.builder(
                    controller: _pageController,
                    // PageScrollPhysics ensures drag/swipe works on web (Flutter web
                    // defaults to NeverScrollableScrollPhysics for pointer devices)
                    physics: const PageScrollPhysics(),
                    itemCount: validUrls.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (_, i) => _buildImage(validUrls[i], cover: false),
                  ),
                ),
              ),
              // Left arrow
              if (_currentPage > 0)
                Positioned(
                  left: 8,
                  child: _CarouselArrow(
                    icon: Icons.chevron_left,
                    onTap: () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    ),
                  ),
                ),
              // Right arrow
              if (_currentPage < validUrls.length - 1)
                Positioned(
                  right: 8,
                  child: _CarouselArrow(
                    icon: Icons.chevron_right,
                    onTap: () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(validUrls.length, (i) {
            final active = i == _currentPage;
            return GestureDetector(
              onTap: () => _pageController.animateToPage(
                i,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
              ),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: active ? 12 : 8,
                    height: active ? 12 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active
                          ? MerchConfig.getAccentColor(widget.item.id)
                          : Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          '${_currentPage + 1} of ${validUrls.length}',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildImage(String url, {required bool cover}) {
    return Image.network(
      url,
      fit: cover ? BoxFit.cover : BoxFit.contain,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: MerchConfig.getAccentColor(widget.item.id),
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Icon(
      MerchConfig.getPlaceholderIcon(widget.item.id),
      size: widget.iconSize,
      color: MerchConfig.getAccentColor(widget.item.id),
    );
  }
}

// ---------------------------------------------------------------------------
// Carousel arrow button
// ---------------------------------------------------------------------------

class _CarouselArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CarouselArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black45,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Lightbox — private fullscreen image viewer
// ---------------------------------------------------------------------------

class _LightboxDialog extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;
  final Color accentColor;

  const _LightboxDialog({
    required this.urls,
    required this.initialIndex,
    required this.accentColor,
  });

  @override
  State<_LightboxDialog> createState() => _LightboxDialogState();
}

class _LightboxDialogState extends State<_LightboxDialog> {
  late final PageController _ctrl;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _ctrl = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Tap outside image area to dismiss
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.transparent),
            ),

            // Full-screen image PageView
            PageView.builder(
              controller: _ctrl,
              itemCount: widget.urls.length,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (_, i) => Image.network(
                widget.urls[i],
                fit: BoxFit.contain,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: widget.accentColor,
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, color: Colors.white38, size: 64),
                ),
              ),
            ),

            // Close button — top right
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),

            // Left arrow
            if (_current > 0)
              Positioned(
                left: 16,
                child: GestureDetector(
                  onTap: () => _ctrl.previousPage(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                  ),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
                    ),
                  ),
                ),
              ),

            // Right arrow
            if (_current < widget.urls.length - 1)
              Positioned(
                right: 16,
                child: GestureDetector(
                  onTap: () => _ctrl.nextPage(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                  ),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(Icons.chevron_right, color: Colors.white, size: 32),
                    ),
                  ),
                ),
              ),

            // Counter pill — bottom center
            if (widget.urls.length > 1)
              Positioned(
                bottom: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    '${_current + 1} / ${widget.urls.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      letterSpacing: 1,
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
