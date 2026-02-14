class ShippingAddress {
  final String firstName;
  final String lastName;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state; // US state code (CA, NY, etc.)
  final String zipCode; // 5-digit or 9-digit (XXXXX-XXXX)
  final String? phoneNumber;

  const ShippingAddress({
    required this.firstName,
    required this.lastName,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.zipCode,
    this.phoneNumber,
  });

  // Validation method - returns map of field errors
  Map<String, String?> validate() {
    final errors = <String, String?>{};

    if (firstName.trim().isEmpty) {
      errors['firstName'] = 'First name is required';
    }
    if (lastName.trim().isEmpty) {
      errors['lastName'] = 'Last name is required';
    }
    if (addressLine1.trim().isEmpty) {
      errors['addressLine1'] = 'Street address is required';
    }
    if (city.trim().isEmpty) {
      errors['city'] = 'City is required';
    }
    if (state.trim().isEmpty) {
      errors['state'] = 'State is required';
    }

    // ZIP code validation (5-digit or 9-digit with hyphen)
    final zipRegex = RegExp(r'^\d{5}(-\d{4})?$');
    if (zipCode.trim().isEmpty) {
      errors['zipCode'] = 'ZIP code is required';
    } else if (!zipRegex.hasMatch(zipCode.trim())) {
      errors['zipCode'] = 'Invalid ZIP code (use XXXXX or XXXXX-XXXX format)';
    }

    // Phone number validation (optional, but validate if provided)
    if (phoneNumber != null && phoneNumber!.trim().isNotEmpty) {
      final phoneRegex = RegExp(r'^\+?1?\s*\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$');
      if (!phoneRegex.hasMatch(phoneNumber!.trim())) {
        errors['phoneNumber'] = 'Invalid phone number format';
      }
    }

    return errors;
  }

  bool get isValid => validate().isEmpty;

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'address_line_1': addressLine1,
        'address_line_2': addressLine2,
        'city': city,
        'state': state,
        'zip_code': zipCode,
        'phone_number': phoneNumber,
      };

  factory ShippingAddress.fromJson(Map<String, dynamic> json) => ShippingAddress(
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String,
        addressLine1: json['address_line_1'] as String,
        addressLine2: json['address_line_2'] as String?,
        city: json['city'] as String,
        state: json['state'] as String,
        zipCode: json['zip_code'] as String,
        phoneNumber: json['phone_number'] as String?,
      );

  @override
  String toString() {
    final parts = [
      '$firstName $lastName',
      addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2,
      '$city, $state $zipCode',
      if (phoneNumber != null && phoneNumber!.isNotEmpty) phoneNumber,
    ];
    return parts.join('\n');
  }
}
