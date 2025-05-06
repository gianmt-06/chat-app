import 'package:chat_app/constants/color_constans.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BackAppbarButton extends StatelessWidget {
  final GestureTapCallback onTap;
  const BackAppbarButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, top: 10.0, bottom: 10.0),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        onTap: onTap,
        child: Container(
          width: 35,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: ColorConstants.mainColor.withValues(alpha: 0.1),
          ),
          child: Center(
            child: Icon(LucideIcons.arrowLeft, color: ColorConstants.mainColor),
          ),
        ),
      ),
    );
  }
}
