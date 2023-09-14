import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
                width: 100,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(width: 1, color: Colors.grey),
                  borderRadius: BorderRadius.all(
                      Radius.circular(10.0) //         <--- border radius here
                      ),
                ),
                child: InkWell(
                  splashColor: Colors.red, // Splash color
                  onTap: onTap,
                  child: Container(
                    padding: EdgeInsets.all(15),
                    child:
                        Image.asset("images/Icons/UserDashboard/$getImage.png",
                            errorBuilder: (context, exception, stackTrace) {
                      return Image.asset(
                        "images/Icons/DocumentUpload/PhotoSection/defaultCertificate.png",
                      );
                    }),
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
            style: TextStyle(
              fontSize: 13.0,
              color: getTextColor ?? Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
