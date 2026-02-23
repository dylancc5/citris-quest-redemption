import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme.dart';
import '../../core/typography.dart';
import '../../backend/data/auth_service.dart';
import '../../backend/domain/models/merch_order.dart';
import '../../widgets/common/animated_starfield.dart';
import '../../widgets/common/balance_display.dart';
import '../../widgets/common/primary_button.dart';
import '../widgets/navigation/merch_nav_bar.dart';
import 'cart_screen.dart';
import 'landing_screen.dart';
import 'order_history_screen.dart';

/// Success screen showing order confirmation
class SuccessScreen extends StatefulWidget {
  final MerchOrder order;

  const SuccessScreen({super.key, required this.order});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _confettiController;
  final List<ConfettiParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Generate confetti particles
    final random = math.Random();
    for (int i = 0; i < 30; i++) {
      _particles.add(ConfettiParticle(
        x: random.nextDouble(),
        y: -0.1,
        vx: (random.nextDouble() - 0.5) * 0.3,
        vy: random.nextDouble() * 0.5 + 0.3,
        color: [
          AppTheme.cyanAccent,
          AppTheme.yellowPrimary,
          AppTheme.greenPrimary,
          AppTheme.magentaPrimary,
        ][random.nextInt(4)],
        size: random.nextDouble() * 6 + 4,
      ));
    }

    _confettiController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

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
      body: Stack(
        children: [
          AnimatedStarfield(
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
                        color: AppTheme.greenPrimary.withValues(alpha:0.2),
                        border: Border.all(
                          color: AppTheme.greenPrimary,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.greenPrimary.withValues(alpha:0.4),
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
                          color: AppTheme.cyanAccent.withValues(alpha:0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.cyanAccent.withValues(alpha:0.2),
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
                            widget.order.id.substring(0, 8).toUpperCase(),
                          ),
                          const SizedBox(height: 12),

                          // Printify Order ID (truncated)
                          _buildInfoRow(
                            'Printify Order',
                            widget.order.printifyOrderId.length > 12
                                ? '${widget.order.printifyOrderId.substring(0, 12)}...'
                                : widget.order.printifyOrderId,
                          ),
                          const SizedBox(height: 12),

                          // Date
                          _buildInfoRow(
                            'Date',
                            '${widget.order.createdAt.month}/${widget.order.createdAt.day}/${widget.order.createdAt.year}',
                          ),
                          const Divider(height: 32),

                          // Items
                          Text(
                            'Items Ordered',
                            style: AppTypography.title2(context),
                          ),
                          const SizedBox(height: 12),
                          ...widget.order.items.map((item) => Padding(
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
                                    '${widget.order.totalCoins}',
                                    style: AppTypography.title1(context).copyWith(
                                      color: AppTheme.yellowPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Before/After coin comparison
                          ValueListenableBuilder(
                            valueListenable: AuthService().coinsNotifier,
                            builder: (context, coins, _) {
                              final before = coins + widget.order.totalCoins;
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.greenPrimary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppTheme.greenPrimary.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          'Before',
                                          style: AppTypography.caption1(context).copyWith(
                                            color: Colors.white54,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.monetization_on,
                                                color: AppTheme.yellowPrimary, size: 20),
                                            const SizedBox(width: 4),
                                            Text(
                                              '$before',
                                              style: AppTypography.title2(context).copyWith(
                                                color: AppTheme.yellowPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Icon(Icons.arrow_forward, color: AppTheme.cyanAccent),
                                    Column(
                                      children: [
                                        Text(
                                          'After',
                                          style: AppTypography.caption1(context).copyWith(
                                            color: Colors.white54,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.monetization_on,
                                                color: AppTheme.greenPrimary, size: 20),
                                            const SizedBox(width: 4),
                                            Text(
                                              '$coins',
                                              style: AppTypography.title2(context).copyWith(
                                                color: AppTheme.greenPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
                            widget.order.shippingAddress.toString(),
                            style: AppTypography.body(context).copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Remaining balance after purchase
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundSecondary.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.cyanAccent.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Remaining balance',
                            style: AppTypography.caption1(context).copyWith(
                              color: Colors.white54,
                            ),
                          ),
                          const BalanceDisplay(
                            size: BalanceSize.small,
                            showXp: false,
                            showCoins: true,
                            abbreviate: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Info message
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.bluePrimary.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.bluePrimary.withValues(alpha:0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppTheme.bluePrimary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'You can check your order status anytime from the "My Orders" menu.',
                              style: AppTypography.caption1(context).copyWith(color: AppTheme.bluePrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Buttons
                    PrimaryButton(
                      text: 'View My Orders',
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OrderHistoryScreen(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LandingScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.storefront),
                      label: const Text('Return to Shop'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.cyanAccent,
                      ),
                    ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Confetti animation
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return CustomPaint(
                painter: ConfettiPainter(
                  particles: _particles,
                  progress: _confettiController.value,
                ),
                size: Size.infinite,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.caption1(context).copyWith(color: Colors.white70),
        ),
        Flexible(
          child: Text(
            value,
            style: AppTypography.caption1(context).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Confetti particle data
class ConfettiParticle {
  double x;
  double y;
  final double vx;
  final double vy;
  final Color color;
  final double size;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
  });
}

/// Painter for confetti particles
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1.0) return;

    final paint = Paint()..style = PaintingStyle.fill;

    for (var particle in particles) {
      // Update particle position
      particle.y += particle.vy * 0.02;
      particle.x += particle.vx * 0.02;

      // Only draw if still on screen
      if (particle.y < 1.1) {
        paint.color = particle.color.withValues(alpha: 1.0 - progress);

        final px = particle.x * size.width;
        final py = particle.y * size.height;

        canvas.drawRect(
          Rect.fromLTWH(px, py, particle.size, particle.size),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) => true;
}
