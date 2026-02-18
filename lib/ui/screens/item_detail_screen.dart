import 'package:flutter/foundation.dart';
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
import '../widgets/navigation/merch_nav_bar.dart';
import 'cart_screen.dart';
import 'login_screen.dart';
import 'order_history_screen.dart';

/// Item detail screen with size selector for shirts
class ItemDetailScreen extends StatefulWidget {
  final MerchItem item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  String? _selectedSize;

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
      CartService().addItem(widget.item, size: _selectedSize);
      debugPrint('CartService: items after add: ${CartService().items.length}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.item.name} added to cart!'),
          backgroundColor: AppTheme.greenPrimary,
          duration: const Duration(seconds: 2),
        ),
      );
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
          thickness: 6,
          radius: const Radius.circular(3),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                Breakpoints.isMobile(context) ? 16 : 24,
                Breakpoints.isMobile(context) ? 16 : 24,
                Breakpoints.isMobile(context) ? 10 : 18,
                Breakpoints.isMobile(context) ? 16 : 24,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Product image/icon
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final imageHeight = Breakpoints.isMobile(context)
                          ? constraints.maxWidth * 0.45
                          : 200.0;
                      final iconSize = Breakpoints.isMobile(context) ? 80.0 : 120.0;
                      return Container(
                        height: imageHeight,
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundSecondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          MerchConfig.getPlaceholderIcon(widget.item.id),
                          size: iconSize,
                          color: AppTheme.bluePrimary,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Name
                  Text(
                    widget.item.name,
                    style: AppTypography.largeTitle(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    widget.item.description,
                    style: AppTypography.body(context).copyWith(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.monetization_on, color: AppTheme.yellowPrimary),
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
                  ValueListenableBuilder(
                    valueListenable: AuthService().xpNotifier,
                    builder: (context, xp, _) {
                      return ValueListenableBuilder(
                        valueListenable: AuthService().coinsNotifier,
                        builder: (context, coins, _) {
                          return Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 4,
                            children: [
                              Text(
                                'Your balance: ',
                                style: AppTypography.caption1(context).copyWith(
                                  color: Colors.white54,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star, color: AppTheme.cyanAccent, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$xp XP',
                                    style: AppTypography.caption1(context).copyWith(
                                      color: AppTheme.cyanAccent,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.monetization_on, color: AppTheme.yellowPrimary, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$coins coins',
                                    style: AppTypography.caption1(context).copyWith(
                                      color: AppTheme.yellowPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
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
                      alignment: WrapAlignment.center,
                      children: widget.item.sizes!.map((size) {
                        final isSelected = _selectedSize == size;
                        final sizeBoxDim = Breakpoints.isMobile(context) ? 50.0 : 60.0;
                        return InkWell(
                          onTap: () => setState(() => _selectedSize = size),
                          child: Container(
                            width: sizeBoxDim,
                            height: sizeBoxDim,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.cyanAccent.withOpacity(0.2)
                                  : AppTheme.backgroundSecondary,
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.cyanAccent
                                    : AppTheme.cyanAccent.withOpacity(0.3),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.cyanAccent.withOpacity(0.4),
                                        blurRadius: 12,
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              size,
                              style: AppTypography.title3(context).copyWith(
                                color: isSelected
                                    ? AppTheme.cyanAccent
                                    : Colors.white,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Add to cart button
                  PrimaryButton(
                    text: 'Add to Cart',
                    onPressed: _addToCart,
                  ),
                  const SizedBox(height: 16),

                  // Back button
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Continue Shopping'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
      ),
      ),
    );
  }
}
