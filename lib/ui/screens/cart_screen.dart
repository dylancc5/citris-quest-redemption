import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/typography.dart';
import '../../core/breakpoints.dart';
import '../../core/constants/merch_config.dart';
import '../../backend/services/cart_service.dart';
import '../../backend/domain/models/cart_item.dart';
import '../../backend/data/auth_service.dart';
import '../../widgets/common/animated_starfield.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/balance_display.dart';
import '../../widgets/common/svg_icon.dart';
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
        child: ValueListenableBuilder<List<CartItem>>(
          valueListenable: CartService().cartItemsNotifier,
          builder: (context, items, _) {
            if (items.isEmpty) {
              return _buildEmptyCart(context);
            }

            return Column(
              children: [
                // Scrollable cart items list
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      Breakpoints.isMobile(context) ? 12 : 16,
                      Breakpoints.isMobile(context) ? 12 : 16,
                      Breakpoints.isMobile(context) ? 12 : 16,
                      Breakpoints.isMobile(context) ? 12 : 16,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final cartItem = items[index];
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 700),
                          child: _CartItemCard(cartItem: cartItem),
                        ),
                      );
                    },
                  ),
                ),

                // Fixed cart summary at bottom
                _buildCartSummary(context, items.length),
              ],
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
          // Space Invader icon
          SvgIcon(
            'space_invader',
            size: 88,
            color: AppTheme.cyanAccent.withValues(alpha: 0.3),
            fallbackIcon: Icons.videogame_asset,
          ),
          const SizedBox(height: 32),
          Text(
            'Your cart is empty',
            style: AppTypography.title1(context).copyWith(
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Browse Merch',
            onPressed: () => Navigator.pop(context),
            height: 50,
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, int itemCount) {
    final isMobile = Breakpoints.isMobile(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final isCompact = screenHeight < 700;
    final totalCost = CartService().totalCost;

    return Container(
      padding: EdgeInsets.all(isCompact ? 8 : (isMobile ? 12 : 16)),
      decoration: BoxDecoration(
        gradient: AppTheme.cardBackgroundGradient,
        border: Border(
          top: BorderSide(
            color: AppTheme.cyanAccent.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cyanAccent.withValues(alpha: 0.2),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your balance',
                  style: AppTypography.caption1(context).copyWith(
                    color: Colors.white54,
                  ),
                ),
                BalanceDisplay(size: BalanceSize.small),
              ],
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
                      '$totalCost',
                      style: AppTypography.title1(context).copyWith(
                        color: AppTheme.yellowPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: isCompact ? 6 : 12),

            // Balance projection (after purchase)
            ValueListenableBuilder<int>(
              valueListenable: AuthService().coinsNotifier,
              builder: (context, coins, _) {
                final remaining = coins - totalCost;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'After purchase',
                      style: AppTypography.caption1(context).copyWith(
                        color: Colors.white54,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.monetization_on,
                          color: remaining >= 0 ? AppTheme.yellowPrimary : Colors.red,
                          size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$remaining remaining',
                          style: AppTypography.caption1(context).copyWith(
                            color: remaining >= 0 ? AppTheme.yellowPrimary : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: isCompact ? 8 : 16),

            // Locked warning banner
            ValueListenableBuilder<bool>(
              valueListenable: AuthService().isLoggedInNotifier,
              builder: (context, isLoggedIn, _) {
                if (!isLoggedIn) return const SizedBox.shrink();
                return ValueListenableBuilder<int>(
                  valueListenable: AuthService().xpNotifier,
                  builder: (context, xp, _) {
                    return ValueListenableBuilder<int>(
                      valueListenable: AuthService().coinsNotifier,
                      builder: (context, coins, _) {
                        final hasEnoughXp = xp >= MerchConfig.xpGateThreshold;
                        final hasEnoughCoins = coins >= totalCost;
                        if (hasEnoughXp && hasEnoughCoins) {
                          return const SizedBox.shrink();
                        }
                        final message = !hasEnoughXp
                            ? 'LOCKED: Need ${MerchConfig.xpGateThreshold - xp} more XP to unlock merch'
                            : 'Insufficient coins: need ${totalCost - coins} more';
                        return Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: (!hasEnoughXp
                                    ? AppTheme.redPrimary
                                    : AppTheme.yellowPrimary)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: (!hasEnoughXp
                                      ? AppTheme.redPrimary
                                      : AppTheme.yellowPrimary)
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                !hasEnoughXp
                                    ? Icons.lock
                                    : Icons.monetization_on,
                                color: !hasEnoughXp
                                    ? AppTheme.redPrimary
                                    : AppTheme.yellowPrimary,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  message,
                                  style: AppTypography.caption1(context).copyWith(
                                    color: !hasEnoughXp
                                        ? AppTheme.redPrimary
                                        : AppTheme.yellowPrimary,
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
            ),

            // Checkout button — disabled when locked
            ValueListenableBuilder<bool>(
              valueListenable: AuthService().isLoggedInNotifier,
              builder: (context, isLoggedIn, _) {
                return ValueListenableBuilder<int>(
                  valueListenable: AuthService().xpNotifier,
                  builder: (context, xp, _) {
                    return ValueListenableBuilder<int>(
                      valueListenable: AuthService().coinsNotifier,
                      builder: (context, coins, _) {
                        final isLocked = isLoggedIn &&
                            (xp < MerchConfig.xpGateThreshold ||
                                coins < totalCost);
                        return PrimaryButton(
                          text: isLocked ? 'LOCKED' : 'Proceed to Checkout',
                          height: isCompact ? 50.0 : 60.0,
                          onPressed:
                              isLocked ? null : () => _handleCheckout(context),
                          borderColor:
                              isLocked ? AppTheme.redPrimary : null,
                          textColor:
                              isLocked ? AppTheme.redPrimary : null,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleCheckout(BuildContext context) {
    // Check if user is logged in
    if (!AuthService().isLoggedInNotifier.value) {
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
  final CartItem cartItem;

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
          color: AppTheme.cyanAccent.withValues(alpha: 0.3),
          width: 2,
        ),
        // Accent color stripe on left
        boxShadow: [
          BoxShadow(
            color: AppTheme.bluePrimary.withValues(alpha: 0.3),
            offset: const Offset(-4, 0),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: AppTheme.bluePrimary,
              width: 4,
            ),
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
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
                    cartItem.item.placeholderIcon,
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
                              '${cartItem.item.coinPrice} \u00d7 ${cartItem.quantity} = ${cartItem.subtotal}',
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
      ),
    );
  }
}
