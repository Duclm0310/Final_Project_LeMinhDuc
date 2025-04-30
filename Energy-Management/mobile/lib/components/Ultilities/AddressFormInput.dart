import 'package:flutter/material.dart';

class AddressInputField extends StatefulWidget {
  final TextEditingController controller;

  const AddressInputField({Key? key, required this.controller}) : super(key: key);

  @override
  _AddressInputFieldState createState() => _AddressInputFieldState();
}

class _AddressInputFieldState extends State<AddressInputField> {
  final _formKey = GlobalKey<FormState>();

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your address';
    }
    if (!RegExp(r"^[A-Za-zÀ-Ỹà-ỹ0-9\s,.\-#]{5,100}$").hasMatch(value)) {
      return 'Invalid address format';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: TextFormField(
        controller: widget.controller,
        decoration: InputDecoration(
          labelText: "Address",
          hintText: "e.g. 123 Nguyen Hue, Quan 1, HCM",
          prefixIcon: const Icon(Icons.location_on, color: Colors.black),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: _validateAddress,
        onFieldSubmitted: (value) {
          if (_formKey.currentState!.validate()) {
            // Handle valid address input
            print("Valid Address: ${widget.controller.text}");
          }
        },
      ),
    );
  }
}
