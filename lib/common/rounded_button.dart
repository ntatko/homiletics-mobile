import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final Widget child;
  final Function() onClick;
  final bool shadow;
  final bool disabled;
  const RoundedButton(
      {Key? key,
      required this.child,
      required this.onClick,
      this.shadow = true,
      this.disabled = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (_) => disabled ? null : onClick(),
      child: Container(
        height: 46,
        width: 150,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            boxShadow: shadow && !disabled ? kElevationToShadow[3] : [],
            color: Colors.blue[200]?.withOpacity(disabled ? 0.6 : 1),
            borderRadius: BorderRadius.circular(30)),
        child: Center(child: child),
      ),
    );
  }
}
