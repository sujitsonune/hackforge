import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/phone_input_widget.dart';
import '../widgets/social_login_widget.dart';
import 'otp_verification_screen.dart';
import 'email_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> 
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _agreedToTerms = false;
  String _selectedLanguage = 'hi';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));
    
    _animationController.forward();
    AnalyticsService.logScreenView(screenName: 'login_screen');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate() || !_agreedToTerms) {
      if (!_agreedToTerms) {
        _showSnackBar(
          _selectedLanguage == 'hi' 
              ? 'कृपया नियम और शर्तें स्वीकार करें'
              : 'Please accept terms and conditions',
          isError: true,
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      
      await AuthService.verifyPhoneNumber(
        phoneNumber: _phoneController.text,
        verificationCompleted: (credential) async {
          try {
            await AuthService.signInWithOTP(
              verificationId: '', 
              smsCode: credential.smsCode ?? '',
            );
            
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/dashboard');
            }
          } catch (e) {
            _handleError(e);
          }
        },
        verificationFailed: (e) {
          _handleError(e);
        },
        codeSent: (verificationId, resendToken) {
          authProvider.setVerificationId(verificationId);
          authProvider.setResendToken(resendToken);
          
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OTPVerificationScreen(
                phoneNumber: _phoneController.text,
                verificationId: verificationId,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {
          authProvider.setVerificationId(verificationId);
        },
      );
    } catch (e) {
      _handleError(e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleError(dynamic error) {
    String message = _selectedLanguage == 'hi' 
        ? ErrorMessages.getMessage('auth_failed', 'hi')
        : ErrorMessages.getMessage('auth_failed', 'en');
    
    if (error.toString().contains('invalid-phone-number')) {
      message = _selectedLanguage == 'hi' 
          ? ErrorMessages.getMessage('invalid_phone', 'hi')
          : ErrorMessages.getMessage('invalid_phone', 'en');
    }
    
    _showSnackBar(message, isError: true);
    
    AnalyticsService.logError(
      error: error.toString(),
      context: 'phone_verification',
      additionalData: {'phone': _phoneController.text},
    );
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primaryColor.withOpacity(0.1),
              theme.scaffoldBackgroundColor,
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: size.height * 0.05),
                  
                  // Language Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildLanguageSelector(),
                    ],
                  ),
                  
                  SizedBox(height: size.height * 0.05),
                  
                  // App Logo and Title
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: theme.primaryColor.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.subscriptions,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          AppConstants.appName,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedLanguage == 'hi'
                              ? 'भारतीय उपयोगकर्ताओं के लिए सब्स्क्रिप्शन ट्रैकर'
                              : 'Subscription Tracker for Indian Users',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: size.height * 0.08),
                  
                  // Login Form
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _selectedLanguage == 'hi'
                                ? 'अपना मोबाइल नंबर दर्ज करें'
                                : 'Enter your mobile number',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedLanguage == 'hi'
                                ? 'हम आपको OTP भेजेंगे'
                                : 'We will send you an OTP',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          
                          // Phone Input
                          PhoneInputWidget(
                            controller: _phoneController,
                            language: _selectedLanguage,
                            onChanged: (value) => setState(() {}),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Terms and Conditions
                          Row(
                            children: [
                              Checkbox(
                                value: _agreedToTerms,
                                onChanged: (value) {
                                  setState(() => _agreedToTerms = value ?? false);
                                },
                                activeColor: theme.primaryColor,
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => _agreedToTerms = !_agreedToTerms);
                                  },
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: _selectedLanguage == 'hi'
                                              ? 'मैं '
                                              : 'I agree to the ',
                                        ),
                                        TextSpan(
                                          text: _selectedLanguage == 'hi'
                                              ? 'नियम और शर्तें'
                                              : 'Terms & Conditions',
                                          style: TextStyle(
                                            color: theme.primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        TextSpan(
                                          text: _selectedLanguage == 'hi'
                                              ? ' और '
                                              : ' and ',
                                        ),
                                        TextSpan(
                                          text: _selectedLanguage == 'hi'
                                              ? 'प्राइवेसी पॉलिसी'
                                              : 'Privacy Policy',
                                          style: TextStyle(
                                            color: theme.primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        TextSpan(
                                          text: _selectedLanguage == 'hi'
                                              ? ' से सहमत हूं'
                                              : '',
                                        ),
                                      ],
                                    ),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Send OTP Button
                          ElevatedButton(
                            onPressed: _isLoading ? null : _sendOTP,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
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
                                    _selectedLanguage == 'hi'
                                        ? 'OTP भेजें'
                                        : 'Send OTP',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Divider
                          Row(
                            children: [
                              Expanded(child: Divider(color: theme.dividerColor)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  _selectedLanguage == 'hi' ? 'या' : 'OR',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: theme.dividerColor)),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Social Login Options
                          SocialLoginWidget(language: _selectedLanguage),
                          
                          const SizedBox(height: 32),
                          
                          // Email Login Option
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => EmailLoginScreen(
                                    language: _selectedLanguage,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              _selectedLanguage == 'hi'
                                  ? 'ईमेल से लॉगिन करें'
                                  : 'Login with Email',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Guest Mode
                          TextButton(
                            onPressed: _isLoading ? null : _signInAsGuest,
                            child: Text(
                              _selectedLanguage == 'hi'
                                  ? 'गेस्ट के रूप में जारी रखें'
                                  : 'Continue as Guest',
                              style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLanguage,
          items: [
            DropdownMenuItem(
              value: 'hi',
              child: Text(AppConstants.languageNames['hi']!),
            ),
            DropdownMenuItem(
              value: 'en',
              child: Text(AppConstants.languageNames['en']!),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedLanguage = value);
              AnalyticsService.logLanguageChange(
                fromLanguage: _selectedLanguage,
                toLanguage: value,
              );
            }
          },
          icon: const Icon(Icons.arrow_drop_down),
          iconSize: 20,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Future<void> _signInAsGuest() async {
    setState(() => _isLoading = true);
    
    try {
      await AuthService.signInAnonymously();
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      _handleError(e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}