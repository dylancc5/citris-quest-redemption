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

/// Formats a number with K/M suffix to prevent overflow in tight spaces.
String _formatBalance(int value, {bool abbreviate = false}) {
  if (!abbreviate) return '$value';
  if (value >= 1000000) {
    final m = value / 1000000;
    return '${m.toStringAsFixed(m.truncateToDouble() == m ? 0 : 1)}M';
  }
  if (value >= 1000) {
    final k = value / 1000;
    return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}K';
  }
  return '$value';
}

/// Reusable widget to display user XP and/or coin balance.
/// Automatically listens to AuthService notifiers and rebuilds on changes.
class BalanceDisplay extends StatelessWidget {
  final bool showXp;
  final bool showCoins;
  final BalanceSize size;
  final MainAxisAlignment alignment;
  final TextStyle? textStyle;
  /// Abbreviate large numbers (e.g. 250000 → 250K). Defaults to true for small.
  final bool? abbreviate;

  const BalanceDisplay({
    super.key,
    this.showXp = true,
    this.showCoins = true,
    this.size = BalanceSize.medium,
    this.alignment = MainAxisAlignment.start,
    this.textStyle,
    this.abbreviate,
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

  bool get _shouldAbbreviate => abbreviate ?? (size == BalanceSize.small);

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
                    '${_formatBalance(xp, abbreviate: _shouldAbbreviate)} XP',
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
                    _formatBalance(coins, abbreviate: _shouldAbbreviate),
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
