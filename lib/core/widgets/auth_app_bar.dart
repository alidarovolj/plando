import 'package:flutter/material.dart';
import 'package:plando/core/styles/constants.dart';

class AuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AuthAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: kToolbarHeight,
      child: Navigator.canPop(context)
          ? Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: AppColors.lightGrey,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
