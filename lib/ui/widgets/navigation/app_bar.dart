import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../backend/data/auth_service.dart';
import '../../../backend/services/cart_service.dart';
import '../../screens/login_screen.dart';

/// Custom app bar for merch shop
class MerchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onCartTap;
  final VoidCallback? onOrdersTap;

  const MerchAppBar({
    super.key,
    required this.onCartTap,
    this.onOrdersTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.backgroundSecondary,
      elevation: 4,
      shadowColor: AppTheme.cyanAccent.withOpacity(0.3),
      title: Row(
        children: [
          Icon(Icons.shopping_bag, color: AppTheme.bluePrimary),
          const SizedBox(width: 8),
          const Text('CITRIS Quest Merch'),
        ],
      ),
      actions: [
        // Orders button (if logged in)
        ValueListenableBuilder(
          valueListenable: AuthService().isLoggedInNotifier,
          builder: (context, isLoggedIn, _) {
            if (!isLoggedIn || onOrdersTap == null) {
              return const SizedBox.shrink();
            }

            return IconButton(
              icon: const Icon(Icons.receipt_long),
              tooltip: 'My Orders',
              onPressed: onOrdersTap,
            );
          },
        ),

        // Cart button with badge
        ValueListenableBuilder(
          valueListenable: CartService().cartItemsNotifier,
          builder: (context, items, _) {
            final itemCount = items.fold<int>(
              0,
              (sum, item) => sum + item.quantity,
            );

            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  tooltip: 'Cart',
                  onPressed: onCartTap,
                ),
                if (itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.magentaPrimary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.magentaPrimary.withOpacity(0.6),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Center(
                        child: Text(
                          itemCount > 99 ? '99+' : '$itemCount',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),

        // Login/Logout button
        ValueListenableBuilder(
          valueListenable: AuthService().isLoggedInNotifier,
          builder: (context, isLoggedIn, _) {
            if (!isLoggedIn) {
              return IconButton(
                icon: const Icon(Icons.person),
                tooltip: 'Sign In',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
              );
            }

            return PopupMenuButton<void>(
              icon: const Icon(Icons.account_circle),
              tooltip: 'Account',
              itemBuilder: (context) => <PopupMenuEntry<void>>[
                PopupMenuItem<void>(
                  enabled: false,
                  child: Text(AuthService().username ?? 'User'),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<void>(
                  onTap: () async {
                    await AuthService().logout();
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(width: 8),
      ],
    );
  }
}
