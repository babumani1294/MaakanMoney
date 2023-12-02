import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../flutter_flow/flutter_flow_theme.dart';
import '../constants.dart';

class ReusableCertificateSection extends StatelessWidget {
  final String? getText;
  final IconData? getIcon;
  final String? getImage;
  final Color? getIconColor;
  final Color? getTextColor;
  final Function()? onTap;

  ReusableCertificateSection(
      {@required this.getText,
      @required this.getIcon,
      @required this.onTap,
      @required this.getImage,
      this.getIconColor,
      this.getTextColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Container(
                width: 21.w,
                height: 7.h,
                decoration: BoxDecoration(
                  color:
                      FlutterFlowTheme.of(context).secondary2.withOpacity(0.1),
                  borderRadius: BorderRadius.all(
                      Radius.circular(10.0) //         <--- border radius here
                      ),
                ),
                child: InkWell(
                  splashColor: FlutterFlowTheme.of(context).secondary1,
                  onTap: onTap,
                  child: Center(
                    child: Container(
                      height: 30,
                      width: 30,
                      child: Image.asset("images/final/Dashboard/$getImage.png",
                          errorBuilder: (context, exception, stackTrace) {
                        return Image.asset(
                          "images/final/Common/Error.png",
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            textAlign: TextAlign.center,
            getText ?? "",
            overflow: TextOverflow.ellipsis,
            style: GlobalTextStyles.secondaryText1(
                txtSize: 13,
                textColor: getTextColor,
                txtWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
