import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/typography.dart';
import '../../core/breakpoints.dart';
import '../../core/constants/merch_config.dart';
import '../../backend/data/auth_service.dart';
import '../../widgets/common/animated_starfield.dart';
import '../widgets/navigation/merch_nav_bar.dart';
import '../widgets/merch/merch_item_card.dart';
import 'cart_screen.dart';
import 'order_history_screen.dart';

/// Landing screen displaying 4 merch items in responsive grid
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MerchNavBar(
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
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Breakpoints.cardSpacing(context),
                  Breakpoints.cardSpacing(context),
                  Breakpoints.cardSpacing(context) - 6,
                  Breakpoints.cardSpacing(context),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    _buildHeader(context),
                    SizedBox(height: Breakpoints.cardSpacing(context) * 2),

                    // Merch items grid
                    _buildMerchGrid(context),
                  ],
                ),
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          'CITRIS QUEST',
          style: AppTypography.largeTitle(context).copyWith(
            color: AppTheme.bluePrimary,
            shadows: [
              Shadow(
                color: AppTheme.cyanAccent.withOpacity(0.5),
                blurRadius: 20,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'MERCH SHOP',
          style: AppTypography.title1(context).copyWith(
            color: AppTheme.cyanAccent,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Redeem your in-game coins for exclusive merch',
          style: AppTypography.body(context).copyWith(
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder(
          valueListenable: AuthService().isLoggedInNotifier,
          builder: (context, isLoggedIn, _) {
            if (!isLoggedIn) {
              return Text(
                'Log in to view your balance',
                style: AppTypography.caption1(context).copyWith(
                  color: Colors.white54,
                ),
                textAlign: TextAlign.center,
              );
            }

            return ValueListenableBuilder(
              valueListenable: AuthService().xpNotifier,
              builder: (context, xp, _) {
                return ValueListenableBuilder(
                  valueListenable: AuthService().coinsNotifier,
                  builder: (context, coins, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star,
                          color: AppTheme.cyanAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$xp XP',
                          style: AppTypography.body(context).copyWith(
                            color: AppTheme.cyanAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.monetization_on,
                          color: AppTheme.yellowPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$coins coins',
                          style: AppTypography.body(context).copyWith(
                            color: AppTheme.yellowPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildMerchGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount;
    final double childAspectRatio;

    if (Breakpoints.isMobile(context)) {
      // Single column on mobile - wider cards, less tall
      crossAxisCount = screenWidth < 400 ? 1 : 2;
      childAspectRatio = screenWidth < 400 ? 0.9 : 0.7;
    } else if (Breakpoints.isTablet(context)) {
      // 2-3 columns on tablet depending on width
      crossAxisCount = screenWidth < 900 ? 2 : 3;
      childAspectRatio = 0.75;
    } else {
      crossAxisCount = 4;
      childAspectRatio = 0.75;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: Breakpoints.cardSpacing(context),
        mainAxisSpacing: Breakpoints.cardSpacing(context),
        childAspectRatio: childAspectRatio,
      ),
      itemCount: MerchConfig.items.length,
      itemBuilder: (context, index) {
        return MerchItemCard(item: MerchConfig.items[index]);
      },
    );
  }
}
