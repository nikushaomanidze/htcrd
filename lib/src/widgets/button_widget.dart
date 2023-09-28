import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_theme_data.dart';
import '../utils/responsive.dart';

class ButtonWidget extends StatelessWidget {
  final String? buttonTittle;
  const ButtonWidget({Key? key, this.buttonTittle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 56,
      decoration: BoxDecoration(
        // boxShadow: const [
        //   BoxShadow(
        //       spreadRadius: 2,
        //       blurRadius: 5,
        //       color: Color.fromARGB(255, 239, 127, 26),
        //       offset: Offset(0, 5))
        // ],
        color: const Color.fromARGB(255, 239, 127, 26),
        borderRadius: BorderRadius.all(
          Radius.circular(30.r),
        ),
      ),
      child: Text(
        buttonTittle!,
        style: isMobile(context)
            ? AppThemeData.buttonTextStyle_14
            : AppThemeData.buttonTextStyle_11Tab,
      ),
    );
  }
}
