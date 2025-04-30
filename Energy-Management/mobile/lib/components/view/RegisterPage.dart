import 'dart:async';
import 'package:energymanagement/components/Ultilities/AddressFormInput.dart';
import 'package:energymanagement/components/viewmodel/auth_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone_form_field/phone_form_field.dart';
import '../Ultilities/FormInput.dart';
import '../Ultilities/FormPasswordInput.dart';
import '../Ultilities/UploadImage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final String? verifiedPhoneNumber;

  const RegisterScreen({super.key, this.verifiedPhoneNumber});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  double? _deviceHeight, _deviceWidth;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController fullNameTextController;
  late TextEditingController emailTextController;
  late PhoneController phoneTextController;
  late TextEditingController passwordTextController;
  late TextEditingController rePasswordTextController;
  late TextEditingController addressTextController;
  final TextEditingController otpController = TextEditingController();
  bool isOTPSent = false;
  bool _isLoading = false;
  bool couldSend = false;

  @override
  void initState() {
    super.initState();
    fullNameTextController = TextEditingController();
    emailTextController = TextEditingController();
    phoneTextController = PhoneController();
    passwordTextController = TextEditingController();
    rePasswordTextController = TextEditingController();
    addressTextController = TextEditingController();
    if(widget.verifiedPhoneNumber != null){
      phoneTextController.value = PhoneNumber.parse(widget.verifiedPhoneNumber!);
    }
  }

  @override
  void dispose() {
    fullNameTextController.dispose();
    emailTextController.dispose();
    phoneTextController.dispose();
    passwordTextController.dispose();
    rePasswordTextController.dispose();
    addressTextController.dispose();
    super.dispose();
  }

  void handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final authVM = ref.read(authViewModelProvider);
      if (!isOTPSent) {
        // Sent OTP
        final isCreated = await authVM.handleSignUp(
          fullNameTextController.text,
          emailTextController.text,
          passwordTextController.text,
          addressTextController.text,
          phoneTextController.value.international,
        );

        if (isCreated) {
          setState(() {
            isOTPSent = true;
          });
          Timer(const Duration(seconds: 60), () {
            setState(() => couldSend = true);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("OTP has been sent to your email.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Sign up failed. Try again.")),
          );
        }

      } else {
        // Fill OTP and verify
        final email = emailTextController.text.trim();
        final otp = otpController.text.trim();
        final verifyRes = await authVM.verifyEmail(email, otp);

        if (verifyRes) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("OTP verified. Registration complete!")),
          );
          Navigator.pushReplacementNamed(context, "home");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid OTP. Please try again.")),
          );
        }
      }
    }
  }

  void handleResentOTP() async {
    setState(() {
      couldSend = false;
    });
    final authVM = ref.read(authViewModelProvider);
    final email = emailTextController.text.trim();

    final isResent = await authVM.resendOTP(email);
    if (isResent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP has been resent.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to resend OTP.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(227, 230, 240, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            padding: EdgeInsets.symmetric(horizontal: _deviceWidth! * 0.05),
            child: Form(
              key: _formKey,
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeaderWidget(),
                SizedBox(height: _deviceHeight! * 0.02),
                if (!isOTPSent) ...[
                  const UploadImage(),
                  SizedBox(height: _deviceHeight! * 0.03),
                  FormInput(
                    ctrl: fullNameTextController,
                    labelText: 'Full Name',
                    prefixImagePth: 'assets/images/avatar-icon.png',
                    inputType: TextInputType.name,
                    onValidate: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your full name';
                      if (!RegExp(r"^[A-Za-zÀ-Ỹà-ỹ' -]{2,50}$").hasMatch(value)) {
                        return 'Please enter a valid name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: _deviceHeight! * 0.02),
                  FormInput(
                    ctrl: emailTextController,
                    labelText: 'Email',
                    prefixImagePth: 'assets/images/email_icon.png',
                    inputType: TextInputType.emailAddress,
                    onValidate: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your email';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: _deviceHeight! * 0.02),
                  PhoneFormField(
                    key: const Key('phoneField'),
                    controller: phoneTextController,
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      hintText: "Enter your phone number",
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (PhoneNumber? phone) {
                      if (phone == null || !phone.isValid()) return 'Please enter a valid phone number';
                      return null;
                    },
                  ),
                  SizedBox(height: _deviceHeight! * 0.02),
                  FormPaswordInput(
                    ctrl: passwordTextController,
                    labelText: 'Password',
                    prefixImagePth: 'assets/images/padlock-icon.png',
                  ),
                  SizedBox(height: _deviceHeight! * 0.02),
                  FormPaswordInput(
                    ctrl: rePasswordTextController,
                    labelText: 'Re-enter Password',
                    prefixImagePth: 'assets/images/padlock-icon.png',
                  ),
                  SizedBox(height: _deviceHeight! * 0.02),
                  AddressInputField(controller: addressTextController),
                ] else ...[
                  SizedBox(height: _deviceHeight! * 0.04),
                  Text(
                    'Enter the OTP sent to ${emailTextController.text}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: _deviceHeight! * 0.02),
                  TextFormField(
                    controller: otpController,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "OTP",
                      prefixIcon: const Icon(Icons.lock_clock),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter the OTP';
                      if (value.length != 6) return 'OTP must be 6 digits';
                      return null;
                    },
                  ),
                  SizedBox(height: _deviceHeight! * 0.02),
                  ElevatedButton(
                    onPressed: couldSend
                        ? () {
                      setState(() => couldSend = false);
                      Timer(const Duration(seconds: 60), () {
                        setState(() => couldSend = true);
                      });
                      handleResentOTP();
                    }
                        : null,
                    child: Text(
                      "Resend OTP",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: couldSend ? const Color(0xFF6B76F2) : Colors.grey
                      ),
                    ),
                  ),
                ],
                SizedBox(height: _deviceHeight! * 0.02),
                signUpButtonWidget(_deviceWidth!, _deviceHeight!),
                if (!isOTPSent) const AlreadyHaveAccountWidget(),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }

  Widget signUpButtonWidget(double deviceWidth, double deviceHeight){
    return Center(
      child: ElevatedButton(
        onPressed: () {
          handleSubmit();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B76F2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          fixedSize: Size(deviceWidth! * 0.8, deviceHeight! * 0.08),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 70),
          elevation: 6,
          shadowColor: Colors.black26,
        ),
        child: Text(
          isOTPSent ? "Verify" : 'Sign Up',
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

}

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF6B76F2), size: 30, weight: 700),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: RichText(
                text: const TextSpan(
                  text: 'Sign up ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'with us',
                      style: TextStyle(color: Color(0xFF6B76F2)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        const Text(
          'Give us some information about you',
          style: TextStyle(
            fontSize: 12,
            color: Color.fromRGBO(146, 138, 138, 1),
          ),
        ),
      ],
    );
  }
}

class AlreadyHaveAccountWidget extends StatelessWidget {
  const AlreadyHaveAccountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      alignment: Alignment.center,
      child: RichText(
        text: TextSpan(
          text: 'Already have an account? ',
          style: const TextStyle(color: Colors.black),
          children: <TextSpan>[
            TextSpan(
              text: 'Login here',
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.popAndPushNamed(context, 'login');
                },
              style: const TextStyle(color: Color.fromRGBO(107, 118, 242, 1)),
            ),
          ],
        ),
      ),
    );
  }
}
