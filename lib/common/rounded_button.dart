import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final Widget child;
  final Function() onClick;
  final bool shadow;
  const RoundedButton(
      {Key? key,
      required this.child,
      required this.onClick,
      this.shadow = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (_) => onClick(),
      child: Container(
        height: 46,
        width: 150,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            boxShadow: shadow
                ? [
                    BoxShadow(
                        color: Colors.grey[400]!,
                        blurRadius: 10,
                        offset: const Offset(0, 3))
                  ]
                : [],
            color: Colors.blue[200],
            borderRadius: BorderRadius.circular(30)),
        child: Center(child: child),
      ),
    );
  }
}
