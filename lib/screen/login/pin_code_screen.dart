import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:quicserve_flutter/constants/theme.dart';
import 'package:quicserve_flutter/providers/auth_provider.dart';
import 'package:quicserve_flutter/widgets/side_menu.dart';
//import 'package:vibration/vibration.dart';

class PinCodeScreen extends StatefulWidget {
  const PinCodeScreen({super.key});

  @override
  State<PinCodeScreen> createState() => _PinCodeScreenState();
}

class _PinCodeScreenState extends State<PinCodeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<String> _pin = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _playTapSound() async {
    try {
      await _audioPlayer.setAsset('assets/sounds/keytap.mp3');
      await _audioPlayer.play();
      await _audioPlayer.setVolume(1.0);
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  /* Future<void> //_vibrate() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 50);
    }
  } */

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);

    // Fade animation for center container
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    _fadeController.forward(); // start fade-in

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).loadSession().then((_) {
        if (Provider.of<AuthProvider>(context, listen: false).isLoggedIn) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SideMenu2()));
        }
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _shakeController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onKeyPressed(String value) {
    _playTapSound();
    //_vibrate();
    setState(() {
      if (_pin.length < 4) {
        _pin.add(value);
      }
    });
  }

  void _onReset() {
    _playTapSound();
    //_vibrate();
    setState(() {
      _pin.clear();
    });
  }

  void _onSubmit() async {
    _playTapSound();
    //_vibrate();

    if (_pin.length < 4) {
      setState(() {
        _errorMessage = 'Please enter a 4-digit PIN.';
      });
      _shakeController.forward(from: 0).then((_) => _shakeController.reset());
      _onReset();
      return;
    }

    final pin = _pin.join();
    print('Submitting PIN: $pin');

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await Provider.of<AuthProvider>(context, listen: false).loginWithPin(pin);
      if (!mounted) return;

      setState(() => _isLoading = false);

      if (result) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SideMenu2()));
      } else {
        throw Exception('Login failed unexpectedly');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      _shakeController.forward(from: 0).then((_) => _shakeController.reset());
      _onReset();
    }
  }

  Widget _buildPinDisplay() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 50,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.center,
              child: Text(
                index < _pin.length ? '*' : '',
                style: CustomFont.daysone24.copyWith(
                  color: const Color(0xFF3371B9),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildKey(String value, {bool isAction = false}) {
    return GestureDetector(
      onTap: () {
        if (value == 'C') {
          _onReset();
        } else if (value == '>') {
          _onSubmit();
        } else {
          _onKeyPressed(value);
        }
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Center(
            child: (value == '>' || value == 'C')
                ? CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(
                      value == '>' ? Icons.check : Icons.close,
                      color: AppColors.white,
                    ),
                  )
                : Text(
                    value,
                    style: CustomFont.daysone32.copyWith(
                      color: AppColors.white,
                    ),
                  )),
      ),
    );
  }

  Widget _buildKeypad() {
    const keys = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      'C',
      '0',
      '>'
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: keys.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 5,
          crossAxisSpacing: 2,
          childAspectRatio: 1.6,
        ),
        itemBuilder: (_, i) {
          return _buildKey(keys[i], isAction: keys[i] == 'C' || keys[i] == '>');
        },
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.4),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        _buildMainUI(),
        if (_isLoading) _buildLoadingOverlay(),
      ]),
    );
  }

  Widget _buildMainUI() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.blue,
            AppColors.teal
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;

          return Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.blue,
                      AppColors.teal
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.black,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    )
                  ],
                ),
                width: isTablet ? 500 : double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/quicserveyellow.png',
                          width: 220,
                          height: 70,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Enter a cashier PIN Number",
                      style: CustomFont.daysone24.copyWith(
                        color: AppColors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildPinDisplay(),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    _buildKeypad(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
