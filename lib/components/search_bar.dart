import 'package:flutter/material.dart';

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
    this.icon = const Icon(Icons.search_rounded),
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
            hintText: 'Search',
            prefixIcon: onIconPressed == null
                ? icon
                : IconButton(
                    icon: icon,
                    onPressed: onIconPressed,
                  )),
      ),
    );
  }
}
