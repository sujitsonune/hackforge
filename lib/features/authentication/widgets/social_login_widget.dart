import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/analytics_service.dart';
import '../providers/auth_provider.dart';

class SocialLoginWidget extends StatefulWidget {
  final String language;
  final bool showAnonymous;
  final VoidCallback? onSuccess;

  const SocialLoginWidget({
    Key? key,
    required this.language,
    this.showAnonymous = true,
    this.onSuccess,
  }) : super(key: key);

  @override
  State<SocialLoginWidget> createState() => _SocialLoginWidgetState();
}

class _SocialLoginWidgetState extends State<SocialLoginWidget> {
  bool _isGoogleLoading = false;
  bool _isAnonymousLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Google Sign In Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isGoogleLoading ? null : _signInWithGoogle,
            icon: _isGoogleLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.primaryColor,
                    ),
                  )
                : Image.asset(
                    'assets/icons/google_icon.png',
                    width: 20,
                    height: 20,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.account_circle,
                        size: 20,
                        color: theme.primaryColor,
                      );
                    },
                  ),
            label: Text(
              widget.language == 'hi'
                  ? 'Google के साथ जारी रखें'
                  : 'Continue with Google',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: theme.dividerColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        if (widget.showAnonymous) ...[
          const SizedBox(height: 16),
          
          // Anonymous Sign In Button
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _isAnonymousLoading ? null : _signInAnonymously,
              icon: _isAnonymousLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    )
                  : Icon(
                      Icons.person_outline,
                      size: 20,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
              label: Text(
                widget.language == 'hi'
                    ? 'गेस्ट के रूप में जारी रखें'
                    : 'Continue as Guest',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    
    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.signInWithGoogle();
      
      if (success) {
        await AnalyticsService.logUserLogin('google');
        
        if (widget.onSuccess != null) {
          widget.onSuccess!();
        } else if (mounted) {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
        
        if (mounted) {
          _showSnackBar(
            widget.language == 'hi'
                ? 'Google के साथ सफलतापूर्वक लॉगिन हुए'
                : 'Successfully signed in with Google',
            isError: false,
          );
        }
      } else {
        if (mounted) {
          _showSnackBar(
            authProvider.error ?? 
            (widget.language == 'hi'
                ? 'Google साइन इन में त्रुटि'
                : 'Google sign in failed'),
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          widget.language == 'hi'
              ? 'Google साइन इन में त्रुटि'
              : 'Google sign in failed',
          isError: true,
        );
      }
      
      AnalyticsService.logError(
        error: e.toString(),
        context: 'google_sign_in',
      );
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  Future<void> _signInAnonymously() async {
    setState(() => _isAnonymousLoading = true);
    
    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.signInAnonymously();
      
      if (success) {
        await AnalyticsService.logUserLogin('anonymous');
        
        if (widget.onSuccess != null) {
          widget.onSuccess!();
        } else if (mounted) {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
        
        if (mounted) {
          _showSnackBar(
            widget.language == 'hi'
                ? 'गेस्ट मोड में प्रवेश किया'
                : 'Entered guest mode',
            isError: false,
          );
        }
      } else {
        if (mounted) {
          _showSnackBar(
            authProvider.error ?? 
            (widget.language == 'hi'
                ? 'गेस्ट मोड में त्रुटि'
                : 'Guest mode failed'),
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          widget.language == 'hi'
              ? 'गेस्ट मोड में त्रुटि'
              : 'Guest mode failed',
          isError: true,
        );
      }
      
      AnalyticsService.logError(
        error: e.toString(),
        context: 'anonymous_sign_in',
      );
    } finally {
      if (mounted) {
        setState(() => _isAnonymousLoading = false);
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
}