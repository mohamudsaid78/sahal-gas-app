import 'package:flutter/material.dart';
import '../screens/customer/profile_screen.dart';
import 'app_navigation.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
    this.showMenuButton = true,
  });

  final String title;
  final Widget child;
  final List<Widget> actions;
  final bool showMenuButton;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
          Container(
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffed1c24), Color(0xffc81018)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              children: [
                Builder(
                  builder: (context) {
                    final isShellPage = AppNavigation.maybeOf(context) != null;
                    final canGoBack = !isShellPage && Navigator.of(context).canPop();
                    if (canGoBack) {
                      return SizedBox(
                        width: 56,
                        height: 56,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: () {
                              if (Navigator.of(context).canPop()) Navigator.of(context).pop();
                            },
                            child: const Center(child: Icon(Icons.arrow_back, color: Colors.white, size: 28)),
                          ),
                        ),
                      );
                    }
                    if (!isDesktop && showMenuButton) {
                      return SizedBox(
                        width: 56,
                        height: 56,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: () => Scaffold.of(context).openDrawer(),
                            child: const Center(child: Icon(Icons.menu, color: Colors.white, size: 30)),
                          ),
                        ),
                      );
                    }
                    return const SizedBox(width: 56);
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: isDesktop ? 10 : 2),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                ...actions.map(
                  (action) => IconTheme(
                    data: const IconThemeData(color: Colors.white),
                    child: action,
                  ),
                ),
                const SizedBox(width: 5),
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
                      },
                      child: const Center(child: Icon(Icons.person, color: Color(0xffed1c24), size: 23)),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
