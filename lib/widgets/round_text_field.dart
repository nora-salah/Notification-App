import 'package:flutter/material.dart';
import 'package:notification/utils/app_colors.dart';

class RoundTextField extends StatelessWidget {
  final TextEditingController? textEditingController;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final IconData icon;
  final TextInputType textInputType;
  final bool isObscureText;
  final Widget? rightIcon;

  const RoundTextField({
    super.key,
    this.textEditingController,
    this.validator,
    this.onChanged,
    required this.hintText,
    required this.icon,
    required this.textInputType,
    this.isObscureText = false,
    this.rightIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: textEditingController,
        keyboardType: textInputType,
        obscureText: isObscureText,
        onChanged: onChanged,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 15),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
          prefixIcon: Container(
            alignment: Alignment.center,
            width: 20,
            height: 20,
            child: Icon(
              icon,
              size: 20,
            ),
          ),
          suffixIcon: rightIcon,
        ),
        validator: validator,
      ),
    );
  }
}
//
// How to Use
//
// You can now use this RoundTextField widget in any screen like this:
//
// RoundTextField(
// textEditingController: yourController,
// hintText: 'Enter text',
// icon: 'assets/icon.png',
// textInputType: TextInputType.text,
// isObscureText: false,
// onChanged: (value) {
// print(value);
// },
// rightIcon: Icon(Icons.visibility),
// );
