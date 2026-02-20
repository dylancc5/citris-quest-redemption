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
import '../widgets/navigation/merch_nav_bar.dart';
import 'cart_screen.dart';
import 'login_screen.dart';
import 'order_history_screen.dart';

/// Item detail screen with two-panel layout and quantity selector
class ItemDetailScreen extends StatefulWidget {
  final MerchItem item;

  const ItemDetailScreen({super.key, required this.item});

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

  void _addToCart() {
    // Require login before adding to cart
    if (!AuthService().isLoggedInNotifier.value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to add items to your cart'),
          backgroundColor: Colors.red,
        ),
      );
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

    try {
      // Add items based on quantity
      for (int i = 0; i < _quantity; i++) {
        CartService().addItem(widget.item, size: _selectedSize);
      }

      // Show inline success message
      setState(() => _showSuccessMessage = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _showSuccessMessage = false);
        }
      });
    } catch (e, stackTrace) {
      debugPrint('_addToCart error: $e');
      debugPrint('Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding to cart: $e'),
          backgroundColor: Colors.red,
        ),
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
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: Center(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(
                  isMobile ? 16 : 24,
                ),
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
        Expanded(
          flex: 2,
          child: _buildProductImage(accentColor),
        ),
        const SizedBox(width: 32),
        Expanded(
          flex: 3,
          child: _buildProductDetails(accentColor),
        ),
      ],
    );
  }

  Widget _buildProductImage(Color accentColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.cardBackgroundGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(40),
      child: AspectRatio(
        aspectRatio: 1,
        child: Icon(
          MerchConfig.getPlaceholderIcon(widget.item.id),
          size: 120,
          color: accentColor,
        ),
      ),
    );
  }

  Widget _buildProductDetails(Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Name
        Text(
          widget.item.name,
          style: AppTypography.largeTitle(context),
        ),
        const SizedBox(height: 16),

        // Description
        Text(
          widget.item.description,
          style: AppTypography.body(context).copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 24),

        // Price
        Row(
          children: [
            Icon(
              Icons.monetization_on,
              color: AppTheme.yellowPrimary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              '${widget.item.coinPrice} coins',
              style: AppTypography.title1(context).copyWith(
                color: AppTheme.yellowPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Balance
        ValueListenableBuilder(
          valueListenable: AuthService().isLoggedInNotifier,
          builder: (context, isLoggedIn, _) {
            if (!isLoggedIn) {
              return Text(
                'Log in to view your balance',
                style: AppTypography.caption1(context).copyWith(
                  color: Colors.white54,
                ),
              );
            }

            return Row(
              children: [
                Text(
                  'Your balance: ',
                  style: AppTypography.caption1(context).copyWith(
                    color: Colors.white54,
                  ),
                ),
                BalanceDisplay(size: BalanceSize.small),
              ],
            );
          },
        ),
        const SizedBox(height: 32),

        // Size selector (if shirt)
        if (widget.item.requiresSize) ...[
          Text(
            'Select Size',
            style: AppTypography.title2(context),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: widget.item.sizes!.map((size) {
              final isSelected = _selectedSize == size;
              return InkWell(
                onTap: () => setState(() => _selectedSize = size),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accentColor.withValues(alpha: 0.2)
                        : AppTheme.backgroundSecondary,
                    border: Border.all(
                      color: isSelected
                          ? accentColor
                          : accentColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.4),
                              blurRadius: 12,
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    size,
                    style: AppTypography.title3(context).copyWith(
                      color: isSelected ? accentColor : Colors.white,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
        ],

        // Quantity selector
        Text(
          'Quantity',
          style: AppTypography.title2(context),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: _quantity > 1
                  ? () => setState(() => _quantity--)
                  : null,
              color: AppTheme.cyanAccent,
              iconSize: 32,
            ),
            Container(
              width: 60,
              alignment: Alignment.center,
              child: Text(
                '$_quantity',
                style: AppTypography.title1(context),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => setState(() => _quantity++),
              color: AppTheme.cyanAccent,
              iconSize: 32,
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Success message
        if (_showSuccessMessage)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppTheme.greenPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.greenPrimary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.greenPrimary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$_quantity ${widget.item.name}${_quantity > 1 ? 's' : ''} added to cart!',
                    style: TextStyle(color: AppTheme.greenPrimary),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                  child: const Text('View Cart'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.greenPrimary,
                  ),
                ),
              ],
            ),
          ),

        // Add to cart button
        PrimaryButton(
          text: 'Add to Cart',
          onPressed: _addToCart,
          borderColor: accentColor,
          textColor: accentColor,
        ),
        const SizedBox(height: 16),

        // Back button
        Center(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Shopping'),
          ),
        ),
      ],
    );
  }
}
