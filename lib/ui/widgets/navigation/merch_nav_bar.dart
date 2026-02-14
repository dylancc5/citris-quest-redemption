import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../core/breakpoints.dart';
import '../../../backend/data/auth_service.dart';
import '../../../backend/services/cart_service.dart';
import '../../../painters/space_invader_painter.dart';
import '../../screens/login_screen.dart';

/// Styled nav bar for the merch shop with retro glow aesthetic.
///
/// Two modes:
/// - **Main mode** (isSubPage: false): SpaceInvader logo, cart badge, login/orders
/// - **Sub-page mode** (isSubPage: true): Back arrow, page title, optional actions
class MerchNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool isSubPage;
  final VoidCallback? onCartTap;
  final VoidCallback? onOrdersTap;
  final List<Widget>? actions;

  const MerchNavBar({
    super.key,
    this.title,
    this.isSubPage = false,
    this.onCartTap,
    this.onOrdersTap,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundPrimary.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.cyanAccent,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cyanAccent.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Breakpoints.isMobile(context) ? 16 : 32,
            ),
            child: isSubPage
                ? _buildSubPageLayout(context)
                : _buildMainLayout(context),
          ),
        ),
      ),
    );
  }

  /// Main landing page layout: Logo | Title | Cart + Login
  Widget _buildMainLayout(BuildContext context) {
    return Row(
      children: [
        // SpaceInvader logo
        _buildLogo(context),
        const SizedBox(width: 12),
        // Title
        Expanded(
          child: Text(
            'CITRIS QUEST MERCH',
            style: GoogleFonts.tiny5(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.cyanAccent,
              letterSpacing: 1,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Action buttons
        ..._buildMainActions(context),
      ],
    );
  }

  /// Sub-page layout: Back | Title | Page Actions + Main Actions
  Widget _buildSubPageLayout(BuildContext context) {
    return Row(
      children: [
        // Back button
        _buildBackButton(context),
        const SizedBox(width: 8),
        // Title
        Expanded(
          child: Text(
            (title ?? '').toUpperCase(),
            style: GoogleFonts.tiny5(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Optional page-specific actions
        if (actions != null) ...actions!,
        // Standard actions (orders, cart, profile)
        ..._buildMainActions(context),
      ],
    );
  }

  Widget _buildLogo(BuildContext context) {
    return CustomPaint(
      size: const Size(33, 24),
      painter: SpaceInvaderPainter(color: AppTheme.cyanAccent),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.cyanAccent.withValues(alpha: 0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMainActions(BuildContext context) {
    return [
      // Orders button (if logged in)
      ValueListenableBuilder(
        valueListenable: AuthService().isLoggedInNotifier,
        builder: (context, isLoggedIn, _) {
          if (!isLoggedIn || onOrdersTap == null) {
            return const SizedBox.shrink();
          }
          return _NavIconButton(
            icon: Icons.receipt_long,
            tooltip: 'My Orders',
            onTap: onOrdersTap!,
          );
        },
      ),

      // Cart button with badge
      if (onCartTap != null)
        ValueListenableBuilder(
          valueListenable: CartService().cartItemsNotifier,
          builder: (context, items, _) {
            final itemCount = items.fold<int>(
              0,
              (sum, item) => sum + item.quantity,
            );
            return _NavCartButton(
              itemCount: itemCount,
              onTap: onCartTap!,
            );
          },
        ),

      // Login/Logout button
      ValueListenableBuilder(
        valueListenable: AuthService().isLoggedInNotifier,
        builder: (context, isLoggedIn, _) {
          if (!isLoggedIn) {
            return _NavIconButton(
              icon: Icons.login,
              tooltip: 'Login',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
            );
          }

          return PopupMenuButton<void>(
            icon: Icon(
              Icons.account_circle,
              color: AppTheme.cyanAccent,
              size: 24,
            ),
            tooltip: 'Account',
            color: AppTheme.backgroundSecondary,
            itemBuilder: (context) => <PopupMenuEntry<void>>[
              PopupMenuItem<void>(
                enabled: false,
                child: Text(
                  AuthService().username ?? 'User',
                  style: GoogleFonts.tiny5(
                    fontSize: 15,
                    color: AppTheme.cyanAccent,
                  ),
                ),
              ),
              PopupMenuItem<void>(
                enabled: false,
                child: Row(
                  children: [
                    Icon(Icons.star, size: 14, color: AppTheme.cyanAccent),
                    const SizedBox(width: 4),
                    Text(
                      '${AuthService().xp} XP',
                      style: GoogleFonts.tiny5(
                        fontSize: 13,
                        color: AppTheme.cyanAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.monetization_on, size: 14, color: AppTheme.yellowPrimary),
                    const SizedBox(width: 4),
                    Text(
                      '${AuthService().coins} coins',
                      style: GoogleFonts.tiny5(
                        fontSize: 13,
                        color: AppTheme.yellowPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<void>(
                onTap: () async {
                  await AuthService().logout();
                },
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: AppTheme.redPrimary),
                    const SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: GoogleFonts.tiny5(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ];
  }
}

/// Styled icon button for the nav bar
class _NavIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _NavIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_NavIconButton> createState() => _NavIconButtonState();
}

class _NavIconButtonState extends State<_NavIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: _isHovered
                    ? AppTheme.cyanAccent.withValues(alpha: 0.5)
                    : Colors.transparent,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              widget.icon,
              color: _isHovered ? AppTheme.cyanAccent : Colors.white70,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

/// Cart button with item count badge
class _NavCartButton extends StatefulWidget {
  final int itemCount;
  final VoidCallback onTap;

  const _NavCartButton({
    required this.itemCount,
    required this.onTap,
  });

  @override
  State<_NavCartButton> createState() => _NavCartButtonState();
}

class _NavCartButtonState extends State<_NavCartButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Cart',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: _isHovered
                    ? AppTheme.cyanAccent.withValues(alpha: 0.5)
                    : Colors.transparent,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.shopping_cart,
                  color: _isHovered ? AppTheme.cyanAccent : Colors.white70,
                  size: 22,
                ),
                if (widget.itemCount > 0)
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppTheme.magentaPrimary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppTheme.magentaPrimary.withValues(alpha: 0.6),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        widget.itemCount > 99
                            ? '99+'
                            : '${widget.itemCount}',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
