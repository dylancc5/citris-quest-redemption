import 'package:flutter/material.dart';
import '../../backend/domain/models/merch_item.dart';
import '../../core/theme.dart';
import '../../core/typography.dart';
import '../../core/breakpoints.dart';
import '../../core/constants/merch_config.dart';
import '../../backend/data/auth_service.dart';
import '../../backend/services/cart_service.dart';
import '../../widgets/common/animated_starfield.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/balance_display.dart';
import '../widgets/merch/merch_image_widget.dart';
import '../widgets/navigation/merch_nav_bar.dart';
import 'cart_screen.dart';
import 'login_screen.dart';
import 'order_history_screen.dart';

/// Item detail screen with two-panel layout and quantity selector
class ItemDetailScreen extends StatefulWidget {
  final MerchItem item;
  final List<String> imageUrls;

  const ItemDetailScreen({
    super.key,
    required this.item,
    this.imageUrls = const [],
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final _scrollController = ScrollController();
  String? _selectedSize;
  int _quantity = 1;
  bool _showSuccessMessage = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Returns null if add-to-cart is allowed, or an error string if blocked
  /// (excluding "please select a size" so the button stays enabled for UX).
  String? _getBlockingReason() {
    if (!AuthService().isLoggedInNotifier.value) {
      return 'Please sign in to add items to your cart';
    }
    if (AuthService().xp < MerchConfig.xpGateThreshold) {
      final remaining = MerchConfig.xpGateThreshold - AuthService().xp;
      return 'You need $remaining more XP to unlock merch redemption';
    }
    final totalCost = widget.item.coinPrice * _quantity;
    if (AuthService().coins < totalCost) {
      final shortage = totalCost - AuthService().coins;
      return 'You need $shortage more coins for this order';
    }
    return null;
  }

  void _addToCart() {
    if (!AuthService().isLoggedInNotifier.value) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    if (widget.item.requiresSize && _selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a size'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final blockReason = _getBlockingReason();
    if (blockReason != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(blockReason), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      for (int i = 0; i < _quantity; i++) {
        CartService().addItem(widget.item, size: _selectedSize);
      }
      setState(() => _showSuccessMessage = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showSuccessMessage = false);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding to cart: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = MerchConfig.getAccentColor(widget.item.id);
    final isMobile = Breakpoints.isMobile(context);

    return Scaffold(
      appBar: MerchNavBar(
        title: widget.item.name,
        isSubPage: true,
        onCartTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartScreen()),
        ),
        onOrdersTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
        ),
      ),
      body: AnimatedStarfield(
        child: Scrollbar(
          controller: _scrollController,
          thickness: 6,
          radius: const Radius.circular(3),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: Center(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: isMobile
                      ? _buildSingleColumnLayout(accentColor)
                      : _buildTwoPanelLayout(accentColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSingleColumnLayout(Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildProductImage(accentColor),
        const SizedBox(height: 24),
        _buildProductDetails(accentColor),
      ],
    );
  }

  Widget _buildTwoPanelLayout(Color accentColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 1, child: _buildProductImage(accentColor)),
        const SizedBox(width: 40),
        Expanded(flex: 2, child: _buildProductDetails(accentColor)),
      ],
    );
  }

  Widget _buildProductImage(Color accentColor) {
    final isMobile = Breakpoints.isMobile(context);
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: AppTheme.cardBackgroundGradient,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 2),
            boxShadow: [
              BoxShadow(color: accentColor.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 2),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: isMobile ? 320 : 400,
              child: MerchImageWidget(
                item: widget.item,
                imageUrls: widget.imageUrls,
                showCarousel: true,
                iconSize: 120,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Tap image to view full screen',
          style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 0.3),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProductDetails(Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Name
        Text(widget.item.name, style: AppTypography.largeTitle(context)),
        const SizedBox(height: 12),

        // Price — prominent
        Row(
          children: [
            Icon(Icons.monetization_on, color: AppTheme.yellowPrimary, size: 28),
            const SizedBox(width: 8),
            Text(
              '${widget.item.coinPrice} coins',
              style: AppTypography.title1(context).copyWith(color: AppTheme.yellowPrimary),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Description
        Text(
          widget.item.description,
          style: AppTypography.body(context).copyWith(color: Colors.white70),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Divider(color: AppTheme.cyanAccent.withValues(alpha: 0.2)),
        ),

        // Size selector
        if (widget.item.requiresSize) ...[
          Text('Select Size', style: AppTypography.title3(context)),
          const SizedBox(height: 12),
          _buildSizeSelector(accentColor),
          const SizedBox(height: 16),
        ],

        // Quantity selector
        Text('Quantity', style: AppTypography.title3(context)),
        const SizedBox(height: 12),
        _buildQuantitySelector(),
        const SizedBox(height: 16),

        // XP gate warning (if locked, only when logged in)
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: _buildXpGateWarning(),
        ),

        // Coin shortage warning (only after XP gate passed)
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: _buildCoinWarning(),
        ),

        // Balance row — subtle, just above button
        ValueListenableBuilder<bool>(
          valueListenable: AuthService().isLoggedInNotifier,
          builder: (context, isLoggedIn, _) {
            if (!isLoggedIn) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Your balance: ',
                    style: AppTypography.caption1(context).copyWith(color: Colors.white54),
                  ),
                  const BalanceDisplay(size: BalanceSize.small),
                ],
              ),
            );
          },
        ),

        // Success message
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _showSuccessMessage
              ? _buildSuccessMessage()
              : const SizedBox.shrink(),
        ),

        // Add to Cart button — reactive to lock state
        ValueListenableBuilder<bool>(
          valueListenable: AuthService().isLoggedInNotifier,
          builder: (context, isLoggedIn, _) {
            return ValueListenableBuilder<int>(
              valueListenable: AuthService().xpNotifier,
              builder: (context, xp, _) {
                return ValueListenableBuilder<int>(
                  valueListenable: AuthService().coinsNotifier,
                  builder: (context, coins, _) {
                    final blockReason = _getBlockingReason();
                    final isHardBlocked = isLoggedIn && blockReason != null;
                    final label = !isLoggedIn
                        ? 'Sign In to Add'
                        : isHardBlocked
                            ? 'LOCKED'
                            : 'Add to Cart';
                    return PrimaryButton(
                      text: label,
                      onPressed: isHardBlocked ? null : _addToCart,
                      borderColor: isHardBlocked ? AppTheme.redPrimary : accentColor,
                      textColor: isHardBlocked ? AppTheme.redPrimary : accentColor,
                    );
                  },
                );
              },
            );
          },
        ),

        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: AppTheme.cyanAccent),
            child: Text(
              'Continue Shopping',
              style: AppTypography.body(context).copyWith(color: AppTheme.cyanAccent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeSelector(Color accentColor) {
    final isMobile = Breakpoints.isMobile(context);
    final boxSize = isMobile ? 48.0 : 60.0;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: widget.item.sizes!.map((size) {
        final isSelected = _selectedSize == size;
        return GestureDetector(
          onTap: () => setState(() => _selectedSize = size),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: boxSize,
              height: boxSize,
              decoration: BoxDecoration(
                color: isSelected
                    ? accentColor.withValues(alpha: 0.2)
                    : AppTheme.backgroundSecondary,
                border: Border.all(
                  color: isSelected ? accentColor : accentColor.withValues(alpha: 0.3),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: isSelected
                    ? [BoxShadow(color: accentColor.withValues(alpha: 0.4), blurRadius: 12)]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                size,
                style: AppTypography.title3(context).copyWith(
                  color: isSelected ? accentColor : Colors.white,
                  height: 1.0,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuantitySelector() {
    final isMobile = Breakpoints.isMobile(context);
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
          color: AppTheme.cyanAccent,
          iconSize: isMobile ? 28 : 32,
        ),
        Container(
          width: 56,
          alignment: Alignment.center,
          child: Text('$_quantity', style: AppTypography.title1(context)),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => setState(() => _quantity++),
          color: AppTheme.cyanAccent,
          iconSize: isMobile ? 28 : 32,
        ),
        const SizedBox(width: 8),
        ValueListenableBuilder<bool>(
          valueListenable: AuthService().isLoggedInNotifier,
          builder: (context, isLoggedIn, _) {
            if (!isLoggedIn || _quantity <= 1) return const SizedBox.shrink();
            return Flexible(
              child: Text(
                '= ${widget.item.coinPrice * _quantity} coins total',
                style: AppTypography.caption1(context).copyWith(color: AppTheme.yellowPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildXpGateWarning() {
    return ValueListenableBuilder<bool>(
      valueListenable: AuthService().isLoggedInNotifier,
      builder: (context, isLoggedIn, _) {
        if (!isLoggedIn) return const SizedBox.shrink();
        return ValueListenableBuilder<int>(
          valueListenable: AuthService().xpNotifier,
          builder: (context, xp, _) {
            if (xp >= MerchConfig.xpGateThreshold) return const SizedBox.shrink();
            final remaining = MerchConfig.xpGateThreshold - xp;
            final progress = (xp / MerchConfig.xpGateThreshold).clamp(0.0, 1.0);
            return Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.redPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.redPrimary.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lock, color: AppTheme.redPrimary, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'LOCKED — Need $remaining more XP to unlock',
                          style: AppTypography.caption1(context).copyWith(
                            color: AppTheme.redPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppTheme.backgroundSecondary,
                      valueColor: AlwaysStoppedAnimation(AppTheme.cyanAccent),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$xp / ${MerchConfig.xpGateThreshold} XP',
                    style: AppTypography.caption2(context).copyWith(color: Colors.white54),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCoinWarning() {
    return ValueListenableBuilder<bool>(
      valueListenable: AuthService().isLoggedInNotifier,
      builder: (context, isLoggedIn, _) {
        if (!isLoggedIn) return const SizedBox.shrink();
        return ValueListenableBuilder<int>(
          valueListenable: AuthService().xpNotifier,
          builder: (context, xp, _) {
            if (xp < MerchConfig.xpGateThreshold) return const SizedBox.shrink();
            return ValueListenableBuilder<int>(
              valueListenable: AuthService().coinsNotifier,
              builder: (context, coins, _) {
                final totalCost = widget.item.coinPrice * _quantity;
                if (coins >= totalCost) return const SizedBox.shrink();
                final shortage = totalCost - coins;
                return Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.yellowPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.yellowPrimary.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.monetization_on, color: AppTheme.yellowPrimary, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'You need $shortage more coins for this order',
                          style: AppTypography.caption1(context).copyWith(
                            color: AppTheme.yellowPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.greenPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.greenPrimary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppTheme.greenPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$_quantity ${widget.item.name}${_quantity > 1 ? 's' : ''} added to cart!',
              style: AppTypography.body(context).copyWith(color: AppTheme.greenPrimary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
            style: TextButton.styleFrom(foregroundColor: AppTheme.greenPrimary),
            child: Text('View Cart', style: AppTypography.body(context).copyWith(color: AppTheme.greenPrimary)),
          ),
        ],
      ),
    );
  }
}
