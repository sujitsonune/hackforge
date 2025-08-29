import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final String language;

  const OTPVerificationScreen({
    Key? key,
    required this.phoneNumber,
    required this.verificationId,
    this.language = 'hi',
  }) : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen>
    with TickerProviderStateMixin {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _canResend = false;
  int _resendTimer = 60;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _animationController.forward();
    _startResendTimer();
    
    AnalyticsService.logScreenView(screenName: 'otp_verification_screen');
  }

  @override
  void dispose() {
    _otpController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendTimer > 0) {
        setState(() => _resendTimer--);
        _startResendTimer();
      } else if (mounted) {
        setState(() => _canResend = true);
      }
    });
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != ValidationConstants.otpLength) {
      _showSnackBar(
        widget.language == 'hi'
            ? 'कृपया ${ValidationConstants.otpLength} अंकों का OTP दर्ज करें'
            : 'Please enter ${ValidationConstants.otpLength} digit OTP',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.verifyOTP(_otpController.text);

      if (success && mounted) {
        _showSnackBar(
          widget.language == 'hi'
              ? 'OTP सत्यापित हो गया!'
              : 'OTP verified successfully!',
          isError: false,
        );

        // Navigate to dashboard
        Navigator.of(context).pushReplacementNamed('/dashboard');
      } else if (mounted) {
        _showSnackBar(
          authProvider.error ?? 
          (widget.language == 'hi'
              ? ErrorMessages.getMessage('invalid_otp', 'hi')
              : ErrorMessages.getMessage('invalid_otp', 'en')),
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          widget.language == 'hi'
              ? 'OTP सत्यापन में त्रुटि'
              : 'OTP verification failed',
          isError: true,
        );
      }
      
      AnalyticsService.logError(
        error: e.toString(),
        context: 'otp_verification',
        additionalData: {'phone': widget.phoneNumber},
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;

    setState(() {
      _canResend = false;
      _resendTimer = 60;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.verifyPhoneNumber(widget.phoneNumber);

      _showSnackBar(
        widget.language == 'hi'
            ? 'OTP पुनः भेजा गया'
            : 'OTP resent successfully',
        isError: false,
      );

      _startResendTimer();
      
      AnalyticsService.logEvent(
        'otp_resent',
        parameters: {'phone': widget.phoneNumber},
      );
    } catch (e) {
      setState(() => _canResend = true);
      
      _showSnackBar(
        widget.language == 'hi'
            ? 'OTP पुनः भेजने में त्रुटि'
            : 'Failed to resend OTP',
        isError: true,
      );
      
      AnalyticsService.logError(
        error: e.toString(),
        context: 'otp_resend',
      );
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.language == 'hi' ? 'OTP सत्यापन' : 'OTP Verification',
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: size.height * 0.05),
                
                // Header
                Icon(
                  Icons.sms_outlined,
                  size: 80,
                  color: theme.primaryColor,
                ),
                
                const SizedBox(height: 32),
                
                Text(
                  widget.language == 'hi'
                      ? 'OTP दर्ज करें'
                      : 'Enter OTP',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  widget.language == 'hi'
                      ? 'हमने ${_formatPhoneNumber(widget.phoneNumber)} पर OTP भेजा है'
                      : 'We sent an OTP to ${_formatPhoneNumber(widget.phoneNumber)}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // OTP Input
                PinCodeTextField(
                  appContext: context,
                  length: ValidationConstants.otpLength,
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  animationType: AnimationType.fade,
                  enableActiveFill: true,
                  textStyle: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(12),
                    fieldHeight: 60,
                    fieldWidth: 50,
                    activeFillColor: theme.primaryColor.withOpacity(0.1),
                    selectedFillColor: theme.primaryColor.withOpacity(0.1),
                    inactiveFillColor: theme.inputDecorationTheme.fillColor ?? Colors.transparent,
                    activeColor: theme.primaryColor,
                    selectedColor: theme.primaryColor,
                    inactiveColor: theme.dividerColor,
                  ),
                  cursorColor: theme.primaryColor,
                  onChanged: (value) {
                    setState(() {});
                  },
                  onCompleted: (value) {
                    if (!_isLoading) {
                      _verifyOTP();
                    }
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Verify Button
                ElevatedButton(
                  onPressed: (_isLoading || _otpController.text.length != ValidationConstants.otpLength)
                      ? null
                      : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.language == 'hi' ? 'सत्यापित करें' : 'Verify',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                
                const SizedBox(height: 24),
                
                // Resend OTP
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.language == 'hi'
                          ? 'OTP नहीं मिला? '
                          : 'Didn\'t receive OTP? ',
                      style: theme.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: _canResend ? _resendOTP : null,
                      child: Text(
                        _canResend
                            ? (widget.language == 'hi' ? 'पुनः भेजें' : 'Resend')
                            : '${widget.language == 'hi' ? 'पुनः भेजें ' : 'Resend in '}($_resendTimer s)',
                        style: TextStyle(
                          color: _canResend ? theme.primaryColor : theme.disabledColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Edit Phone Number
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.edit, size: 18),
                  label: Text(
                    widget.language == 'hi'
                        ? 'फोन नंबर बदलें'
                        : 'Change Phone Number',
                  ),
                ),
                
                const Spacer(),
                
                // Auto-fill hint
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.language == 'hi'
                              ? 'OTP अपने आप भर जाएगा'
                              : 'OTP will be auto-filled',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatPhoneNumber(String phoneNumber) {
    // Format phone number for display
    String digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    if (digits.startsWith('91') && digits.length == 12) {
      digits = digits.substring(2);
    }
    
    if (digits.length == 10) {
      return '+91 ${digits.substring(0, 5)} ${digits.substring(5)}';
    }
    
    return phoneNumber;
  }
}