import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/typography.dart';
import '../../../core/constants/merch_config.dart';
import '../../../backend/data/auth_service.dart';
import '../../../backend/domain/models/merch_item.dart';
import '../../../widgets/common/hover_lift_card.dart';
import '../../screens/item_detail_screen.dart';

/// Card displaying a single merch item
class MerchItemCard extends StatelessWidget {
  final MerchItem item;

  const MerchItemCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = MerchConfig.getAccentColor(item.id);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ItemDetailScreen(item: item),
        ),
      ),
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
              // Image/Icon area
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundSecondary.withValues(alpha: 0.5),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                  ),
                  child: Icon(
                    MerchConfig.getPlaceholderIcon(item.id),
                    size: 60,
                    color: accentColor,
                  ),
                ),
              ),

              // Content area
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                      // Progress bars (only when logged in)
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
                                  final xpThreshold = MerchConfig.xpGateThreshold;
                                  final xpProgress = (xp / xpThreshold).clamp(0.0, 1.0);
                                  final hasEnoughXp = xp >= xpThreshold;
                                  final coinProgress =
                                      (coins / item.coinPrice).clamp(0.0, 1.0);
                                  final hasEnoughCoins = coins >= item.coinPrice;

                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Column(
                                      children: [
                                        // XP progress bar (only if not yet met)
                                        if (!hasEnoughXp) ...[
                                          _buildProgressBar(
                                            context,
                                            label: '$xp / $xpThreshold XP',
                                            progress: xpProgress,
                                            barColor: AppTheme.cyanAccent,
                                            labelColor: Colors.white54,
                                          ),
                                          const SizedBox(height: 6),
                                        ],
                                        // Coins progress bar
                                        _buildProgressBar(
                                          context,
                                          label: hasEnoughCoins
                                              ? 'Ready to redeem!'
                                              : '$coins / ${item.coinPrice} coins',
                                          progress: coinProgress,
                                          barColor: hasEnoughCoins
                                              ? AppTheme.greenPrimary
                                              : AppTheme.yellowPrimary,
                                          labelColor: hasEnoughCoins
                                              ? AppTheme.greenPrimary
                                              : Colors.white54,
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
