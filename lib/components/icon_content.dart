import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';




class ReusableIdProofSection extends StatelessWidget {
  final String? getText;
  final IconData? getIcon;
  final Color? getIconColor;
  final Color? getTextColor;
  final Function()? onTap;
  final String? isMandateDoc;

  ReusableIdProofSection(
      {@required this.getText,
      @required this.getIcon,
      @required this.onTap,
      @required this.isMandateDoc,
      this.getIconColor,
      this.getTextColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(width: 1, color: Colors.grey.shade200),
              borderRadius: BorderRadius.all(
                  Radius.circular(10.0) //         <--- border radius here
                  ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 80.w,
                        child: Text(
                          getText ?? "",
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ),
                      Text(
                        isMandateDoc == "1" ? "*" : "",
                        style: TextStyle(fontSize: 24, color: Colors.red),
                      ),
                    ],
                  ),
                  Icon(
                    getIcon,
                    size: 20,
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
