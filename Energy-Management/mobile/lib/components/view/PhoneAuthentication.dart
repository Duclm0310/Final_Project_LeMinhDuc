import 'dart:async';
import 'package:energymanagement/components/viewmodel/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'RegisterPage.dart';

class PhoneAuthentication extends ConsumerStatefulWidget {
  const PhoneAuthentication({super.key});

  @override
  ConsumerState<PhoneAuthentication> createState() => _PhoneAuthenticationState();
}

class _PhoneAuthenticationState extends ConsumerState<PhoneAuthentication> with SingleTickerProviderStateMixin {
  final TextEditingController _otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  PhoneNumber? _phoneNumber;
  bool _isOtpSent = false;
  bool _isLoading = false;
  bool _isVerified = false;
  String _errorMessage = '';

  // For countdown timer
  int _remainingSeconds = 60;
  Timer? _timer;
  bool _canResendOtp = false;

  // For animation
  late AnimationController _animationController;
  late Animation<double> _animation;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startCountdownTimer() {
    _remainingSeconds = 60;
    _canResendOtp = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _canResendOtp = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _sendOtp() async {
    if (_formKey.currentState?.validate() != true || _phoneNumber == null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final formattedPhone = _phoneNumber!.international.replaceAll(' ', '');

    try {
      await supabase.auth.signInWithOtp(phone: formattedPhone);

      setState(() {
        _isOtpSent = true;
        _isLoading = false;
      });

      _startCountdownTimer();
      _animationController.forward();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("OTP sent successfully!"),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to send OTP: ${e.toString().split(']').last.trim()}";
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_errorMessage),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) {
      setState(() {
        _errorMessage = "Please enter a valid 6-digit OTP";
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await supabase.auth
          .verifyOTP(phone: _phoneNumber!.international, token: _otpController.text.trim(), type: OtpType.sms);

      if (response.session != null) {
        final authProvider = ref.read(authViewModelProvider);
        final isVerified = await authProvider.loginWithPhone(_phoneNumber!.international);

        setState(() {
          _isVerified = true;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Verification successful!"),
          backgroundColor: Colors.green,
        ));
        if(isVerified){
          print("Login with exist account!");
          if(!mounted) return;
          Navigator.pushReplacementNamed(context, "home");
        }else{
          if(!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RegisterScreen(verifiedPhoneNumber: _phoneNumber!.international),
            ),
          );
          print("Navigate and allow create new account!");

        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Verification failed: ${e.toString().split(']').last.trim()}";
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_errorMessage),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _resetForm() {
    setState(() {
      _isOtpSent = false;
      _errorMessage = '';
    });
    _otpController.clear();
    _timer?.cancel();
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Phone Authentication"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _isVerified
                        ? Lottie.asset("assets/lottie/enter_phone.json",
                            width: 80, height: 80)
                        : _isOtpSent
                            ? Lottie.asset("assets/lottie/otpsent.json",
                                width: 80, height: 80) // change this lottie
                            : Lottie.asset("assets/lottie/otp_verify.json", width: 80, height: 80),
                    const SizedBox(height: 24),

                    // Title and description
                    Text(
                      _isOtpSent ? "Verify Your Phone" : "Sign In with Phone",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isOtpSent
                          ? "We've sent a 6-digit code to ${_phoneNumber?.international}. Enter it below to verify your phone number."
                          : "Enter your phone number to receive a verification code",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Phone number input (visible only before OTP is sent)
                    if (!_isOtpSent) ...[
                      PhoneFormField(
                        key: const Key('phoneField'),
                        initialValue: PhoneNumber.parse('+44'),
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          hintText: "Enter your phone number",
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (PhoneNumber? phone) {
                          if (phone == null || !phone.isValid()) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                        onChanged: (phone) {
                          setState(() {
                            _phoneNumber = phone;
                          });
                        },
                      ),
                    ],

                    // OTP input (visible only after OTP is sent)
                    if (_isOtpSent && _animationController != null) ...[
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(_animationController),
                        child: FadeTransition(
                          opacity: _animationController,
                          child: Column(
                            children: [
                              PinCodeTextField(
                                appContext: context,
                                length: 6,
                                controller: _otpController,
                                keyboardType: TextInputType.number,
                                animationType: AnimationType.fade,
                                pinTheme: PinTheme(
                                  shape: PinCodeFieldShape.box,
                                  borderRadius: BorderRadius.circular(12),
                                  fieldHeight: 50,
                                  fieldWidth: 45,
                                  activeFillColor: Colors.white,
                                  inactiveFillColor: Colors.grey[50],
                                  selectedFillColor: Colors.grey[100],
                                  activeColor: Theme.of(context).colorScheme.primary,
                                  inactiveColor: Colors.grey[300],
                                  selectedColor: Theme.of(context).colorScheme.primary,
                                ),
                                animationDuration: const Duration(milliseconds: 300),
                                enableActiveFill: true,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _errorMessage = '';
                                  });
                                },
                              ),

                              // Resend OTP timer
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Didn't receive the code? ",
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  _canResendOtp
                                      ? TextButton(
                                          onPressed: _isLoading ? null : _sendOtp,
                                          child: const Text("Resend"),
                                        )
                                      : Text(
                                          "Resend in $_remainingSeconds s",
                                          style: TextStyle(color: Theme.of(context).colorScheme.primary),
                                        ),
                                ],
                              ),

                              // Edit phone number button
                              TextButton.icon(
                                onPressed: _isLoading ? null : _resetForm,
                                icon: const Icon(Icons.edit),
                                label: const Text("Edit Phone Number"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // Error message using spread operator
                    if (_errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage,
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Action button
                    ElevatedButton(
                      onPressed: _isLoading ? null : (_isOtpSent ? _verifyOtp : _sendOtp),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isOtpSent ? "Verify OTP" : "Send OTP",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
