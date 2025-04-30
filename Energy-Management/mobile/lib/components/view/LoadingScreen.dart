import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieLoadingScreen extends StatefulWidget {
  final String? message;
  final Color backgroundColor;
  final Color textColor;
  final String? lottieUrl;
  final double animationSize;
  final bool dismissible;

  const LottieLoadingScreen({
    Key? key,
    this.message,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
    this.lottieUrl,
    this.animationSize = 200,
    this.dismissible = false,
  }) : super(key: key);

  /// Shows a loading screen as an overlay
  static Future<void> show(
      BuildContext context, {
        String? message,
        Color backgroundColor = Colors.white,
        Color textColor = Colors.black87,
        String? lottieUrl,
        double animationSize = 200,
        bool dismissible = false,
      }) async {
    return showDialog(
      context: context,
      barrierDismissible: dismissible,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return LottieLoadingScreen(
          message: message,
          backgroundColor: backgroundColor,
          textColor: textColor,
          lottieUrl: lottieUrl,
          animationSize: animationSize,
          dismissible: dismissible,
        );
      },
    );
  }

  /// Hides the loading screen
  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  State<LottieLoadingScreen> createState() => _LottieLoadingScreenState();
}

class _LottieLoadingScreenState extends State<LottieLoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  // Collection of high-quality Lottie loading animations
  final List<String> _defaultAnimations = [
    'https://assets9.lottiefiles.com/packages/lf20_x62chJ.json',       // Blue circular loader
    'https://assets10.lottiefiles.com/packages/lf20_kxsd2ytq.json',    // Colorful dots
    'https://assets2.lottiefiles.com/packages/lf20_p8bfn5to.json',     // Rocket launch
    'https://assets5.lottiefiles.com/packages/lf20_ydo1amjm.json',     // Liquid loading
    'https://assets3.lottiefiles.com/packages/lf20_b88nh30c.json',     // Pulse loader
    'https://assets6.lottiefiles.com/packages/lf20_usmfx6bp.json',     // Material design dots
    'https://assets9.lottiefiles.com/private_files/lf30_lndgkbvl.json', // Tech circuit loader
    'https://assets3.lottiefiles.com/packages/lf20_z9ed2jna.json',     // Gears loading
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String get _lottieAnimation => widget.lottieUrl ?? _getRandomAnimation();

  String _getRandomAnimation() {
    // Return a random animation from the collection
    return _defaultAnimations[DateTime.now().millisecondsSinceEpoch % _defaultAnimations.length];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => widget.dismissible,
      child: Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.network(
                _lottieAnimation,
                controller: _animationController,
                width: widget.animationSize,
                height: widget.animationSize,
                fit: BoxFit.contain,
                frameRate: FrameRate.max,
                errorBuilder: (context, error, stackTrace) {
                  return const CircularProgressIndicator();
                },
              ),
              if (widget.message != null) ...[
                const SizedBox(height: 16),
                Text(
                  widget.message!,
                  style: TextStyle(
                    color: widget.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Example usage:
class LoadingScreenExample extends StatelessWidget {
  const LoadingScreenExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loading Screen Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Show default loading screen
                LottieLoadingScreen.show(context, message: 'Loading...');

                // Auto-hide after 3 seconds for demo
                Future.delayed(const Duration(seconds: 3), () {
                  LottieLoadingScreen.hide(context);
                });
              },
              child: const Text('Show Default Loading'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Show custom loading screen
                LottieLoadingScreen.show(
                  context,
                  message: 'Processing your request...',
                  backgroundColor: Colors.blueGrey.shade900,
                  textColor: Colors.white,
                  lottieUrl: 'https://assets5.lottiefiles.com/packages/lf20_ydo1amjm.json',
                  animationSize: 150,
                );

                // Auto-hide after 3 seconds for demo
                Future.delayed(const Duration(seconds: 3), () {
                  LottieLoadingScreen.hide(context);
                });
              },
              child: const Text('Show Custom Loading'),
            ),
          ],
        ),
      ),
    );
  }
}