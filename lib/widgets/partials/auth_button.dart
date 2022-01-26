import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String title;
  final Function onClick;
  final bool rounded;
  const AuthButton(
      {required this.title,
      required this.onClick,
      this.rounded = true,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Center(
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.button,
            textAlign: TextAlign.center,
          ),
        ),
      ),
      onPressed: () {
        onClick();
      },
      style: ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all(Theme.of(context).primaryColorDark),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(rounded ? 25.0 : 5.0)),
            side: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
