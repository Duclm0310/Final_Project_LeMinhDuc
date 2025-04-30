import 'package:energymanagement/components/view/DevicesList.dart';
import 'package:energymanagement/components/viewmodel/auth_viewmodel.dart';
import 'package:energymanagement/components/viewmodel/notification_viewmodel.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Ultilities/FormInput.dart';
import '../Ultilities/FormPasswordInput.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// TODO: Add state management!
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  double? _deviceWidth, _deviceHeight;
  bool _isLoading = false;
  bool _isOTPAvailable = false;
  String errorMsg = "";
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animationController.forward();
  }

  //Check user login before loading UI
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    bool isLogin = await ref.read(authViewModelProvider).isLogin();
    if (!mounted) return;
    if (isLogin) Navigator.pushReplacementNamed(context, "home");
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailTextController.dispose();
    passwordTextController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        errorMsg = "";
      });

      final authViewModel = ref.read(authViewModelProvider);
      bool isLoggedIn = await authViewModel.handleLogin(
        emailTextController.text,
        passwordTextController.text,
        ref,
      );
      setState(() {
        errorMsg = authViewModel.errorMsg;
      });
      bool notifyStatus = await NotificationViewModel().sendDeviceToken();

      if (isLoggedIn && notifyStatus) {
        print(
            "Is Stored Data: $isLoggedIn, Is Connect To Firebase $notifyStatus");
        Navigator.pushReplacementNamed(context, "home");
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    try {
      final supabase = Supabase.instance.client;
      _isOTPAvailable = true;
    } catch (e) {
      print("Error, can't init supabase services. $e");
      _isOTPAvailable = false;
    }
    return Scaffold(
      backgroundColor: const Color(0xFFE3E6F0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: _deviceWidth! * 0.05),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: _deviceHeight! * 0.02),
                  // Animated Header
                  FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
                      ),
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: 'Take Control Of Your',
                        style: GoogleFonts.asul(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: ' Electricity',
                            style: GoogleFonts.asul(
                              color: const Color(0xFF6B76F2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Center(
                    child: Text(
                      'Sign in to continue',
                      style: GoogleFonts.asul(
                        fontSize: 14,
                        color: const Color(0xFF928A8A),
                      ),
                    ),
                  ),

                  // Lottie Animation
                  Center(
                    child: SizedBox(
                      height: _deviceHeight! * 0.25,
                      child: Lottie.asset(
                        'assets/lottie/smartcity.json',
                        // Electricity/power animation
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  ...errorMsg.isNotEmpty
                      ? [
                          Center(
                              child: Text("Error: $errorMsg",
                                  style: TextStyle(color: Colors.red)))
                        ]
                      : [],

                  FormInput(
                      ctrl: emailTextController,
                      labelText: "Email",
                      prefixImagePth: 'assets/images/email_icon.png',
                      inputType: TextInputType.emailAddress,
                      onValidate: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      }),
                  SizedBox(height: _deviceHeight! * 0.02),
                  FormPaswordInput(
                      ctrl: passwordTextController,
                      labelText: "Password",
                      prefixImagePth: 'assets/images/padlock-icon.png'),
                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
               context,
                          MaterialPageRoute(
                            builder: (context) => DeviceListScreen(deviceType: 'Light',), // Test here
                          ),
                        );
                      },
                      child: Text(
                        'Forgot your password?',
                        style: GoogleFonts.asul(
                          color: const Color(0xFF928A8A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: _deviceHeight! * 0.04),

                  // Sign In Button with Loading State
                  _isLoading
                      ? Center(
                          child: Lottie.network(
                            'https://assets9.lottiefiles.com/packages/lf20_x62chJ.json',
                            // Loading animation
                            width: 80,
                            height: 80,
                          ),
                        )
                      : _primaryBtn(
                          onPressed: _submitForm,
                          text: 'Sign in',
                        ),

                  SizedBox(height: _deviceHeight! * 0.02),
                  // Sign Up Text
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: GoogleFonts.asul(
                          fontSize: 16,
                          color: const Color(0xFF928A8A),
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign up here',
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushNamed(context, 'register');
                              },
                            style: GoogleFonts.asul(
                              color: const Color(0xFF6B76F2),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Social Login Divider
                  Row(
                    children: [
                      const Expanded(
                          child:
                              Divider(thickness: 1, color: Color(0xFF928A8A))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Or continue with',
                          style:
                              GoogleFonts.asul(color: const Color(0xFF928A8A)),
                        ),
                      ),
                      const Expanded(
                          child:
                              Divider(thickness: 1, color: Color(0xFF928A8A))),
                    ],
                  ),

                  SizedBox(height: _deviceHeight! * 0.02),
                  // Social Login Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _socialButton(
                          icon: 'assets/images/facebook-icon.png',
                          text: 'Facebook',
                          onPressed: () {
                            // Facebook login logic
                            Navigator.pushReplacementNamed(context, 'home');
                          },
                        ),
                      ),
                      SizedBox(width: _deviceHeight! * 0.03),
                      Expanded(
                        child: _socialButton(
                          icon: 'assets/images/google-icon.png',
                          text: 'Google',
                          onPressed: () {
                            Navigator.pushNamed(context, 'notification');
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: _deviceHeight! * 0.02),

                  // Other Methods Button
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) => _buildOtherMethodsSheet(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      minimumSize: const Size(double.infinity, 54),
                      elevation: 2,
                    ),
                    child: Text(
                      "Other methods",
                      style: GoogleFonts.asul(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6B76F2),
                      ),
                    ),
                  ),

                  SizedBox(height: _deviceHeight! * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _primaryBtn({
    required VoidCallback onPressed,
    required String text,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6B76F2),
        padding: const EdgeInsets.all(15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        minimumSize: const Size(double.infinity, 54),
        elevation: 3,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: GoogleFonts.asul(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, color: Colors.white),
        ],
      ),
    );
  }

  Widget _socialButton({
    required String icon,
    required String text,
    required VoidCallback onPressed,
    Color textColor = const Color(0xFF6B76F2),
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            icon,
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.asul(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherMethodsSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            'assets/lottie/phoneauth.json', // Authentication animation
            height: 120,
            width: 120,
          ),
          const SizedBox(height: 16),
          Text(
            'Other Sign In Methods',
            style: GoogleFonts.asul(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6B76F2),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.phone, color: Color(0xFF6B76F2)),
            title: Text('Phone Number', style: GoogleFonts.asul()),
            onTap: () {
              Navigator.pop(context);
              if (_isOTPAvailable) {
                Navigator.pushNamed(context, 'phone-auth');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("This page could not be use for now!"),
                  backgroundColor: Colors.red,
                ));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.fingerprint, color: Color(0xFF6B76F2)),
            title: Text('Biometric Authentication', style: GoogleFonts.asul()),
            onTap: () {
              Navigator.pop(context);
              // Handle biometric auth
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("This page is not available yet!"),
                backgroundColor: Colors.orange,
              ));
            },
          ),
        ],
      ),
    );
  }
}
