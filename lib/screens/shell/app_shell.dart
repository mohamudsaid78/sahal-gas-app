import 'dart:async';

import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_theme.dart';
import '../../core/enums.dart';
import '../../core/app_localizations.dart';
import '../admin/admin_cylinders_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../admin/admin_drivers_screen.dart';
import '../admin/admin_orders_screen.dart';
import '../admin/admin_reports_screen.dart';
import '../admin/admin_revenue_screen.dart';
import '../admin/admin_users_screen.dart';
import '../customer/cart_screen.dart';
import '../customer/customer_home_screen.dart';
import '../customer/customer_orders_screen.dart';
import '../customer/products_screen.dart';
import '../customer/profile_screen.dart';
import '../driver/driver_orders_screen.dart';
import '../../widgets/app_navigation.dart';
import '../../services/image_service.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  Timer? _adminOrderTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = AppScope.of(context, listen: false);
      controller.refreshAdminNewOrderCount();
      _adminOrderTimer = Timer.periodic(const Duration(seconds: 15), (_) {
        controller.refreshAdminNewOrderCount();
      });
    });
  }

  @override
  void dispose() {
    _adminOrderTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final user = controller.currentUser!;
    final l10n = AppLocalizations.of(context);
    final destinations = _destinationsFor(user.role, l10n);
    final wide = MediaQuery.sizeOf(context).width >= 900;
    if (_index >= destinations.length) _index = 0;
    // Show only the first 5 destinations in the bottom navigation.
    final visibleDestinations = destinations.take(5).toList();
    final displayedIndex = _index < visibleDestinations.length ? _index : 0;
    return AppNavigation(
      onSelect: _select,
      child: Scaffold(
        drawer: wide
            ? null
            : _AppDrawer(
                user: user,
                destinations: destinations,
                selectedIndex: _index,
                onSelected: _select,
                onSignOut: controller.signOut,
              ),
        body: Row(
          children: [
            if (wide)
              _AppDrawer(
                user: user,
                destinations: destinations,
                selectedIndex: _index,
                onSelected: _select,
                onSignOut: controller.signOut,
              ),
            Expanded(child: destinations[_index].page),
          ],
        ),
        bottomNavigationBar: wide
            ? null
            : DecoratedBox(
                decoration: const BoxDecoration(
                  color: Color(0xffed1c24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x16000000),
                      blurRadius: 18,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: NavigationBarTheme(
                  data: NavigationBarThemeData(
                    iconTheme: WidgetStateProperty.resolveWith((states) {
                      return IconThemeData(size: 25, color: Colors.white);
                    }),
                  ),
                  child: NavigationBar(
                    height: 86,
                    selectedIndex: displayedIndex,
                    onDestinationSelected: (visibleIndex) {
                      // Map the tapped visible destination back to the full destinations list
                      final dest = visibleDestinations[visibleIndex];
                      final fullIndex = destinations.indexOf(dest);
                      if (fullIndex >= 0) _select(fullIndex);
                    },
                    backgroundColor: const Color(0xffed1c24),
                    surfaceTintColor: Colors.transparent,
                    indicatorColor: const Color(0xffc81018),
                    indicatorShape: const StadiumBorder(),
                    labelBehavior:
                        NavigationDestinationLabelBehavior.alwaysShow,
                    labelTextStyle: WidgetStateProperty.resolveWith((states) {
                      final selected = states.contains(WidgetState.selected);
                      return TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w500,
                        letterSpacing: .1,
                      );
                    }),
                    destinations: visibleDestinations.map((item) {
                      final badge = item.badgeBuilder?.call(controller) ?? 0;
                      return NavigationDestination(
                        icon: Badge.count(
                          count: badge,
                          isLabelVisible: badge > 0,
                          child: Icon(item.icon),
                        ),
                        selectedIcon: Badge.count(
                          count: badge,
                          isLabelVisible: badge > 0,
                          child: Icon(item.selectedIcon),
                        ),
                        label: item.label,
                      );
                    }).toList(),
                  ),
                ),
              ),
      ),
    );
  }

  void _select(int value) {
    setState(() => _index = value);
    if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
      // Close the drawer safely only if the navigator can pop.
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    }
  }

  List<_ShellDestination> _destinationsFor(
    UserRole role,
    AppLocalizations l10n,
  ) {
    return switch (role) {
      UserRole.admin => [
        _ShellDestination(
          label: l10n.text('home'),
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          page: AdminDashboardScreen(),
        ),
        _ShellDestination(
          label: l10n.text('users'),
          icon: Icons.group_outlined,
          selectedIcon: Icons.group,
          page: AdminUsersScreen(),
        ),
        _ShellDestination(
          label: l10n.text('cylinders'),
          icon: Icons.inventory_2_outlined,
          selectedIcon: Icons.inventory_2,
          page: AdminCylindersScreen(),
        ),
        _ShellDestination(
          label: l10n.text('drivers'),
          icon: Icons.local_shipping_outlined,
          selectedIcon: Icons.local_shipping,
          page: AdminDriversScreen(),
        ),
        _ShellDestination(
          label: l10n.text('orders'),
          icon: Icons.receipt_long_outlined,
          selectedIcon: Icons.receipt_long,
          page: AdminOrdersScreen(),
          badgeBuilder: (controller) => controller.adminNewOrderCount,
        ),
        _ShellDestination(
          label: l10n.text('stock'),
          icon: Icons.inventory_2_outlined,
          selectedIcon: Icons.inventory_2,
          page: AdminCylindersScreen(),
        ),
        _ShellDestination(
          label: l10n.text('revenue'),
          icon: Icons.bar_chart_rounded,
          selectedIcon: Icons.bar_chart_rounded,
          page: AdminRevenueScreen(),
        ),
        _ShellDestination(
          label: l10n.text('reports'),
          icon: Icons.description_outlined,
          selectedIcon: Icons.description,
          page: AdminReportsScreen(),
        ),
        _ShellDestination(
          label: l10n.text('profile'),
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          page: ProfileScreen(),
        ),
      ],
      UserRole.driver => [
        _ShellDestination(
          label: l10n.text('assigned'),
          icon: Icons.delivery_dining_outlined,
          selectedIcon: Icons.delivery_dining,
          page: DriverOrdersScreen(),
        ),
        _ShellDestination(
          label: l10n.text('profile'),
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          page: ProfileScreen(),
        ),
      ],
      UserRole.customer => [
        _ShellDestination(
          label: l10n.text('home'),
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          page: CustomerHomeScreen(),
        ),
        _ShellDestination(
          label: l10n.text('products'),
          icon: Icons.inventory_2_outlined,
          selectedIcon: Icons.inventory_2,
          page: ProductsScreen(),
        ),
        _ShellDestination(
          label: l10n.text('cart'),
          icon: Icons.shopping_cart_outlined,
          selectedIcon: Icons.shopping_cart,
          page: const CartScreen(),
          badgeBuilder: (controller) => controller.cartQuantity,
        ),
        _ShellDestination(
          label: l10n.text('orders'),
          icon: Icons.receipt_long_outlined,
          selectedIcon: Icons.receipt_long,
          page: CustomerOrdersScreen(),
        ),
        _ShellDestination(
          label: l10n.text('profile'),
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          page: ProfileScreen(),
        ),
      ],
    };
  }
}

class _ShellDestination {
  const _ShellDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.page,
    this.badgeBuilder,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget page;
  final int Function(dynamic controller)? badgeBuilder;
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({
    required this.user,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.onSignOut,
  });

  final dynamic user;
  final List<_ShellDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 224,
      elevation: 8,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          children: [
            _DrawerHeader(user: user),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                children: [
                  for (var index = 0; index < destinations.length; index++)
                    _DrawerItem(
                      destination: destinations[index],
                      label: _drawerLabel(destinations[index], user.role),
                      selected: index == selectedIndex,
                      badge:
                          destinations[index].badgeBuilder?.call(
                            AppScope.of(context),
                          ) ??
                          0,
                      onTap: () => onSelected(index),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
              child: _DrawerItem(
                destination: const _ShellDestination(
                  label: 'Logout',
                  icon: Icons.logout_rounded,
                  selectedIcon: Icons.logout_rounded,
                  page: SizedBox.shrink(),
                ),
                label: 'Logout',
                selected: false,
                onTap: onSignOut,
                highlightColor: const Color(0xffed1c24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _drawerLabel(_ShellDestination destination, UserRole role) {
    if (role != UserRole.admin) return destination.label;
    return switch (destination.label) {
      'Home' => 'Home',
      'Users' => 'Customers',
      'Cylinders' => 'Products',
      'Profile' => 'Settings',
      _ => destination.label,
    };
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.user});

  final dynamic user;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 17),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xffed1c24), Color(0xffc90f18)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<Uint8List?>(
            future: ImageService.loadSavedImage(userId: user.id),
            builder: (context, snapshot) {
              final image = snapshot.data;
              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 21,
                        backgroundColor: Colors.white,
                        backgroundImage: image == null
                            ? null
                            : MemoryImage(image),
                        child: image == null
                            ? const Icon(
                                Icons.person,
                                color: Color(0xffed1c24),
                                size: 25,
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              user.phone,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 19,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.destination,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge = 0,
    this.highlightColor,
  });

  final _ShellDestination destination;
  final String label;
  final bool selected;
  final int badge;
  final Color? highlightColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final baseColor = selected ? AppTheme.orange : const Color(0xff344154);
    final color = highlightColor ?? baseColor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: onTap,
        dense: true,
        minLeadingWidth: 26,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
        tileColor: selected
            ? const Color(0xffffe8e5)
            : (highlightColor != null
                  ? highlightColor!.withOpacity(.06)
                  : null),
        leading: Icon(
          selected ? destination.selectedIcon : destination.icon,
          color: color,
          size: 21,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        trailing: badge > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xffed1c2b),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
