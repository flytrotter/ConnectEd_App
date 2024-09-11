import "package:flutter/material.dart";

class MyButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  MyButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 119, 182, 1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(25),
            child: Center(
              child: Text(
                text,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16),
              ),
            )));
  }
}
