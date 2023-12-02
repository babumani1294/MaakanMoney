import 'package:flutter/material.dart';
import 'package:maaakanmoney/components/constants.dart';
import 'package:maaakanmoney/flutter_flow/flutter_flow_theme.dart';

class CustomDialogBox extends StatefulWidget {
  const CustomDialogBox(
      {Key? key,
      @required this.descriptions,
      @required this.title,
      @required this.text,
      @required this.onTap,
      @required this.isCancel,
      this.isNo,
      this.onNoTap})
      : super(key: key);

  final bool? isNo;
  final bool? isCancel;
  final String? descriptions;
  final String? title;
  final String? text;
  final Function()? onTap;
  final Function()? onNoTap;

  @override
  State<CustomDialogBox> createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.padding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(
              left: Constants.padding,
              top: 30, //Constants.avatarRadius + Constants.padding,
              right: Constants.padding,
              bottom: Constants.padding),
          margin: const EdgeInsets.only(top: Constants.avatarRadius),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                // BoxShadow(
                //     color: Colors.black, offset: Offset(0, 7), blurRadius: 15),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                widget.title.toString().toUpperCase() ?? "no value",
                // "Message",
                style: GlobalTextStyles.secondaryText2(
                    txtSize: 20,
                    textColor: FlutterFlowTheme.of(context).primary,
                    txtWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                widget.descriptions ?? "no value",
                style: GlobalTextStyles.secondaryText2(
                    txtSize: 14,
                    textColor: FlutterFlowTheme.of(context).primary,
                    txtWeight: FontWeight.w700),
                textAlign: TextAlign.left,
              ),
              const SizedBox(
                height: 22,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Visibility(
                    visible: widget.isCancel ?? true,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                          // onPressed: () {
                          //   Navigator.of(context).pop();
                          // },
                          style: TextButton.styleFrom(
                              backgroundColor:
                                  FlutterFlowTheme.of(context).secondary),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(fontSize: 18),
                          )),
                    ),
                  ),
                  Visibility(
                    visible: widget.isNo ?? false,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                          // onPressed: () {
                          //   Navigator.of(context).pop();
                          // },
                          style: TextButton.styleFrom(
                              backgroundColor:
                                  FlutterFlowTheme.of(context).primary),
                          onPressed: widget.onNoTap,
                          child: const Text(
                            "No",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          )),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                        onPressed: widget.onTap,
                        style: TextButton.styleFrom(
                            backgroundColor:
                                FlutterFlowTheme.of(context).primary),
                        child: Text(
                          widget.text ?? "no value",
                          style: const TextStyle(fontSize: 18),
                        )),
                  ),
                ],
              ),
            ],
          ),
        ), // bottom part
        Visibility(
          visible: false,
          child: Positioned(
            left: Constants.padding,
            right: Constants.padding,
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: Constants.avatarRadius,
              child: ClipRRect(
                  borderRadius: const BorderRadius.all(
                      Radius.circular(Constants.avatarRadius)),
                  child: Image.asset(
                      width: 50,
                      height: 50,
                      "images/Icons/DocumentUpload/CertificateSection/cancel.png")),
            ), // top part
          ),
        )
      ],
    );
  }
}
