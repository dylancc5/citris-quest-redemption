import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/typography.dart';
import '../../../core/constants/merch_config.dart';
import '../../../backend/data/auth_service.dart';
import '../../../backend/domain/models/merch_item.dart';
import '../../../widgets/common/hover_lift_card.dart';
import '../../screens/item_detail_screen.dart';
import 'merch_image_widget.dart';

/// Card displaying a single merch item
class MerchItemCard extends StatelessWidget {
  final MerchItem item;
  final List<String> imageUrls;

  const MerchItemCard({
    super.key,
    required this.item,
    this.imageUrls = const [],
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = MerchConfig.getAccentColor(item.id);

    return ValueListenableBuilder<bool>(
      valueListenable: AuthService().isLoggedInNotifier,
      builder: (context, isLoggedIn, _) {
        return ValueListenableBuilder<int>(
          valueListenable: AuthService().xpNotifier,
          builder: (context, xp, _) {
            final isXpLocked = isLoggedIn && xp < MerchConfig.xpGateThreshold;

            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ItemDetailScreen(item: item, imageUrls: imageUrls),
                ),
              ),
              child: Opacity(
                opacity: isXpLocked ? 0.45 : 1.0,
                child: HoverLiftCard(
                  child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.cardBackgroundGradient,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.2),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image/Icon area — fixed height
              SizedBox(
                height: 140,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundSecondary.withValues(alpha: 0.5),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                  ),
                  child: MerchImageWidget(
                    item: item,
                    imageUrls: imageUrls,
                    showCarousel: false,
                    iconSize: 60,
                  ),
                ),
              ),

              // Content area — sizes to content
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        item.name,
                        style: AppTypography.title3(context).copyWith(
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      // Price row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.monetization_on,
                                color: AppTheme.yellowPrimary,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${item.coinPrice}',
                                style: AppTypography.body(context).copyWith(
                                  color: AppTheme.yellowPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: accentColor,
                            size: 20,
                          ),
                        ],
                      ),

                      // Coin progress bar (only when logged in)
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
                                  final coinProgress =
                                      (coins / item.coinPrice).clamp(0.0, 1.0);
                                  final hasEnoughCoins = coins >= item.coinPrice;
                                  final isReady = hasEnoughXp && hasEnoughCoins;

                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: _buildProgressBar(
                                      context,
                                      label: isReady
                                          ? 'Ready to redeem!'
                                          : '$coins / ${item.coinPrice} coins',
                                      progress: coinProgress,
                                      barColor: isReady
                                          ? AppTheme.greenPrimary
                                          : AppTheme.yellowPrimary,
                                      labelColor: isReady
                                          ? AppTheme.greenPrimary
                                          : Colors.white54,
                                    ),
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
            ],
          ),
        ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProgressBar(
    BuildContext context, {
    required String label,
    required double progress,
    required Color barColor,
    required Color labelColor,
  }) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppTheme.backgroundSecondary,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.caption2(context).copyWith(
            color: labelColor,
          ),
        ),
      ],
    );
  }
}
