import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/analytics_service.dart';
import '../providers/auth_provider.dart';

class EmailLoginScreen extends StatefulWidget {
  final String language;

  const EmailLoginScreen({
    Key? key,
    this.language = 'hi',
  }) : super(key: key);

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
    
    AnalyticsService.logScreenView(screenName: 'email_login_screen');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      bool success = false;

      if (_isLogin) {
        success = await authProvider.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        success = await authProvider.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        );
      }

      if (success && mounted) {
        _showSnackBar(
          _isLogin
              ? (widget.language == 'hi' ? 'सफलतापूर्वक लॉगिन हुए' : 'Successfully signed in')
              : (widget.language == 'hi' ? 'खाता बनाया गया' : 'Account created'),
          isError: false,
        );

        Navigator.of(context).pushReplacementNamed('/dashboard');
      } else if (mounted) {
        _showSnackBar(
          authProvider.error ?? 
          (_isLogin 
              ? (widget.language == 'hi' ? 'लॉगिन में त्रुटि' : 'Login failed')
              : (widget.language == 'hi' ? 'खाता बनाने में त्रुटि' : 'Sign up failed')),
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          _isLogin 
              ? (widget.language == 'hi' ? 'लॉगिन में त्रुटि' : 'Login failed')
              : (widget.language == 'hi' ? 'खाता बनाने में त्रुटि' : 'Sign up failed'),
          isError: true,
        );
      }
      
      AnalyticsService.logError(
        error: e.toString(),
        context: _isLogin ? 'email_login' : 'email_signup',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isLogin 
              ? (widget.language == 'hi' ? 'ईमेल लॉगिन' : 'Email Login')
              : (widget.language == 'hi' ? 'खाता बनाएं' : 'Create Account'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  
                  // Toggle between Login/Signup
                  Container(
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isLogin = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: _isLogin ? theme.primaryColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.language == 'hi' ? 'लॉगिन' : 'Login',
                                style: TextStyle(
                                  color: _isLogin ? Colors.white : theme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isLogin = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: !_isLogin ? theme.primaryColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.language == 'hi' ? 'साइन अप' : 'Sign Up',
                                style: TextStyle(
                                  color: !_isLogin ? Colors.white : theme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Name Field (for signup only)
                  if (!_isLogin) ...[
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: widget.language == 'hi' ? 'नाम' : 'Name',
                        hintText: widget.language == 'hi' ? 'अपना नाम दर्ज करें' : 'Enter your name',
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        final authProvider = context.read<AuthProvider>();
                        return authProvider.validateName(value ?? '');
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: widget.language == 'hi' ? 'ईमेल' : 'Email',
                      hintText: widget.language == 'hi' ? 'ईमेल दर्ज करें' : 'Enter your email',
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      final authProvider = context.read<AuthProvider>();
                      return authProvider.validateEmail(value ?? '');
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Phone Field (for signup only)
                  if (!_isLogin) ...[
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: widget.language == 'hi' ? 'फोन नंबर' : 'Phone Number',
                        hintText: widget.language == 'hi' ? 'फोन नंबर दर्ज करें' : 'Enter phone number',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        prefixText: '+91 ',
                      ),
                      validator: (value) {
                        final authProvider = context.read<AuthProvider>();
                        return authProvider.validatePhone(value ?? '');
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: widget.language == 'hi' ? 'पासवर्ड' : 'Password',
                      hintText: widget.language == 'hi' ? 'पासवर्ड दर्ज करें' : 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (value) {
                      final authProvider = context.read<AuthProvider>();
                      return authProvider.validatePassword(value ?? '');
                    },
                    textInputAction: _isLogin ? TextInputAction.done : TextInputAction.next,
                    onFieldSubmitted: (_) {
                      if (_isLogin && !_isLoading) {
                        _submit();
                      }
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Submit Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
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
                            _isLogin 
                                ? (widget.language == 'hi' ? 'लॉगिन' : 'Login')
                                : (widget.language == 'hi' ? 'खाता बनाएं' : 'Create Account'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Forgot Password (for login only)
                  if (_isLogin)
                    TextButton(
                      onPressed: _isLoading ? null : _showForgotPasswordDialog,
                      child: Text(
                        widget.language == 'hi' ? 'पासवर्ड भूल गए?' : 'Forgot Password?',
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

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          widget.language == 'hi' ? 'पासवर्ड रीसेट' : 'Reset Password',
        ),
        content: TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: widget.language == 'hi' ? 'ईमेल' : 'Email',
            hintText: widget.language == 'hi' ? 'ईमेल दर्ज करें' : 'Enter your email',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              widget.language == 'hi' ? 'रद्द करें' : 'Cancel',
            ),
          ),
          TextButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty) {
                final authProvider = context.read<AuthProvider>();
                final success = await authProvider.resetPassword(emailController.text.trim());
                
                if (mounted) {
                  Navigator.pop(context);
                  _showSnackBar(
                    success 
                        ? (widget.language == 'hi' 
                            ? 'रीसेट लिंक भेजा गया' 
                            : 'Reset link sent')
                        : (authProvider.error ?? 
                            (widget.language == 'hi' 
                                ? 'रीसेट में त्रुटि' 
                                : 'Reset failed')),
                    isError: !success,
                  );
                }
              }
            },
            child: Text(
              widget.language == 'hi' ? 'भेजें' : 'Send',
            ),
          ),
        ],
      ),
    );
  }
}