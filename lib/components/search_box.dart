import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  SearchBox({
    required this.onChanged,
  }) : super();

  ValueChanged onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 5, right: 20),
      padding: const EdgeInsets.symmetric(
        horizontal: 5.0,
        vertical: 5.0, // 5 top and bottom
      ),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        onChanged: onChanged,
        style: TextStyle(color: Colors.white, letterSpacing: 1),
        decoration: InputDecoration(
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          icon: Icon(
            Icons.search,
            color: Colors.white,
          ),
          hintText: 'SEARCH',
          hintStyle: TextStyle(color: Colors.white, letterSpacing: 0.5),
        ),
      ),
    );
  }
}
