import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Querying the environment via [Plattform] throws and exception on Flutter web
// This extension adds a new [isWeb] getter that should be used
// before checking for any of the other environments

Future<bool> showAlertDialog({
  @required BuildContext context,
  @required String title,
  @required String content,
  String cancelActionText,
  @required String defaultActionText,
}) async {
  return await showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(title, style: TextStyle(fontSize: 18),),
      content: Text(content, style: TextStyle(fontSize: 17),),
      actions: <Widget>[
        if (cancelActionText != null)
          CupertinoDialogAction(
            child: Text(cancelActionText, style: TextStyle(fontSize: 17),),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        CupertinoDialogAction(
          child: Text(defaultActionText, style: TextStyle(fontSize: 17),),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );
}
