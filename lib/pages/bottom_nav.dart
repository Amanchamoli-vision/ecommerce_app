import 'package:clothes_ecommerce/pages/cart.dart';
import 'package:clothes_ecommerce/pages/home.dart';
import 'package:clothes_ecommerce/pages/order.dart';
import 'package:clothes_ecommerce/pages/profile.dart';
import 'package:clothes_ecommerce/pages/wallet.dart';
import 'package:clothes_ecommerce/pages/wishlist.dart';
import 'package:clothes_ecommerce/services/cart_service.dart';
import 'package:clothes_ecommerce/services/wishlist_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNav extends StatefulWidget {
  final int initialIndex;
  const BottomNav({super.key, this.initialIndex = 0});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  late int currentTabIndex;

  // ✅ IndexedStack — tab switch pe rebuild/blink nahi hoga
  final List<Widget> pages = const [
    Home(),
    Order(),
    CartPage(),
    WishlistPage(),
    Wallet(),
    Profile(),
  ];

  @override
  void initState() {
    super.initState();
    currentTabIndex = widget.initialIndex;

    // ✅ Badge live update ke liye listen karo
    CartService.instance.addListener(_onServiceUpdate);
    WishlistService.instance.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    CartService.instance.removeListener(_onServiceUpdate);
    WishlistService.instance.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ IndexedStack — pages alive rehte hain, blink nahi hota
      body: IndexedStack(
        index: currentTabIndex,
        children: pages,
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, Icons.home_outlined, "Home"),
              _navItem(1, Icons.receipt_long_rounded,
                  Icons.receipt_long_outlined, "Orders"),
              _navItemWithBadge(
                index: 2,
                activeIcon: Icons.shopping_cart_rounded,
                inactiveIcon: Icons.shopping_cart_outlined,
                label: "Cart",
                badgeCount: CartService.instance.itemCount,
              ),
              _navItemWithBadge(
                index: 3,
                activeIcon: Icons.favorite_rounded,
                inactiveIcon: Icons.favorite_border_rounded,
                label: "Wishlist",
                badgeCount: WishlistService.instance.itemCount,
                activeColor: const Color(0xFFFF6161),
              ),
              _navItem(2, Icons.account_balance_wallet_rounded,
                  Icons.account_balance_wallet_outlined, "Wallet",
                  tabIndex: 4),
              _navItem(2, Icons.person_rounded,
                  Icons.person_outline_rounded, "Profile",
                  tabIndex: 5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    int _,
    IconData activeIcon,
    IconData inactiveIcon,
    String label, {
    int? tabIndex,
  }) {
    final index = tabIndex ?? _;
    final bool isActive = currentTabIndex == index;
    return _NavTile(
      isActive: isActive,
      activeIcon: activeIcon,
      inactiveIcon: inactiveIcon,
      label: label,
      badgeCount: 0,
      onTap: () => setState(() => currentTabIndex = index),
    );
  }

  Widget _navItemWithBadge({
    required int index,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required String label,
    required int badgeCount,
    Color activeColor = const Color(0xff6e5038),
  }) {
    final bool isActive = currentTabIndex == index;
    return _NavTile(
      isActive: isActive,
      activeIcon: activeIcon,
      inactiveIcon: inactiveIcon,
      label: label,
      badgeCount: badgeCount,
      activeColor: activeColor,
      onTap: () => setState(() => currentTabIndex = index),
    );
  }
}

// ── Reusable nav tile ──────────────────────────────────────────────────────────
class _NavTile extends StatelessWidget {
  final bool isActive;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  final int badgeCount;
  final Color activeColor;
  final VoidCallback onTap;

  const _NavTile({
    required this.isActive,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
    required this.badgeCount,
    required this.onTap,
    this.activeColor = const Color(0xff6e5038),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 12 : 8,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? activeIcon : inactiveIcon,
                  color: isActive ? activeColor : Colors.grey,
                  size: 22,
                ),
                if (isActive) ...[
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      color: activeColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            // ✅ Live badge
            if (badgeCount > 0)
              Positioned(
                top: -6,
                right: isActive ? -6 : -8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '₹badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}