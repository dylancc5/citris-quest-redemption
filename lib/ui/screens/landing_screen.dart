import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../core/typography.dart';
import '../../core/breakpoints.dart';
import '../../backend/data/merch_items_service.dart';
import '../../backend/data/auth_service.dart';
import '../../backend/domain/models/merch_item.dart';
import '../../widgets/common/animated_starfield.dart';
import '../../widgets/common/balance_display.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/svg_icon.dart';
import '../widgets/navigation/merch_nav_bar.dart';
import '../widgets/merch/merch_item_card.dart';
import 'cart_screen.dart';
import 'login_screen.dart';
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
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Ensure merch items are loaded
    if (!MerchItemsService().hasFetched) {
      MerchItemsService().initialize();
    }
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
                        _buildHeroSection(context),
                        SizedBox(height: Breakpoints.sectionSpacing(context)),
                        _buildHowItWorks(context),
                        SizedBox(height: Breakpoints.sectionSpacing(context)),
                        _buildMerchGrid(context),
                        SizedBox(height: Breakpoints.cardSpacing(context) * 2),
                        _buildFooter(context),
                        const SizedBox(height: 24),
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
    final invaderSize = isMobile ? 48.0 : 66.0;

    return Column(
      children: [
        // Floating Space Invader SVG icon
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
                child: SvgIcon(
                  'space_invader',
                  size: invaderSize,
                  color: AppTheme.cyanAccent,
                  fallbackIcon: Icons.videogame_asset,
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
          style: AppTypography.body(context).copyWith(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        // Login CTA or balance display
        ValueListenableBuilder<bool>(
          valueListenable: AuthService().isLoggedInNotifier,
          builder: (context, isLoggedIn, _) {
            if (!isLoggedIn) {
              return _buildLoginCta(context);
            }
            return Column(
              children: [
                BalanceDisplay(
                  size: BalanceSize.large,
                  alignment: MainAxisAlignment.center,
                  abbreviate: false,
                  textStyle: AppTypography.body(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome back, ${AuthService().username ?? 'Player'}!',
                  style: AppTypography.caption1(context).copyWith(
                    color: Colors.white54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoginCta(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    return Column(
      children: [
        Text(
          'Sign in to track your balance and redeem coins for merch',
          style: AppTypography.body(context).copyWith(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          text: 'Sign In to Get Started',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          ),
          borderColor: AppTheme.cyanAccent,
          textColor: AppTheme.cyanAccent,
          width: isMobile ? double.infinity : 320,
          height: 56,
        ),
        const SizedBox(height: 12),
        Text(
          'Already playing CITRIS Quest? Use your game account to sign in.',
          style: AppTypography.caption1(context).copyWith(color: Colors.white38),
          textAlign: TextAlign.center,
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

        isMobile
            ? Column(
                children: [
                  _buildStep(context, 1, Icons.star, 'Earn Coins',
                      'Scan artworks in the CITRIS Quest app', AppTheme.cyanAccent),
                  const SizedBox(height: 16),
                  _buildStep(context, 2, Icons.shopping_bag, 'Browse Merch',
                      'Choose from exclusive CITRIS items', AppTheme.magentaPrimary),
                  const SizedBox(height: 16),
                  _buildStep(context, 3, Icons.local_shipping, 'Get It Shipped',
                      'Redeem coins and receive your merch', AppTheme.greenPrimary),
                ],
              )
            : Row(
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
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 12),
        ],
      ),
      child: Column(
        children: [
          // Number circle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 3, left: 3),
              child: Text(
                '$number',
                textAlign: TextAlign.center,
                style: AppTypography.title3(context).copyWith(
                  fontSize: 28,
                  color: color,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Icon(icon, color: color, size: 40),
          const SizedBox(height: 12),

          Text(
            title,
            style: AppTypography.title3(context).copyWith(color: color),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          Text(
            description,
            style: AppTypography.caption1(context).copyWith(color: Colors.white70),
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
      crossAxisCount = screenWidth < 420 ? 1 : 2;
      childAspectRatio = screenWidth < 420 ? 0.9 : 0.55;
    } else if (Breakpoints.isTablet(context)) {
      crossAxisCount = screenWidth < 900 ? 2 : 3;
      childAspectRatio = 0.55;
    } else {
      crossAxisCount = 4;
      childAspectRatio = 0.55;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MERCH',
          style: AppTypography.title2(context).copyWith(
            color: AppTheme.cyanAccent,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder<bool>(
          valueListenable: MerchItemsService().isLoadingNotifier,
          builder: (context, isLoading, _) {
            return ValueListenableBuilder<String?>(
              valueListenable: MerchItemsService().errorNotifier,
              builder: (context, error, _) {
                return ValueListenableBuilder<List<MerchItem>>(
                  valueListenable: MerchItemsService().itemsNotifier,
                  builder: (context, items, _) {
                    // Loading state
                    if (isLoading && items.isEmpty) {
                      return _buildLoadingGrid(crossAxisCount, childAspectRatio);
                    }

                    // Error state
                    if (error != null && items.isEmpty) {
                      return _buildErrorState(context, error);
                    }

                    // Empty state
                    if (items.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    // Items grid
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: Breakpoints.cardSpacing(context),
                        mainAxisSpacing: Breakpoints.cardSpacing(context),
                        childAspectRatio: childAspectRatio,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return MerchItemCard(item: items[index]);
                      },
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

  Widget _buildLoadingGrid(int crossAxisCount, double childAspectRatio) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: Breakpoints.cardSpacing(context),
        mainAxisSpacing: Breakpoints.cardSpacing(context),
        childAspectRatio: childAspectRatio,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            gradient: AppTheme.cardBackgroundGradient,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.cyanAccent.withValues(alpha: 0.15),
              width: 2,
            ),
          ),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(
                  AppTheme.cyanAccent.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: AppTheme.cardBackgroundGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.redPrimary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppTheme.redPrimary, size: 48),
          const SizedBox(height: 16),
          Text(
            error,
            style: AppTypography.body(context).copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Retry',
            onPressed: () => MerchItemsService().refreshItems(),
            borderColor: AppTheme.cyanAccent,
            textColor: AppTheme.cyanAccent,
            width: 160,
            height: 44,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: AppTheme.cardBackgroundGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.cyanAccent.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.shopping_bag_outlined,
              color: Colors.white38, size: 48),
          const SizedBox(height: 16),
          Text(
            'No merch available right now.\nCheck back soon!',
            style: AppTypography.body(context).copyWith(color: Colors.white54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Center(child: _HoverFooterLink());
  }
}

class _HoverFooterLink extends StatefulWidget {
  const _HoverFooterLink();

  @override
  State<_HoverFooterLink> createState() => _HoverFooterLinkState();
}

class _HoverFooterLinkState extends State<_HoverFooterLink> {
  bool _isHovered = false;

  Future<void> _launch() async {
    final uri = Uri.parse('https://dylancc5.github.io/citris-quest-landing/');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _isHovered ? AppTheme.magentaPrimary : AppTheme.cyanAccent;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _launch,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: AppTypography.body(context).copyWith(
            color: color,
            decoration: _isHovered ? TextDecoration.underline : TextDecoration.none,
            decorationColor: color,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.videogame_asset, size: 18, color: color),
              const SizedBox(width: 8),
              const Text('Play CITRIS Quest to Earn More Coins'),
              const SizedBox(width: 4),
              Icon(Icons.open_in_new, size: 14, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
