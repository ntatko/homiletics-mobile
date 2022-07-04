import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  void Function()? onTap;
  void Function(String)? onChanged;
  void Function(String)? onSubmitted;
  Icon icon;
  void Function()? onIconPressed;
  bool autofocus;
  bool enabled;
  SearchBar({
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
        onSubmitted: onSubmitted,
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
            fillColor: Color.fromARGB(255, 206, 231, 255)),
      ),
    );
  }
}
