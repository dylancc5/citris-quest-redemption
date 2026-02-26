import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/constants/merch_config.dart';
import '../../../backend/domain/models/merch_item.dart';

/// Displays merch product images loaded from remote URLs (via asset_metadata),
/// with a PageView carousel for multiple photos and automatic fallback to
/// placeholder icons when no images are available or loaded.
///
/// [imageUrls]   — ordered list of public image URLs for this item.
///                 Pass an empty list to always show the placeholder icon.
/// [showCarousel] — true in detail screen (enables paging + dot indicators);
///                  false in grid cards (shows only the first image, no dots).
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

  @override
  Widget build(BuildContext context) {
    final validUrls = widget.imageUrls.where((u) => u.isNotEmpty).toList();

    if (validUrls.isEmpty) {
      return _buildPlaceholder();
    }

    if (!widget.showCarousel || validUrls.length == 1) {
      return _buildImage(validUrls.first);
    }

    // Carousel with dot indicators
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: validUrls.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => _buildImage(validUrls[i]),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(validUrls.length, (i) {
            final active = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 10 : 6,
              height: active ? 10 : 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active
                    ? MerchConfig.getAccentColor(widget.item.id)
                    : AppTheme.backgroundSecondary,
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.contain,
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
