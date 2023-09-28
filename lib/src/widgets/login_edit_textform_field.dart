import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hot_card/src/utils/app_theme_data.dart';

import '../utils/responsive.dart';

class LoginEditTextField extends StatelessWidget {
  final String? hintText;
  final IconData? fieldIcon;
  final TextInputType? keyboardType;
  final TextEditingController? myController;
  final bool? myObscureText;
  final dynamic myValidate;
  final dynamic onSave;
  final String? labelText;
  final Widget? suffixIcon;
  final bool isReadonly;
  const LoginEditTextField({
    Key? key,
    this.isReadonly = false,
    this.labelText,
    this.fieldIcon,
    this.hintText,
    this.myController,
    this.keyboardType,
    this.myObscureText,
    this.suffixIcon,
    this.myValidate,
    this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 56,
      decoration: BoxDecoration(
        //color: Color(0xfff3f3f4),
        color: const Color.fromARGB(255, 242, 242, 242),
        borderRadius: BorderRadius.circular(35),
        // boxShadow: [
        //   BoxShadow(
        //     color: AppThemeData.boxShadowColor.withOpacity(0.15),
        //     spreadRadius: 2,
        //     blurRadius: 30,
        //     offset: const Offset(0, 15), // changes position of shadow
        //   ),
        // ],
      ),
      child: TextFormField(
        style: isMobile(context)
            ? AppThemeData.titleTextStyle_13.copyWith(
                color: const Color.fromARGB(255, 182, 183, 183), fontSize: 14)
            : AppThemeData.titleTextStyleTab,
        readOnly: isReadonly,
        obscureText: myObscureText!,
        validator: myValidate,
        controller: myController,
        onSaved: onSave,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          suffixIcon: suffixIcon,
          suffixIconColor: AppThemeData.textFieldSuffixIconColor,
          hintText: hintText,
          hintStyle: isMobile(context)
              ? AppThemeData.hintTextStyle_13.copyWith(
                  fontSize: 14, color: const Color.fromARGB(255, 182, 183, 183))
              : AppThemeData.hintTextStyle_10Tab,
          contentPadding: EdgeInsets.only(
            left: 8.w,
            right: 8.w,
            top: 15.h,
          ),
          prefixIcon: Icon(
            fieldIcon,
            color: AppThemeData.textFieldSuffixIconColor,
            size: isMobile(context) ? 17.r : 20.r,
          ),
          border: InputBorder.none,
          filled: false,
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(
              color: Colors.red,
              width: 2.w,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(
              color: Colors.red,
              width: 2.w,
            ),
          ),

          //border: InputBorder.none,
          // enabledBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(10.r),
          //   borderSide: BorderSide(
          //     color: Colors.white,
          //     width: 2.w,
          //   ),
          // ),
          // focusedBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.all(
          //     Radius.circular(10.r),
          //   ),
          //   borderSide: BorderSide(
          //     color: Colors.white,
          //     width: 2.w,
          //   ),
          // ),
        ),
      ),
    );
  }
}
