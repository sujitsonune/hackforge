import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../constants/app_constants.dart';
import '../../models/user_model.dart';
import 'firestore_service.dart';
import 'analytics_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static User? get currentUser => _auth.currentUser;
  static String? get currentUserId => _auth.currentUser?.uid;
  static bool get isLoggedIn => _auth.currentUser != null;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Phone Authentication for Indian users
  static Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    try {
      String formattedPhone = _formatIndianPhoneNumber(phoneNumber);
      
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        timeout: const Duration(seconds: 60),
      );
      
      await AnalyticsService.logEvent(
        AnalyticsConstants.eventUserSignup,
        parameters: {
          'method': 'phone',
          'phone_country': 'IN',
        },
      );
    } catch (e) {
      throw AuthException('Phone verification failed', e.toString());
    }
  }

  // Sign in with OTP
  static Future<UserCredential> signInWithOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        await _handleUserSignIn(userCredential.user!, 'phone');
      }
      
      return userCredential;
    } catch (e) {
      throw AuthException('OTP verification failed', e.toString());
    }
  }

  // Google Sign In
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null; // User cancelled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        await _handleUserSignIn(userCredential.user!, 'google');
      }
      
      return userCredential;
    } catch (e) {
      throw AuthException('Google sign in failed', e.toString());
    }
  }

  // Email/Password Sign Up
  static Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(name);
        
        // Create user document in Firestore
        final userModel = UserModel(
          uid: userCredential.user!.uid,
          name: name,
          email: email,
          phone: phone,
          preferredLanguage: 'hi',
          currency: 'INR',
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
          isPremium: false,
        );
        
        await FirestoreService.createUser(userModel);
        await _handleUserSignIn(userCredential.user!, 'email');
      }

      return userCredential;
    } catch (e) {
      throw AuthException('Email sign up failed', e.toString());
    }
  }

  // Email/Password Sign In
  static Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _handleUserSignIn(userCredential.user!, 'email');
      }

      return userCredential;
    } catch (e) {
      throw AuthException('Email sign in failed', e.toString());
    }
  }

  // Anonymous Sign In (Guest Mode)
  static Future<UserCredential> signInAnonymously() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      
      if (userCredential.user != null) {
        await _handleUserSignIn(userCredential.user!, 'anonymous');
      }
      
      return userCredential;
    } catch (e) {
      throw AuthException('Anonymous sign in failed', e.toString());
    }
  }

  // Password Reset
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      
      await AnalyticsService.logEvent(
        'password_reset_requested',
        parameters: {'method': 'email'},
      );
    } catch (e) {
      throw AuthException('Password reset failed', e.toString());
    }
  }

  // Link Anonymous Account
  static Future<UserCredential> linkAnonymousAccount({
    String? email,
    String? password,
    String? phoneNumber,
    bool useGoogle = false,
  }) async {
    try {
      if (_auth.currentUser?.isAnonymous != true) {
        throw AuthException('Not an anonymous account', 'Cannot link non-anonymous account');
      }

      AuthCredential credential;

      if (useGoogle) {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) throw AuthException('Google sign in cancelled', 'User cancelled');
        
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
      } else if (email != null && password != null) {
        credential = EmailAuthProvider.credential(email: email, password: password);
      } else {
        throw AuthException('Invalid linking parameters', 'Must provide email/password or use Google');
      }

      UserCredential userCredential = await _auth.currentUser!.linkWithCredential(credential);
      
      if (userCredential.user != null) {
        await _updateUserLastLogin(userCredential.user!.uid);
      }
      
      return userCredential;
    } catch (e) {
      throw AuthException('Account linking failed', e.toString());
    }
  }

  // Sign Out
  static Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      
      await AnalyticsService.logEvent('user_logout');
    } catch (e) {
      throw AuthException('Sign out failed', e.toString());
    }
  }

  // Delete Account
  static Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw AuthException('No user signed in', 'Cannot delete account');

      // Delete user data from Firestore first
      // This should be done carefully to maintain referential integrity
      
      await user.delete();
      
      await AnalyticsService.logEvent('user_account_deleted');
    } catch (e) {
      throw AuthException('Account deletion failed', e.toString());
    }
  }

  // Update Profile
  static Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw AuthException('No user signed in', 'Cannot update profile');

      await user.updateDisplayName(displayName);
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }
    } catch (e) {
      throw AuthException('Profile update failed', e.toString());
    }
  }

  // Check if phone number is already registered
  static Future<bool> isPhoneNumberRegistered(String phoneNumber) async {
    try {
      String formattedPhone = _formatIndianPhoneNumber(phoneNumber);
      
      // Query Firestore to check if phone number exists
      final user = await FirestoreService.getUser(_auth.currentUser?.uid ?? '');
      
      // This is a simplified check - in production, you might want to implement
      // a more robust phone number verification system
      return user != null && user.phone == formattedPhone;
    } catch (e) {
      return false;
    }
  }

  // Get current user model
  static Future<UserModel?> getCurrentUserModel() async {
    if (!isLoggedIn) return null;
    
    return await FirestoreService.getUser(currentUserId!);
  }

  // Private helper methods
  static String _formatIndianPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    String digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    // If it starts with 91, remove it
    if (digits.startsWith('91') && digits.length == 12) {
      digits = digits.substring(2);
    }
    
    // If it doesn't start with +91, add it
    if (digits.length == 10 && RegExp(r'^[6-9]').hasMatch(digits)) {
      return '+91$digits';
    }
    
    throw AuthException('Invalid phone number', 'Please enter a valid Indian mobile number');
  }

  static Future<void> _handleUserSignIn(User user, String method) async {
    try {
      // Update last login time
      await _updateUserLastLogin(user.uid);
      
      // Log analytics event
      await AnalyticsService.logEvent(
        AnalyticsConstants.eventUserLogin,
        parameters: {
          'method': method,
          'user_id': user.uid,
        },
      );
      
      // Set user properties for analytics
      await AnalyticsService.setUserId(user.uid);
      
      // Check if user document exists in Firestore
      UserModel? existingUser = await FirestoreService.getUser(user.uid);
      
      if (existingUser == null && !user.isAnonymous) {
        // Create new user document
        final userModel = UserModel(
          uid: user.uid,
          name: user.displayName ?? 'User',
          email: user.email,
          phone: user.phoneNumber ?? '',
          preferredLanguage: 'hi',
          currency: 'INR',
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
          isPremium: false,
        );
        
        await FirestoreService.createUser(userModel);
        
        await AnalyticsService.logEvent(
          AnalyticsConstants.eventUserSignup,
          parameters: {
            'method': method,
            'user_id': user.uid,
          },
        );
      }
    } catch (e) {
      print('Error in _handleUserSignIn: $e');
      // Don't throw error here to avoid breaking the sign-in flow
    }
  }

  static Future<void> _updateUserLastLogin(String uid) async {
    try {
      UserModel? user = await FirestoreService.getUser(uid);
      if (user != null) {
        await FirestoreService.updateUser(
          user.copyWith(lastLogin: DateTime.now())
        );
      }
    } catch (e) {
      print('Error updating last login: $e');
    }
  }

  // Validation helpers
  static bool isValidEmail(String email) {
    return RegExp(ValidationConstants.emailRegex).hasMatch(email);
  }

  static bool isValidIndianPhone(String phone) {
    String digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('91') && digits.length == 12) {
      digits = digits.substring(2);
    }
    return RegExp(ValidationConstants.phoneRegex).hasMatch(digits);
  }

  static bool isValidPassword(String password) {
    return password.length >= ValidationConstants.minPasswordLength &&
           password.length <= ValidationConstants.maxPasswordLength &&
           !ValidationConstants.commonPasswords.contains(password.toLowerCase());
  }

  static String? validateName(String name) {
    if (name.trim().isEmpty) {
      return 'Name cannot be empty';
    }
    if (name.trim().length < ValidationConstants.minNameLength) {
      return 'Name must be at least ${ValidationConstants.minNameLength} characters';
    }
    if (name.trim().length > ValidationConstants.maxNameLength) {
      return 'Name must be less than ${ValidationConstants.maxNameLength} characters';
    }
    return null;
  }

  static String? validateEmail(String email) {
    if (email.trim().isEmpty) {
      return 'Email cannot be empty';
    }
    if (!isValidEmail(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePhone(String phone) {
    if (phone.trim().isEmpty) {
      return 'Phone number cannot be empty';
    }
    if (!isValidIndianPhone(phone)) {
      return 'Please enter a valid Indian mobile number';
    }
    return null;
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password cannot be empty';
    }
    if (!isValidPassword(password)) {
      if (password.length < ValidationConstants.minPasswordLength) {
        return 'Password must be at least ${ValidationConstants.minPasswordLength} characters';
      }
      if (ValidationConstants.commonPasswords.contains(password.toLowerCase())) {
        return 'Please choose a stronger password';
      }
    }
    return null;
  }
}

class AuthException implements Exception {
  final String message;
  final String details;
  
  AuthException(this.message, this.details);
  
  @override
  String toString() => 'AuthException: $message - $details';
}