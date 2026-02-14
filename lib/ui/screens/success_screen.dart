import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/typography.dart';
import '../../backend/data/auth_service.dart';
import '../../backend/domain/models/merch_order.dart';
import '../../widgets/common/animated_starfield.dart';
import '../../widgets/common/primary_button.dart';
import '../widgets/navigation/merch_nav_bar.dart';
import 'cart_screen.dart';
import 'landing_screen.dart';
import 'order_history_screen.dart';

/// Success screen showing order confirmation
class SuccessScreen extends StatelessWidget {
  final MerchOrder order;

  const SuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MerchNavBar(
        title: 'Order Confirmed',
        isSubPage: true,
        onCartTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CartScreen()),
        ),
        onOrdersTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
        ),
      ),
      body: AnimatedStarfield(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.greenPrimary.withOpacity(0.2),
                        border: Border.all(
                          color: AppTheme.greenPrimary,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.greenPrimary.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: AppTheme.greenPrimary,
                        size: 80,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Success title
                    Text(
                      'Order Confirmed!',
                      style: AppTypography.largeTitle(context).copyWith(
                        color: AppTheme.greenPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Success message
                    Text(
                      'Your order is being prepared for shipment',
                      style: AppTypography.title2(context).copyWith(
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Order details card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppTheme.cardBackgroundGradient,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.cyanAccent.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.cyanAccent.withOpacity(0.2),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Details',
                            style: AppTypography.title1(context),
                          ),
                          const SizedBox(height: 16),

                          // Order ID
                          _buildInfoRow(
                            'Order ID',
                            order.id.substring(0, 8).toUpperCase(),
                          ),
                          const SizedBox(height: 12),

                          // Printify Order ID
                          _buildInfoRow(
                            'Printify Order',
                            order.printifyOrderId,
                          ),
                          const SizedBox(height: 12),

                          // Date
                          _buildInfoRow(
                            'Date',
                            '${order.createdAt.month}/${order.createdAt.day}/${order.createdAt.year}',
                          ),
                          const Divider(height: 32),

                          // Items
                          Text(
                            'Items Ordered',
                            style: AppTypography.title2(context),
                          ),
                          const SizedBox(height: 12),
                          ...order.items.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.itemName}${item.size != null ? ' (${item.size})' : ''} × ${item.quantity}',
                                    style: AppTypography.body(context),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.monetization_on,
                                      color: AppTheme.yellowPrimary,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${item.subtotal}',
                                      style: AppTypography.body(context).copyWith(
                                        color: AppTheme.yellowPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),
                          const Divider(height: 24),

                          // Total
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Coins Spent',
                                style: AppTypography.title2(context),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.monetization_on,
                                    color: AppTheme.yellowPrimary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${order.totalCoins}',
                                    style: AppTypography.title1(context).copyWith(
                                      color: AppTheme.yellowPrimary,
                                    ),
                                  ),
                                ],
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
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Remaining Balance',
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
                          const Divider(height: 24),

                          // Shipping address
                          Text(
                            'Shipping To',
                            style: AppTypography.title2(context),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            order.shippingAddress.toString(),
                            style: AppTypography.body(context).copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Info message
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.bluePrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.bluePrimary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppTheme.bluePrimary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'You can check your order status anytime from the "My Orders" menu.',
                              style: TextStyle(color: AppTheme.bluePrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Return to shop button
                    PrimaryButton(
                      text: 'Return to Shop',
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LandingScreen(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
