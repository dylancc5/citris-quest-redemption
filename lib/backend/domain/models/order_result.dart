import 'merch_order.dart';

class OrderResult {
  final bool success;
  final MerchOrder? order;
  final String? errorMessage;

  const OrderResult({
    required this.success,
    this.order,
    this.errorMessage,
  });

  factory OrderResult.success(MerchOrder order) => OrderResult(
        success: true,
        order: order,
      );

  factory OrderResult.failure(String errorMessage) => OrderResult(
        success: false,
        errorMessage: errorMessage,
      );
}

class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
  });

  factory ValidationResult.success() => const ValidationResult(
        isValid: true,
      );

  factory ValidationResult.failure(String errorMessage) => ValidationResult(
        isValid: false,
        errorMessage: errorMessage,
      );
}
