import 'package:flutter/material.dart';

class FormTextField extends StatefulWidget {
  final TextEditingController controller;
  final String placeholder;
  final String label;
  final String? Function(String?)? validator;
  final bool isPassword;
  const FormTextField({
    super.key,
    required this.controller,
    this.validator,
    required this.placeholder,
    required this.label,
    this.isPassword = false,
  });

  @override
  State<FormTextField> createState() => _FormTextFieldState();
}

class _FormTextFieldState extends State<FormTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 5),
        TextFormField(
          obscureText: widget.isPassword,
          controller: widget.controller,
          decoration: InputDecoration(
            hintText: widget.placeholder,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.only(left: 25),
            suffixIconConstraints: BoxConstraints(minWidth: 20, minHeight: 20),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: Color(0xFFD9D9D9)),
              borderRadius: BorderRadius.circular(7.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: Color(0xFFD9D9D9)),
              borderRadius: BorderRadius.circular(7.0),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1.5, color: Colors.red),
              borderRadius: BorderRadius.circular(7.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 2, color: Colors.redAccent),
              borderRadius: BorderRadius.circular(7.0),
            ),
            errorStyle: TextStyle(color: Colors.red, fontSize: 12),
          ),
          validator: widget.validator,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF827F7F),
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }
}
