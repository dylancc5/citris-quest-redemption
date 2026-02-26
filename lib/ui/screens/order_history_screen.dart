import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/typography.dart';
import '../../backend/data/auth_service.dart';
import '../../backend/data/merch_orders_service.dart';
import '../../backend/domain/models/merch_order.dart';
import '../../widgets/common/animated_starfield.dart';
import '../../widgets/common/balance_display.dart';
import '../widgets/navigation/merch_nav_bar.dart';
import 'cart_screen.dart';

/// Order history screen showing past orders
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final _scrollController = ScrollController();
  List<MerchOrder>? _orders;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    if (!AuthService().isLoggedIn) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please log in to view your orders';
      });
      return;
    }

    try {
      final orders = await MerchOrdersService().getUserOrders(
        AuthService().userId!,
      );

      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              "Hmm, we couldn't load your orders right now. Give it another try!";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MerchNavBar(
        title: 'My Orders',
        isSubPage: true,
        onCartTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CartScreen()),
        ),
      ),
      body: AnimatedStarfield(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingSkeleton();
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: AppTypography.title2(context).copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadOrders();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.cyanAccent,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_orders == null || _orders!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 100, color: Colors.white30),
            const SizedBox(height: 24),
            Text(
              'No orders yet',
              style: AppTypography.title1(
                context,
              ).copyWith(color: Colors.white54),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Start Shopping'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: Scrollbar(
        controller: _scrollController,
        thickness: 6,
        radius: const Radius.circular(3),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 16, 10, 16),
            itemCount: _orders!.length + 1,
            itemBuilder: (context, index) {
              // Index 0 = balance header
              if (index == 0) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6, bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
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
                              'Current balance',
                              style: AppTypography.caption1(context).copyWith(
                                color: Colors.white54,
                              ),
                            ),
                            const BalanceDisplay(
                              size: BalanceSize.small,
                              showXp: true,
                              showCoins: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              final order = _orders![index - 1];
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _OrderCard(order: order),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 3,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 120,
              decoration: BoxDecoration(
                gradient: AppTheme.cardBackgroundGradient,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.cyanAccent.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Individual order card
class _OrderCard extends StatelessWidget {
  final MerchOrder order;

  const _OrderCard({required this.order});

  Color _getStatusColor() {
    switch (order.status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.processing:
        return AppTheme.bluePrimary;
      case OrderStatus.shipped:
        return AppTheme.cyanAccent;
      case OrderStatus.delivered:
        return AppTheme.greenPrimary;
      case OrderStatus.failed:
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText() {
    switch (order.status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.failed:
        return 'Failed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardBackgroundGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.cyanAccent.withValues(alpha:0.3),
          width: 2,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.id.substring(0, 8).toUpperCase()}',
                    style: AppTypography.title3(context),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${order.createdAt.month}/${order.createdAt.day}/${order.createdAt.year}',
                    style: AppTypography.caption1(
                      context,
                    ).copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor().withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getStatusColor().withValues(alpha:0.5)),
              ),
              child: Text(
                _getStatusText(),
                style: AppTypography.caption2(context).copyWith(
                  color: _getStatusColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Icon(
                Icons.monetization_on,
                color: AppTheme.yellowPrimary,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${order.totalCoins} coins',
                style: AppTypography.body(
                  context,
                ).copyWith(color: AppTheme.yellowPrimary),
              ),
              const SizedBox(width: 16),
              Text(
                '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                style: AppTypography.body(
                  context,
                ).copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
        children: [
          const Divider(),
          const SizedBox(height: 8),

          // Items list
          ...order.items.map(
            (item) => Padding(
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
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item.subtotal}',
                        style: AppTypography.caption1(
                          context,
                        ).copyWith(color: AppTheme.yellowPrimary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Shipping address
          ...[
            const Divider(),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.local_shipping,
                  size: 16,
                  color: Colors.white70,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.shippingAddress.toString(),
                    style: AppTypography.caption1(
                      context,
                    ).copyWith(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ],

          // Tracking number (if available)
          if (order.trackingNumber != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.local_shipping,
                  size: 16,
                  color: Colors.white70,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tracking: ${order.trackingNumber}',
                  style: AppTypography.caption1(
                    context,
                  ).copyWith(color: AppTheme.cyanAccent),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
