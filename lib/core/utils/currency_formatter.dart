import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String formatIndianCurrency(double amount, {bool includeSymbol = true}) {
    final formatter = NumberFormat('#,##,##0', 'hi_IN');
    final formattedAmount = formatter.format(amount);
    return includeSymbol ? '₹$formattedAmount' : formattedAmount;
  }

  static String formatIndianCurrencyWithDecimals(double amount, {bool includeSymbol = true, int decimalPlaces = 2}) {
    final formatter = NumberFormat('#,##,##0.${'0' * decimalPlaces}', 'hi_IN');
    final formattedAmount = formatter.format(amount);
    return includeSymbol ? '₹$formattedAmount' : formattedAmount;
  }

  static String formatCurrencyCompact(double amount, {bool includeSymbol = true}) {
    if (amount < 1000) {
      return formatIndianCurrency(amount, includeSymbol: includeSymbol);
    } else if (amount < 100000) {
      double thousands = amount / 1000;
      return includeSymbol ? '₹${thousands.toStringAsFixed(1)}K' : '${thousands.toStringAsFixed(1)}K';
    } else if (amount < 10000000) {
      double lakhs = amount / 100000;
      return includeSymbol ? '₹${lakhs.toStringAsFixed(1)}L' : '${lakhs.toStringAsFixed(1)}L';
    } else {
      double crores = amount / 10000000;
      return includeSymbol ? '₹${crores.toStringAsFixed(1)}Cr' : '${crores.toStringAsFixed(1)}Cr';
    }
  }

  static String formatMonthlySavings(double monthlyAmount) {
    return '${formatIndianCurrency(monthlyAmount)}/month';
  }

  static String formatYearlySavings(double yearlyAmount) {
    return '${formatIndianCurrency(yearlyAmount)}/year';
  }

  static String formatBillingCycle(double amount, String cycle) {
    final formattedAmount = formatIndianCurrency(amount);
    switch (cycle.toLowerCase()) {
      case 'weekly':
        return '$formattedAmount/week';
      case 'monthly':
        return '$formattedAmount/month';
      case 'quarterly':
        return '$formattedAmount/quarter';
      case 'halfyearly':
        return '$formattedAmount/6 months';
      case 'yearly':
        return '$formattedAmount/year';
      default:
        return '$formattedAmount/$cycle';
    }
  }

  static String formatPercentage(double percentage, {int decimalPlaces = 1}) {
    return '${percentage.toStringAsFixed(decimalPlaces)}%';
  }

  static String formatSavingsPercentage(double originalAmount, double discountedAmount) {
    if (originalAmount <= 0) return '0%';
    double savingsPercentage = ((originalAmount - discountedAmount) / originalAmount) * 100;
    return formatPercentage(savingsPercentage);
  }

  static Map<String, String> formatCostBreakdown(double amount, String billingCycle) {
    Map<String, String> breakdown = {};
    
    switch (billingCycle.toLowerCase()) {
      case 'weekly':
        breakdown['weekly'] = formatIndianCurrency(amount);
        breakdown['monthly'] = formatIndianCurrency(amount * 4.33);
        breakdown['yearly'] = formatIndianCurrency(amount * 52);
        break;
      case 'monthly':
        breakdown['weekly'] = formatIndianCurrency(amount / 4.33);
        breakdown['monthly'] = formatIndianCurrency(amount);
        breakdown['yearly'] = formatIndianCurrency(amount * 12);
        break;
      case 'quarterly':
        breakdown['weekly'] = formatIndianCurrency(amount / 13);
        breakdown['monthly'] = formatIndianCurrency(amount / 3);
        breakdown['yearly'] = formatIndianCurrency(amount * 4);
        break;
      case 'halfyearly':
        breakdown['weekly'] = formatIndianCurrency(amount / 26);
        breakdown['monthly'] = formatIndianCurrency(amount / 6);
        breakdown['yearly'] = formatIndianCurrency(amount * 2);
        break;
      case 'yearly':
        breakdown['weekly'] = formatIndianCurrency(amount / 52);
        breakdown['monthly'] = formatIndianCurrency(amount / 12);
        breakdown['yearly'] = formatIndianCurrency(amount);
        break;
    }
    
    return breakdown;
  }

  static String formatIndianNumber(int number) {
    final formatter = NumberFormat('#,##,##0', 'hi_IN');
    return formatter.format(number);
  }

  static String formatIndianCurrencyWords(double amount) {
    if (amount < 0) return 'minus ${formatIndianCurrencyWords(-amount)}';
    
    if (amount == 0) return 'zero rupees';
    
    List<String> units = [
      '', 'thousand', 'lakh', 'crore', 'arab', 'kharab'
    ];
    
    List<String> numbers = [
      '', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine',
      'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen',
      'seventeen', 'eighteen', 'nineteen'
    ];
    
    List<String> tens = [
      '', '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety'
    ];
    
    String convertHundreds(int n) {
      String result = '';
      
      if (n >= 100) {
        result += '${numbers[n ~/ 100]} hundred ';
        n %= 100;
      }
      
      if (n >= 20) {
        result += '${tens[n ~/ 10]} ';
        n %= 10;
      }
      
      if (n > 0) {
        result += '${numbers[n]} ';
      }
      
      return result.trim();
    }
    
    int rupees = amount.floor();
    int paise = ((amount - rupees) * 100).round();
    
    String result = '';
    
    if (rupees > 0) {
      List<int> groups = [];
      groups.add(rupees % 1000);
      rupees ~/= 1000;
      
      while (rupees > 0) {
        groups.add(rupees % 100);
        rupees ~/= 100;
      }
      
      for (int i = groups.length - 1; i >= 0; i--) {
        if (groups[i] > 0) {
          if (i == 0) {
            result += convertHundreds(groups[i]);
          } else {
            result += '${convertHundreds(groups[i])} ${units[i]} ';
          }
        }
      }
      
      result += result.split(' ').length > 1 ? 'rupees' : 'rupee';
    }
    
    if (paise > 0) {
      if (result.isNotEmpty) result += ' and ';
      result += '${convertHundreds(paise)} ${paise == 1 ? 'paisa' : 'paise'}';
    }
    
    return result.trim();
  }

  static double parseIndianCurrency(String currencyString) {
    String cleanString = currencyString.replaceAll(RegExp(r'[₹,\s]'), '');
    
    if (cleanString.isEmpty) return 0.0;
    
    return double.tryParse(cleanString) ?? 0.0;
  }

  static bool isValidIndianCurrencyFormat(String input) {
    RegExp regex = RegExp(r'^₹?[\d,]+(\.\d{2})?$');
    return regex.hasMatch(input.trim());
  }

  static String formatDuration(Duration duration) {
    if (duration.inDays > 365) {
      int years = duration.inDays ~/ 365;
      return '$years year${years > 1 ? 's' : ''}';
    } else if (duration.inDays > 30) {
      int months = duration.inDays ~/ 30;
      return '$months month${months > 1 ? 's' : ''}';
    } else if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    } else {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    }
  }

  static String formatCurrencyWithSuffix(double amount) {
    if (amount < 1000) {
      return formatIndianCurrency(amount);
    } else if (amount < 100000) {
      return '${formatIndianCurrency(amount / 1000)} thousand';
    } else if (amount < 10000000) {
      return '${formatIndianCurrency(amount / 100000)} lakh';
    } else {
      return '${formatIndianCurrency(amount / 10000000)} crore';
    }
  }
}