import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/typography.dart';
import '../../../backend/data/auth_service.dart';

/// Display size for balance widget
enum BalanceSize {
  small, // For nav bar, compact views (14px icons)
  medium, // Default for cards, forms (16px icons)
  large, // For prominent displays (20px icons)
}

/// Reusable widget to display user XP and/or coin balance
/// Automatically listens to AuthService notifiers and rebuilds on changes
class BalanceDisplay extends StatelessWidget {
  final bool showXp;
  final bool showCoins;
  final BalanceSize size;
  final MainAxisAlignment alignment;
  final TextStyle? textStyle;

  const BalanceDisplay({
    super.key,
    this.showXp = true,
    this.showCoins = true,
    this.size = BalanceSize.medium,
    this.alignment = MainAxisAlignment.start,
    this.textStyle,
  });

  double get _iconSize {
    switch (size) {
      case BalanceSize.small:
        return 14;
      case BalanceSize.medium:
        return 16;
      case BalanceSize.large:
        return 20;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AuthService().xpNotifier,
      builder: (context, xp, _) {
        return ValueListenableBuilder<int>(
          valueListenable: AuthService().coinsNotifier,
          builder: (context, coins, _) {
            final effectiveTextStyle =
                textStyle ?? AppTypography.caption1(context);

            return Row(
              mainAxisAlignment: alignment,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showXp) ...[
                  Icon(Icons.star, color: AppTheme.cyanAccent, size: _iconSize),
                  const SizedBox(width: 4),
                  Text(
                    '$xp XP',
                    style: effectiveTextStyle.copyWith(
                      color: AppTheme.cyanAccent,
                    ),
                  ),
                ],
                if (showXp && showCoins) const SizedBox(width: 12),
                if (showCoins) ...[
                  Icon(Icons.monetization_on,
                      color: AppTheme.yellowPrimary, size: _iconSize),
                  const SizedBox(width: 4),
                  Text(
                    '$coins',
                    style: effectiveTextStyle.copyWith(
                      color: AppTheme.yellowPrimary,
                    ),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}
