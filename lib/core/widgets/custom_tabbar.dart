import 'package:flutter/material.dart';
import 'package:plando/core/styles/constants.dart';

class CustomTabBar extends StatelessWidget {
  final TabController tabController;

  const CustomTabBar({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(
            color: AppColors.borderColor,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Цвет тени
            blurRadius: AppLength.xxs, // Радиус размытия
            spreadRadius: 1, // Радиус распространения
            offset: const Offset(
                0, 4), // Смещение тени (по горизонтали и вертикали)
          ),
        ],
      ),
      child: TabBar(
        controller: tabController,
        indicatorColor: Colors.transparent,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textPrimary,
        labelStyle: const TextStyle(
          fontSize: AppLength.xxs,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(icon: Icon(Icons.home_outlined), text: "Главная"),
          Tab(icon: Icon(Icons.search), text: "Поиск"),
          Tab(icon: Icon(Icons.chat_bubble_outline), text: "Чат"),
          // Tab(icon: Icon(Icons.local_pharmacy_outlined), text: "Аптеки"),
          Tab(icon: Icon(Icons.map_outlined), text: "Карта"),
          Tab(icon: Icon(Icons.person_outline_sharp), text: "Профиль"),
        ],
      ),
    );
  }
}
