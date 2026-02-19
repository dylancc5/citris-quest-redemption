import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/typography.dart';
import '../../core/breakpoints.dart';
import '../../core/constants/merch_config.dart';
import '../../backend/data/auth_service.dart';
import '../../widgets/common/animated_starfield.dart';
import '../../widgets/common/balance_display.dart';
import '../widgets/navigation/merch_nav_bar.dart';
import '../widgets/merch/merch_item_card.dart';
import '../../painters/space_invader_painter.dart';
import 'cart_screen.dart';
import 'order_history_screen.dart';

/// Landing screen with hero section, how-it-works, and merch grid
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    // Floating animation for Space Invader icon
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _floatController.dispose();
    super.dispose();
  }

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
          controller: _scrollController,
          thickness: 6,
          radius: const Radius.circular(3),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      Breakpoints.cardSpacing(context),
                      Breakpoints.cardSpacing(context),
                      Breakpoints.cardSpacing(context),
                      Breakpoints.cardSpacing(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Hero section
                        _buildHeroSection(context),
                        SizedBox(height: Breakpoints.sectionSpacing(context)),

                        // How it works
                        _buildHowItWorks(context),
                        SizedBox(height: Breakpoints.sectionSpacing(context)),

                        // Merch items grid
                        _buildMerchGrid(context),
                        SizedBox(height: Breakpoints.cardSpacing(context) * 2),

                        // Footer
                        _buildFooter(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);

    return Column(
      children: [
        // Floating Space Invader icon
        AnimatedBuilder(
          animation: _floatAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _floatAnimation.value),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.cyanAccent.withValues(alpha: 0.4),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: CustomPaint(
                  size: Size(isMobile ? 55 : 66, isMobile ? 40 : 48),
                  painter: SpaceInvaderPainter(
                    color: AppTheme.cyanAccent,
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: isMobile ? 24 : 32),

        // Title
        Text(
          'CITRIS QUEST',
          style: AppTypography.largeTitle(context).copyWith(
            color: AppTheme.bluePrimary,
            shadows: [
              Shadow(
                color: AppTheme.cyanAccent.withValues(alpha: 0.5),
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

        // Subtitle
        Text(
          'Redeem your in-game coins for exclusive merch',
          style: AppTypography.body(context).copyWith(
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Balance display
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

            return BalanceDisplay(
              size: BalanceSize.large,
              alignment: MainAxisAlignment.center,
              textStyle: AppTypography.body(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHowItWorks(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);

    return Column(
      children: [
        Text(
          'HOW IT WORKS',
          style: AppTypography.title2(context).copyWith(
            color: AppTheme.cyanAccent,
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isMobile ? 24 : 32),

        // Steps
        LayoutBuilder(
          builder: (context, constraints) {
            if (isMobile) {
              // Vertical layout on mobile
              return Column(
                children: [
                  _buildStep(context, 1, Icons.star, 'Earn Coins',
                      'Scan artworks in the CITRIS Quest app', AppTheme.cyanAccent),
                  const SizedBox(height: 24),
                  _buildStep(context, 2, Icons.shopping_bag, 'Browse Merch',
                      'Choose from exclusive CITRIS items', AppTheme.magentaPrimary),
                  const SizedBox(height: 24),
                  _buildStep(context, 3, Icons.local_shipping, 'Get It Shipped',
                      'Redeem coins and receive your merch', AppTheme.greenPrimary),
                ],
              );
            }

            // Horizontal layout on tablet/desktop
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildStep(context, 1, Icons.star, 'Earn Coins',
                      'Scan artworks in the CITRIS Quest app', AppTheme.cyanAccent),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildStep(context, 2, Icons.shopping_bag, 'Browse Merch',
                      'Choose from exclusive CITRIS items', AppTheme.magentaPrimary),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildStep(context, 3, Icons.local_shipping, 'Get It Shipped',
                      'Redeem coins and receive your merch', AppTheme.greenPrimary),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStep(BuildContext context, int number, IconData icon,
      String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardBackgroundGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          // Number badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: Text(
                '$number',
                style: AppTypography.title3(context).copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Icon
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 12),

          // Title
          Text(
            title,
            style: AppTypography.title3(context).copyWith(color: color),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            description,
            style: AppTypography.caption1(context).copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMerchGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount;
    final double childAspectRatio;

    if (Breakpoints.isMobile(context)) {
      // Single column on mobile - wider cards, less tall
      crossAxisCount = screenWidth < 400 ? 1 : 2;
      childAspectRatio = screenWidth < 400 ? 0.85 : 0.65;
    } else if (Breakpoints.isTablet(context)) {
      // 2-3 columns on tablet depending on width
      crossAxisCount = screenWidth < 900 ? 2 : 3;
      childAspectRatio = 0.68;
    } else {
      crossAxisCount = 4;
      childAspectRatio = 0.68;
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

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: TextButton.icon(
        icon: const Icon(Icons.videogame_asset, size: 18),
        label: const Text('Need more coins? Play CITRIS Quest'),
        onPressed: () {
          // Could link to the landing page or TestFlight
          // For now, just show info
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Download CITRIS Quest on TestFlight to earn coins!'),
              backgroundColor: AppTheme.bluePrimary,
            ),
          );
        },
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.cyanAccent,
        ),
      ),
    );
  }
}
