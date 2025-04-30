import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FormPaswordInput extends StatefulWidget {
  final String labelText;
  final String prefixImagePth;
  final TextEditingController ctrl;

  const FormPaswordInput({
    super.key,
    required this.ctrl,
    required this.labelText,
    required this.prefixImagePth,
  });

  @override
  State<FormPaswordInput> createState() => _FormPaswordInputState();
}

class _FormPaswordInputState extends State<FormPaswordInput> {
  bool _obscureText = true;
  FocusNode inputFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    inputFocus.addListener((){
      if(!inputFocus.hasFocus){
        setState(() {_obscureText = true;});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: TextFormField(
        obscureText: _obscureText,
        controller: widget.ctrl,
        keyboardType: TextInputType.visiblePassword,
        focusNode: inputFocus,
        validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: widget.labelText,
          labelStyle: GoogleFonts.asul(color: const Color(0xFF928A8A)),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              widget.prefixImagePth,
              width: 16,
              height: 16,
              fit: BoxFit.contain,
            ),
          ),
          suffixIcon: GestureDetector(
            onTap: (){setState(() {_obscureText = !_obscureText;});},
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset(
                _obscureText ? "assets/images/eye.png" : "assets/images/invisible.png",
                width: 10,
                height: 10,
              ),
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

  @override
  void dispose() {
    super.dispose();
    inputFocus.dispose();
  }
}
