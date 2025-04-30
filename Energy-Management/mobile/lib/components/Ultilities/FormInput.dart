import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FormInput extends StatelessWidget {
  final String labelText;
  final String prefixImagePth;
  final TextInputType inputType;
  final String? suffixImgPth;
  final VoidCallback? onSuffixIconPressed;
  final TextEditingController ctrl;
  final FormFieldValidator<String>? onValidate;

  const FormInput({
    super.key,
    required this.ctrl,
    required this.labelText,
    required this.prefixImagePth,
    required this.inputType,
    this.suffixImgPth,
    this.onSuffixIconPressed,
    this.onValidate
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: TextFormField(
        controller: ctrl,
        keyboardType: inputType,
        validator: onValidate,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: labelText,
          labelStyle: GoogleFonts.asul(color: const Color(0xFF928A8A)),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              prefixImagePth,
              width: 16,
              height: 16,
              fit: BoxFit.contain,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 12,
          ),
        ),
      ),
    );
  }
}
