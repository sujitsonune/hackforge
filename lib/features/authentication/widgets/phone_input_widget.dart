import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/auth_service.dart';

class PhoneInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final String language;
  final Function(String)? onChanged;
  final String? errorText;
  final bool enabled;

  const PhoneInputWidget({
    Key? key,
    required this.controller,
    required this.language,
    this.onChanged,
    this.errorText,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<PhoneInputWidget> createState() => _PhoneInputWidgetState();
}

class _PhoneInputWidgetState extends State<PhoneInputWidget> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return widget.language == 'hi'
          ? 'मोबाइल नंबर दर्ज करें'
          : 'Enter mobile number';
    }

    String? validationError = AuthService.validatePhone(value);
    if (validationError != null) {
      return widget.language == 'hi'
          ? 'कृपया एक वैध भारतीय मोबाइल नंबर दर्ज करें'
          : validationError;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.errorText != null
                  ? theme.colorScheme.error
                  : _isFocused
                      ? theme.primaryColor
                      : theme.dividerColor,
              width: _isFocused ? 2 : 1,
            ),
            color: widget.enabled 
                ? theme.inputDecorationTheme.fillColor ?? Colors.transparent
                : theme.disabledColor.withOpacity(0.1),
          ),
          child: Row(
            children: [
              // Country Code
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: theme.dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '🇮🇳',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+91',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: widget.enabled 
                            ? theme.textTheme.bodyLarge?.color
                            : theme.disabledColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Phone Number Input
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                    PhoneNumberFormatter(),
                  ],
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.language == 'hi'
                        ? '98765 43210'
                        : '98765 43210',
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.hintColor,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 1.2,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    errorStyle: const TextStyle(height: 0),
                  ),
                  validator: _validatePhone,
                  onChanged: widget.onChanged,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
        ),
        
        // Error Text
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              widget.errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        
        // Helper Text
        if (widget.errorText == null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              widget.language == 'hi'
                  ? 'हम आपको OTP भेजेंगे'
                  : 'We\'ll send you a verification code',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ),
      ],
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    if (text.length <= 5) {
      return newValue;
    }
    
    // Format as XXXXX XXXXX
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 5 && text.length > 5) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    
    final formattedText = buffer.toString();
    
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(
        offset: formattedText.length,
      ),
    );
  }
}

class IndianPhoneValidator {
  static const List<String> validPrefixes = [
    '6', '7', '8', '9' // Indian mobile numbers start with these digits
  ];
  
  static const List<String> operatorPrefixes = [
    // Jio
    '60', '61', '62', '63', '64', '65', '66', '67', '68', '69',
    // Airtel
    '70', '71', '72', '73', '74', '75', '76', '77', '78', '79',
    // VI (Vodafone Idea)
    '80', '81', '82', '83', '84', '85', '86', '87', '88', '89',
    // BSNL, Other operators
    '90', '91', '92', '93', '94', '95', '96', '97', '98', '99',
  ];
  
  static bool isValidIndianMobile(String phone) {
    // Remove all non-digit characters
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    
    // Check length
    if (digits.length != 10) return false;
    
    // Check if starts with valid prefix
    if (!validPrefixes.contains(digits[0])) return false;
    
    // Additional validation for specific operator ranges
    final prefix = digits.substring(0, 2);
    
    // Check if the prefix is in our operator prefixes list
    return operatorPrefixes.contains(prefix);
  }
  
  static String? getOperatorName(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) return null;
    
    final firstDigit = digits[0];
    
    switch (firstDigit) {
      case '6':
        return 'Jio';
      case '7':
        return 'Airtel';
      case '8':
        return 'VI (Vodafone Idea)';
      case '9':
        return 'BSNL/Other';
      default:
        return null;
    }
  }
  
  static bool isJio(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return digits.length == 10 && digits.startsWith('6');
  }
  
  static bool isAirtel(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return digits.length == 10 && digits.startsWith('7');
  }
  
  static bool isVI(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return digits.length == 10 && digits.startsWith('8');
  }
}