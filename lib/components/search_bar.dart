import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SearchBar extends StatelessWidget {
  final void Function()? onTap;
  final void Function(String)? onChanged;
  final Icon icon;
  final void Function()? onIconPressed;
  final bool autofocus;
  final bool enabled;
  const SearchBar({
    Key? key,
    this.onTap,
    this.onChanged,
    this.icon = const Icon(Icons.search),
    this.onIconPressed,
    this.autofocus = false,
    this.enabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: TextField(
        enabled: enabled,
        onTap: onTap,
        autofocus: autofocus,
        onChanged: onChanged,
        decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
            filled: true,
            labelText: 'Search',
            prefixIcon: onIconPressed == null
                ? icon
                : IconButton(
                    icon: icon,
                    onPressed: onIconPressed,
                  ),
            fillColor: const Color.fromARGB(255, 206, 231, 255)),
      ),
    );
  }
}
