import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/typography.dart';
import '../../core/breakpoints.dart';
import '../../core/constants/merch_config.dart';
import '../../backend/services/cart_service.dart';
import '../../backend/data/auth_service.dart';
import '../../widgets/common/animated_starfield.dart';
import '../../widgets/common/primary_button.dart';
import '../widgets/navigation/merch_nav_bar.dart';
import 'login_screen.dart';
import 'checkout_screen.dart';
import 'order_history_screen.dart';

/// Cart screen with quantity editor and checkout button
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MerchNavBar(
        title: 'Shopping Cart',
        isSubPage: true,
        onOrdersTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
        ),
      ),
      body: AnimatedStarfield(
        child: ValueListenableBuilder(
          valueListenable: CartService().cartItemsNotifier,
          builder: (context, items, _) {
            if (items.isEmpty) {
              return _buildEmptyCart(context);
            }

            return Scrollbar(
              thickness: 6,
              radius: const Radius.circular(3),
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: CustomScrollView(
                  slivers: [
                  // Cart items list
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      Breakpoints.isMobile(context) ? 12 : 16,
                      Breakpoints.isMobile(context) ? 12 : 16,
                      Breakpoints.isMobile(context) ? 6 : 10,
                      Breakpoints.isMobile(context) ? 12 : 16,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final cartItem = items[index];
                          return Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 700),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: _CartItemCard(cartItem: cartItem),
                              ),
                            ),
                          );
                        },
                        childCount: items.length,
                      ),
                    ),
                  ),

                  // Push cart summary to bottom
                  SliverFillRemaining(
                    hasScrollBody: false,
                    fillOverscroll: true,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: _buildCartSummary(context, items.length),
                    ),
                  ),
                ],
              ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.white30,
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: AppTypography.title1(context).copyWith(
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, int itemCount) {
    final isMobile = Breakpoints.isMobile(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final isCompact = screenHeight < 700;

    return Container(
      padding: EdgeInsets.all(isCompact ? 8 : (isMobile ? 12 : 16)),
      decoration: BoxDecoration(
        gradient: AppTheme.cardBackgroundGradient,
        border: Border(
          top: BorderSide(
            color: AppTheme.cyanAccent.withOpacity(0.3),
            width: 2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cyanAccent.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Your balance
            ValueListenableBuilder(
              valueListenable: AuthService().xpNotifier,
              builder: (context, xp, _) {
                return ValueListenableBuilder(
                  valueListenable: AuthService().coinsNotifier,
                  builder: (context, coins, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your balance',
                          style: AppTypography.caption1(context).copyWith(
                            color: Colors.white54,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, color: AppTheme.cyanAccent, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '$xp XP',
                              style: AppTypography.caption1(context).copyWith(
                                color: AppTheme.cyanAccent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.monetization_on, color: AppTheme.yellowPrimary, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '$coins',
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
            SizedBox(height: isCompact ? 6 : 12),

            // Total items and cost
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total ($itemCount ${itemCount == 1 ? 'item' : 'items'})',
                  style: AppTypography.title2(context),
                ),
                Row(
                  children: [
                    Icon(Icons.monetization_on, color: AppTheme.yellowPrimary, size: isCompact ? 20 : 24),
                    const SizedBox(width: 8),
                    Text(
                      '${CartService().totalCost}',
                      style: AppTypography.title1(context).copyWith(
                        color: AppTheme.yellowPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: isCompact ? 8 : 16),

            // Checkout button
            PrimaryButton(
              text: 'Proceed to Checkout',
              height: isCompact ? 50.0 : 60.0,
              onPressed: () => _handleCheckout(context),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCheckout(BuildContext context) {
    // Check if user is logged in
    if (!AuthService().isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    // Navigate to checkout
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
    );
  }
}

/// Individual cart item card with quantity controls
class _CartItemCard extends StatelessWidget {
  final dynamic cartItem;

  const _CartItemCard({required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isCompact = screenWidth < 480 || screenHeight < 700;
    final iconBoxSize = isCompact ? 40.0 : 60.0;
    final iconSize = isCompact ? 22.0 : 32.0;
    final qtyIconSize = isCompact ? 20.0 : 28.0;

    return Container(
      margin: EdgeInsets.only(bottom: isCompact ? 8 : 16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardBackgroundGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.cyanAccent.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 8 : 16),
        child: Column(
          children: [
            Row(
              children: [
                // Product icon
                Container(
                  width: iconBoxSize,
                  height: iconBoxSize,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundSecondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    MerchConfig.getPlaceholderIcon(cartItem.item.id),
                    color: AppTheme.bluePrimary,
                    size: iconSize,
                  ),
                ),
                SizedBox(width: isCompact ? 10 : 16),

                // Product info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cartItem.item.name,
                        style: AppTypography.title3(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (cartItem.selectedSize != null) ...[
                        SizedBox(height: isCompact ? 2 : 4),
                        Text(
                          'Size: ${cartItem.selectedSize}',
                          style: AppTypography.caption1(context).copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                      SizedBox(height: isCompact ? 4 : 8),
                      Row(
                        children: [
                          Icon(
                            Icons.monetization_on,
                            color: AppTheme.yellowPrimary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${cartItem.item.coinPrice} × ${cartItem.quantity} = ${cartItem.subtotal}',
                              style: AppTypography.body(context).copyWith(
                                color: AppTheme.yellowPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Quantity controls (inline on wider screens)
                if (!isCompact)
                  Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              CartService().updateQuantity(
                                cartItem.id,
                                cartItem.quantity - 1,
                              );
                            },
                            color: AppTheme.cyanAccent,
                            iconSize: qtyIconSize,
                          ),
                          Container(
                            width: 36,
                            alignment: Alignment.center,
                            child: Text(
                              '${cartItem.quantity}',
                              style: AppTypography.title2(context),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              CartService().updateQuantity(
                                cartItem.id,
                                cartItem.quantity + 1,
                              );
                            },
                            color: AppTheme.cyanAccent,
                            iconSize: qtyIconSize,
                          ),
                        ],
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('Remove'),
                        onPressed: () {
                          CartService().removeItem(cartItem.id);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            // Quantity controls row (below on compact screens)
            if (isCompact) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Remove'),
                    onPressed: () {
                      CartService().removeItem(cartItem.id);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          CartService().updateQuantity(
                            cartItem.id,
                            cartItem.quantity - 1,
                          );
                        },
                        color: AppTheme.cyanAccent,
                        iconSize: qtyIconSize,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      Container(
                        width: 36,
                        alignment: Alignment.center,
                        child: Text(
                          '${cartItem.quantity}',
                          style: AppTypography.title2(context),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          CartService().updateQuantity(
                            cartItem.id,
                            cartItem.quantity + 1,
                          );
                        },
                        color: AppTheme.cyanAccent,
                        iconSize: qtyIconSize,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
