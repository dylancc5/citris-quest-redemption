import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../core/typography.dart';
import '../../core/breakpoints.dart';
import '../../core/constants/merch_config.dart';
import '../../backend/data/auth_service.dart';
import '../../backend/data/merch_items_service.dart';
import '../../backend/domain/models/merch_item.dart';
import '../../widgets/common/animated_starfield.dart';
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
                        SizedBox(height: Breakpoints.sectionSpacing(context) * 0.5),
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
        SizedBox(height: Breakpoints.sectionSpacing(context) * 0.5),
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
            style: AppTypography.body(context).copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMerchGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final spacing = Breakpoints.cardSpacing(context);

    final double cardWidth;
    if (Breakpoints.isMobile(context)) {
      cardWidth = screenWidth < 420
          ? double.infinity
          : (screenWidth - spacing * 3) / 2;
    } else if (Breakpoints.isTablet(context)) {
      final cols = screenWidth < 900 ? 2 : 3;
      cardWidth = (screenWidth - spacing * (cols + 1)) / cols;
    } else {
      cardWidth = (screenWidth.clamp(0, 1200) - spacing * 5) / 4;
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
        _buildXpGateBanner(context),
        ValueListenableBuilder<bool>(
          valueListenable: MerchItemsService().isLoadingNotifier,
          builder: (context, isLoading, _) {
            return ValueListenableBuilder<String?>(
              valueListenable: MerchItemsService().errorNotifier,
              builder: (context, error, _) {
                return ValueListenableBuilder<List<MerchItem>>(
                  valueListenable: MerchItemsService().itemsNotifier,
                  builder: (context, items, _) {
                    if (isLoading && items.isEmpty) {
                      return _buildLoadingGrid(cardWidth, spacing);
                    }
                    if (error != null && items.isEmpty) {
                      return _buildErrorState(context, error);
                    }
                    if (items.isEmpty) {
                      return _buildEmptyState(context);
                    }
                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: items.map((item) {
                        return SizedBox(
                          width: cardWidth == double.infinity
                              ? double.infinity
                              : cardWidth,
                          child: MerchItemCard(item: item),
                        );
                      }).toList(),
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

  Widget _buildLoadingGrid(double cardWidth, double spacing) {
    final skeletonCount = cardWidth == double.infinity ? 2 : 4;
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: List.generate(skeletonCount, (_) {
        return SizedBox(
          width: cardWidth == double.infinity ? double.infinity : cardWidth,
          height: 260,
          child: Container(
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
          ),
        );
      }),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: AppTheme.cardBackgroundGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 48),
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
          Icon(Icons.shopping_bag_outlined, color: Colors.white38, size: 48),
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

  Widget _buildXpGateBanner(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AuthService().isLoggedInNotifier,
      builder: (context, isLoggedIn, _) {
        if (!isLoggedIn) return const SizedBox.shrink();

        return ValueListenableBuilder<int>(
          valueListenable: AuthService().xpNotifier,
          builder: (context, xp, _) {
            final threshold = MerchConfig.xpGateThreshold;
            final hasEnoughXp = xp >= threshold;

            return AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: hasEnoughXp
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundSecondary.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.cyanAccent.withValues(alpha: 0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.cyanAccent.withValues(alpha: 0.15),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header row: lock icon + label + XP counter
                            Row(
                              children: [
                                Icon(
                                  Icons.lock_outline,
                                  size: 16,
                                  color: Colors.white54,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'MERCH LOCKED',
                                  style: AppTypography.caption1(context).copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '$xp / $threshold XP',
                                  style: AppTypography.caption1(context).copyWith(
                                    color: AppTheme.cyanAccent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Description
                            Text(
                              'Reach $threshold XP in CITRIS Quest to unlock the merch shop.',
                              style: AppTypography.caption2(context).copyWith(
                                color: Colors.white54,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (xp / threshold).clamp(0.0, 1.0),
                                minHeight: 8,
                                backgroundColor: AppTheme.backgroundSecondary,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.cyanAccent,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Percentage label
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${((xp / threshold) * 100).clamp(0, 100).toStringAsFixed(1)}%',
                                style: AppTypography.caption2(context).copyWith(
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            );
          },
        );
      },
    );
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
