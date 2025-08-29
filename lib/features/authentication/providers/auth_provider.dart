import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/analytics_service.dart';
import '../../../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _verificationId;
  int? _resendToken;
  String? _error;
  bool _isInitialized = false;

  // Getters
  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null && !_user!.isAnonymous;
  bool get isAnonymous => _user?.isAnonymous ?? false;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  String? get verificationId => _verificationId;
  int? get resendToken => _resendToken;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    AuthService.authStateChanges.listen((User? user) async {
      _user = user;
      
      if (user != null && !user.isAnonymous) {
        await _loadUserModel();
      } else {
        _userModel = null;
      }
      
      _isInitialized = true;
      notifyListeners();
    });
  }

  Future<void> _loadUserModel() async {
    try {
      if (_user != null) {
        _userModel = await FirestoreService.getUser(_user!.uid);
      }
    } catch (e) {
      _error = e.toString();
      AnalyticsService.logError(
        error: e.toString(),
        context: 'load_user_model',
        additionalData: {'user_id': _user?.uid},
      );
    }
  }

  // Phone Authentication
  Future<bool> verifyPhoneNumber(String phoneNumber) async {
    _setLoading(true);
    _clearError();
    
    try {
      bool verificationCompleted = false;
      
      await AuthService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await AuthService.signInWithOTP(
              verificationId: credential.verificationId ?? '',
              smsCode: credential.smsCode ?? '',
            );
            verificationCompleted = true;
          } catch (e) {
            _setError(e.toString());
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          _setError(e.message ?? 'Phone verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
      
      return !verificationCompleted; // Return true if code was sent, false if auto-verified
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // OTP Verification
  Future<bool> verifyOTP(String otp) async {
    if (_verificationId == null) {
      _setError('Verification ID not found');
      return false;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final credential = await AuthService.signInWithOTP(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      
      if (credential.user != null) {
        await AnalyticsService.logUserLogin('phone', userId: credential.user!.uid);
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Google Sign In
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();
    
    try {
      final credential = await AuthService.signInWithGoogle();
      
      if (credential?.user != null) {
        await AnalyticsService.logUserLogin('google', userId: credential!.user!.uid);
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Email Sign Up
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final credential = await AuthService.createUserWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
      
      if (credential.user != null) {
        await AnalyticsService.logUserSignup('email', userId: credential.user!.uid);
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Email Sign In
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final credential = await AuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        await AnalyticsService.logUserLogin('email', userId: credential.user!.uid);
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Anonymous Sign In
  Future<bool> signInAnonymously() async {
    _setLoading(true);
    _clearError();
    
    try {
      final credential = await AuthService.signInAnonymously();
      
      if (credential.user != null) {
        await AnalyticsService.logUserLogin('anonymous', userId: credential.user!.uid);
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Link Anonymous Account
  Future<bool> linkAnonymousAccount({
    String? email,
    String? password,
    bool useGoogle = false,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final credential = await AuthService.linkAnonymousAccount(
        email: email,
        password: password,
        useGoogle: useGoogle,
      );
      
      if (credential.user != null) {
        await AnalyticsService.logEvent(
          'account_linked',
          parameters: {
            'method': useGoogle ? 'google' : 'email',
            'user_id': credential.user!.uid,
          },
        );
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Password Reset
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();
    
    try {
      await AuthService.resetPassword(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update User Profile
  Future<bool> updateUserProfile({
    String? name,
    String? email,
    String? phone,
    String? preferredLanguage,
  }) async {
    if (_userModel == null) return false;
    
    _setLoading(true);
    _clearError();
    
    try {
      final updatedUser = _userModel!.copyWith(
        name: name ?? _userModel!.name,
        email: email ?? _userModel!.email,
        phone: phone ?? _userModel!.phone,
        preferredLanguage: preferredLanguage ?? _userModel!.preferredLanguage,
      );
      
      await FirestoreService.updateUser(updatedUser);
      _userModel = updatedUser;
      
      // Update Firebase Auth profile if needed
      if (name != null && name != _user?.displayName) {
        await AuthService.updateProfile(displayName: name);
      }
      
      await AnalyticsService.logEvent(
        'profile_updated',
        parameters: {
          'user_id': _userModel!.uid,
          'fields_updated': [
            if (name != null) 'name',
            if (email != null) 'email',
            if (phone != null) 'phone',
            if (preferredLanguage != null) 'language',
          ].join(','),
        },
      );
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    _setLoading(true);
    
    try {
      await AuthService.signOut();
      _user = null;
      _userModel = null;
      _verificationId = null;
      _resendToken = null;
      _clearError();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Delete Account
  Future<bool> deleteAccount() async {
    _setLoading(true);
    _clearError();
    
    try {
      await AuthService.deleteAccount();
      _user = null;
      _userModel = null;
      _verificationId = null;
      _resendToken = null;
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void setVerificationId(String verificationId) {
    _verificationId = verificationId;
    notifyListeners();
  }

  void setResendToken(int? resendToken) {
    _resendToken = resendToken;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
    
    // Log error for analytics
    AnalyticsService.logError(
      error: error,
      context: 'auth_provider',
    );
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // Validation helpers
  bool isValidEmail(String email) => AuthService.isValidEmail(email);
  bool isValidPhone(String phone) => AuthService.isValidIndianPhone(phone);
  bool isValidPassword(String password) => AuthService.isValidPassword(password);
  
  String? validateName(String name) => AuthService.validateName(name);
  String? validateEmail(String email) => AuthService.validateEmail(email);
  String? validatePhone(String phone) => AuthService.validatePhone(phone);
  String? validatePassword(String password) => AuthService.validatePassword(password);
}