import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String title;
  final Function()? onExpand;

  const HomeHeader({Key? key, required this.title, required this.onExpand}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        TextButton(onPressed: onExpand, child: const Text("Show More", style: TextStyle(fontWeight: FontWeight.bold)))
      ]),
    );
  }
}
