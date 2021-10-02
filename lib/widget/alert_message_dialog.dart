import 'package:flutter/material.dart';

class AlertMessageDialog extends StatelessWidget {
  final String content;
  final String button;
  final String title;
  final String cancelButton;
  final bool showCancel;
  final Widget child;

  AlertMessageDialog(this.content,
      {String button = '确定',
      this.cancelButton = '取消',
      this.title = '提示',
      this.showCancel = true,
      this.child})
      : this.button = button;

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Material(
        type: MaterialType.transparency,
        child: new Container(
          margin: EdgeInsets.only(left: 64.0, right: 64.0),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            color: Colors.white,
          ),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: Color(0xFF393833)),
                constraints: BoxConstraints.tightFor(width: double.infinity),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 12.0),
                      child: Text(
                        title,
                        style: TextStyle(
                            color: Color(0xFFDBAA74),
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 12.0, left: 12.0, right: 12.0, bottom: 34),
                      child: Text(
                        content,
                        style:
                            TextStyle(color: Color(0xFFDBAA74), fontSize: 13.0),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
              ),
              if (child != null) child,
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: InkWell(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Color(0xFF393833),
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: Center(
                      child: Text(
                        button,
                        style: TextStyle(color: Color(0xFFDBAA74), fontSize: 15.0),
                      ),
                    ),
                    padding: EdgeInsets.only(top: 7, bottom: 7),
                  ),
                  onTap: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ),
              if (showCancel)
                Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: InkWell(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color(0xFFB1B1B1),
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Center(
                        child: Text(
                          cancelButton,
                          style: TextStyle(
                              color: Color(0xFF767676),
                              fontSize: 15.0,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      padding: EdgeInsets.only(top: 7, bottom: 6),
                    ),
                    onTap: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
