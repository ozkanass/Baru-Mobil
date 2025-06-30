import 'package:baru_mobil/main.dart';
import 'package:flutter/material.dart';

class CafeteriaPage extends StatelessWidget {
  const CafeteriaPage({super.key});

  @override
  Widget build(BuildContext context) {
    MenuCard menu1 = const MenuCard(
      title: "Üniversite Yemek Menüsü",
      icon: Icons.restaurant_menu,
      iconColor: Colors.blue,
      routeName: '/university-menu',
    );
    MenuCard menu2 = const MenuCard(
      title: "Yurt Yemek Menüsü (Kapalı)",
      icon: Icons.restaurant,
      iconColor: Colors.green,
      routeName: '/dorm-menu',
    );
    return Scaffold(
        appBar: AppBar(
          title: AppTheme.appBarTitle('Yemekhaneler'),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.chevron_left, size: 30.0),
          ),
        ),
        body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 1,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      menu1.buildMenuItem(context),
                      menu2.buildMenuItem(context),
                    ],
                  ),
                ),
              );
            }));
  }
}

class MenuCard {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String routeName;

  const MenuCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.routeName,
  });

  Widget buildMenuItem(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: DecorationTheme.boxDecoration(),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: DecorationTheme.iconsDecoration(),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: DecorationTheme.iconsDecoration(),
          child: const Icon(
            Icons.chevron_right,
            color: AppTheme.primaryColor,
            size: 24,
          ),
        ),
      ),
    );
  }
}
