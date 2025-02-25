import 'package:flutter/material.dart';
import 'package:notification/utils/app_colors.dart';

class RoundGradientBtn extends StatelessWidget {
  final String title;
  final Function() onPressed;

  const RoundGradientBtn(
      {super.key, required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.primaryColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppColors.black2,
                blurRadius: 2,
                offset: Offset(0, 2),
              ),
            ]),
        child: MaterialButton(
          minWidth: double.maxFinite,
          height: 50,
          onPressed: onPressed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
