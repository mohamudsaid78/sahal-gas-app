class MobileMoneyPayment {
  const MobileMoneyPayment({
    required this.phoneNumber,
    required this.provider, // 'EVC Plus', 'Hormuud', 'Telesom', etc.
    this.transactionPin,
  });

  final String phoneNumber;
  final String provider;
  final String? transactionPin;

  bool get isValid => phoneNumber.isNotEmpty && provider.isNotEmpty;

  MobileMoneyPayment copyWith({
    String? phoneNumber,
    String? provider,
    String? transactionPin,
  }) {
    return MobileMoneyPayment(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      provider: provider ?? this.provider,
      transactionPin: transactionPin ?? this.transactionPin,
    );
  }

  Map<String, dynamic> toMap() => {
        'phone': phoneNumber,
        'provider': provider,
        'pin': transactionPin,
      };
}

class CardPayment {
  const CardPayment({
    required this.cardholderName,
    required this.cardNumber,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
  });

  final String cardholderName;
  final String cardNumber;
  final String expiryMonth;
  final String expiryYear;
  final String cvv;

    String get normalizedCardNumber => cardNumber.replaceAll(RegExp(r'\D'), '');
    String get normalizedMonth => expiryMonth.replaceAll(RegExp(r'\D'), '');
    String get normalizedYear => expiryYear.replaceAll(RegExp(r'\D'), '');
    String get normalizedCvv => cvv.replaceAll(RegExp(r'\D'), '');

    bool get isValid {
    final month = int.tryParse(normalizedMonth);
    return cardholderName.trim().isNotEmpty &&
      normalizedCardNumber.length == 16 &&
      month != null &&
      month >= 1 &&
      month <= 12 &&
      (normalizedYear.length == 2 || normalizedYear.length == 4) &&
      (normalizedCvv.length == 3 || normalizedCvv.length == 4);
    }

  String get maskedCardNumber =>
      '**** **** **** ${normalizedCardNumber.length >= 4 ? normalizedCardNumber.substring(normalizedCardNumber.length - 4) : '****'}';

  CardPayment copyWith({
    String? cardholderName,
    String? cardNumber,
    String? expiryMonth,
    String? expiryYear,
    String? cvv,
  }) {
    return CardPayment(
      cardholderName: cardholderName ?? this.cardholderName,
      cardNumber: cardNumber ?? this.cardNumber,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      cvv: cvv ?? this.cvv,
    );
  }

  Map<String, dynamic> toMap() => {
        'cardholder': cardholderName,
        'card_number': cardNumber,
        'expiry_month': expiryMonth,
        'expiry_year': expiryYear,
        'cvv': cvv,
      };
}

class CashOnDeliveryPayment {
  const CashOnDeliveryPayment({this.notes = ''});

  final String notes;

  CashOnDeliveryPayment copyWith({String? notes}) =>
      CashOnDeliveryPayment(notes: notes ?? this.notes);

  Map<String, dynamic> toMap() => {'notes': notes};
}
