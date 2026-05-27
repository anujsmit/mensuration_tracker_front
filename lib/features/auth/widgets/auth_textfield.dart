import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {

  // ======================================================
  // VARIABLES
  // ======================================================

  final TextEditingController controller;

  final String hintText;

  final IconData prefixIcon;

  final bool obscureText;

  final Widget? suffixIcon;

  final TextInputType keyboardType;

  final String? Function(String?)? validator;

  final void Function(String)? onChanged;

  final int maxLines;

  final bool enabled;

  // ======================================================
  // CONSTRUCTOR
  // ======================================================

  const AuthTextField({

    super.key,

    required this.controller,

    required this.hintText,

    required this.prefixIcon,

    this.obscureText = false,

    this.suffixIcon,

    this.keyboardType =
        TextInputType.text,

    this.validator,

    this.onChanged,

    this.maxLines = 1,

    this.enabled = true,

  });

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return TextFormField(

      controller: controller,

      obscureText: obscureText,

      keyboardType: keyboardType,

      validator: validator,

      onChanged: onChanged,

      maxLines: maxLines,

      enabled: enabled,

      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),

      decoration: InputDecoration(

        hintText: hintText,

        hintStyle: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 14,
        ),

        prefixIcon: Icon(
          prefixIcon,
          color: theme.colorScheme.primary,
        ),

        suffixIcon: suffixIcon,

        filled: true,

        fillColor: Colors.white,

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),

        border: OutlineInputBorder(

          borderRadius:
              BorderRadius.circular(18),

          borderSide: BorderSide.none,

        ),

        enabledBorder:
            OutlineInputBorder(

          borderRadius:
              BorderRadius.circular(18),

          borderSide: BorderSide(
            color: Colors.grey.shade200,
          ),

        ),

        focusedBorder:
            OutlineInputBorder(

          borderRadius:
              BorderRadius.circular(18),

          borderSide: BorderSide(
            color:
                theme.colorScheme.primary,
            width: 1.5,
          ),

        ),

        errorBorder:
            OutlineInputBorder(

          borderRadius:
              BorderRadius.circular(18),

          borderSide: BorderSide(
            color: Colors.red.shade400,
          ),

        ),

        focusedErrorBorder:
            OutlineInputBorder(

          borderRadius:
              BorderRadius.circular(18),

          borderSide: BorderSide(
            color: Colors.red.shade400,
            width: 1.5,
          ),

        ),

      ),

    );

  }

}