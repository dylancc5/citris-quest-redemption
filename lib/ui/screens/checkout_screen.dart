import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/typography.dart';
import '../../core/breakpoints.dart';
import '../../backend/domain/models/shipping_address.dart';
import '../../backend/data/auth_service.dart';
import '../../backend/services/cart_service.dart';
import '../../backend/services/validation_service.dart';
import '../../backend/services/order_processing_service.dart';
import '../../widgets/common/animated_starfield.dart';
import '../../widgets/common/primary_button.dart';
import '../widgets/navigation/merch_nav_bar.dart';
import 'cart_screen.dart';
import 'order_history_screen.dart';
import 'success_screen.dart';

/// Checkout screen with address form and order processing
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Address form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedState = 'CA';
  bool _isProcessing = false;

  // US states
  static const _usStates = [
    'AL',
    'AK',
    'AZ',
    'AR',
    'CA',
    'CO',
    'CT',
    'DE',
    'FL',
    'GA',
    'HI',
    'ID',
    'IL',
    'IN',
    'IA',
    'KS',
    'KY',
    'LA',
    'ME',
    'MD',
    'MA',
    'MI',
    'MN',
    'MS',
    'MO',
    'MT',
    'NE',
    'NV',
    'NH',
    'NJ',
    'NM',
    'NY',
    'NC',
    'ND',
    'OH',
    'OK',
    'OR',
    'PA',
    'RI',
    'SC',
    'SD',
    'TN',
    'TX',
    'UT',
    'VT',
    'VA',
    'WA',
    'WV',
    'WI',
    'WY',
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _processOrder() async {
    if (!_formKey.currentState!.validate()) return;

    // Create shipping address
    final address = ShippingAddress(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      addressLine1: _addressLine1Controller.text.trim(),
      addressLine2: _addressLine2Controller.text.trim().isEmpty
          ? null
          : _addressLine2Controller.text.trim(),
      city: _cityController.text.trim(),
      state: _selectedState,
      zipCode: _zipCodeController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
    );

    // Validate address
    final addressValidation = ValidationService().validateAddress(address);
    if (!addressValidation.isValid) {
      _showErrorDialog(addressValidation.errorMessage!);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Process order
      final result = await OrderProcessingService().processOrder(
        items: CartService().items,
        address: address,
      );

      if (!mounted) return;

      if (result.success) {
        // Navigate to success screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SuccessScreen(order: result.order!),
          ),
        );
      } else {
        setState(() => _isProcessing = false);
        _showErrorDialog(result.errorMessage!);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showErrorDialog('An unexpected error occurred. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundSecondary,
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            const Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MerchNavBar(
        title: 'Checkout',
        isSubPage: true,
        onCartTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CartScreen()),
        ),
        onOrdersTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
        ),
      ),
      body: AnimatedStarfield(
        child: Scrollbar(
          controller: _scrollController,
          thickness: 6,
          radius: const Radius.circular(3),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: Center(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(
                  Breakpoints.isMobile(context) ? 12 : 16,
                  Breakpoints.isMobile(context) ? 12 : 16,
                  Breakpoints.isMobile(context) ? 6 : 10,
                  Breakpoints.isMobile(context) ? 12 : 16,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Order summary card
                          _buildOrderSummary(),
                          const SizedBox(height: 24),

                          // Shipping address section
                          Text(
                            'Shipping Address',
                            style: AppTypography.title1(context),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'US addresses only',
                            style: AppTypography.caption1(
                              context,
                            ).copyWith(color: Colors.white54),
                          ),
                          const SizedBox(height: 16),

                          // Address form
                          _buildAddressForm(),
                          const SizedBox(height: 24),

                          // Non-refundable notice
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.orange),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'All redemptions are final. No refunds or cancellations.',
                                    style: TextStyle(color: Colors.orange),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Confirm order button
                          PrimaryButton(
                            text: _isProcessing
                                ? 'Processing...'
                                : 'Confirm Order',
                            onPressed: _isProcessing ? null : _processOrder,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    final items = CartService().items;
    final totalCost = CartService().totalCost;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardBackgroundGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.cyanAccent.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Summary', style: AppTypography.title2(context)),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.item.name}${item.selectedSize != null ? ' (${item.selectedSize})' : ''} × ${item.quantity}',
                      style: AppTypography.body(context),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on,
                        color: AppTheme.yellowPrimary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item.subtotal}',
                        style: AppTypography.body(
                          context,
                        ).copyWith(color: AppTheme.yellowPrimary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTypography.title2(context)),
              Row(
                children: [
                  Icon(Icons.monetization_on, color: AppTheme.yellowPrimary),
                  const SizedBox(width: 8),
                  Text(
                    '$totalCost',
                    style: AppTypography.title1(
                      context,
                    ).copyWith(color: AppTheme.yellowPrimary),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          ValueListenableBuilder(
            valueListenable: AuthService().xpNotifier,
            builder: (context, xp, _) {
              return ValueListenableBuilder(
                valueListenable: AuthService().coinsNotifier,
                builder: (context, coins, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your balance',
                        style: AppTypography.caption1(
                          context,
                        ).copyWith(color: Colors.white54),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: AppTheme.cyanAccent,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$xp XP',
                            style: AppTypography.caption1(
                              context,
                            ).copyWith(color: AppTheme.cyanAccent),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.monetization_on,
                            color: AppTheme.yellowPrimary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$coins',
                            style: AppTypography.caption1(
                              context,
                            ).copyWith(color: AppTheme.yellowPrimary),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddressForm() {
    final isMobile = Breakpoints.isMobile(context);

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardBackgroundGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.cyanAccent.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // First and Last Name - stack on mobile
          if (isMobile) ...[
            _buildTextField(
              controller: _firstNameController,
              label: 'First Name',
              icon: Icons.person,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _lastNameController,
              label: 'Last Name',
              icon: Icons.person_outline,
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _firstNameController,
                    label: 'First Name',
                    icon: Icons.person,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _lastNameController,
                    label: 'Last Name',
                    icon: Icons.person_outline,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),

          // Address Line 1
          _buildTextField(
            controller: _addressLine1Controller,
            label: 'Street Address',
            icon: Icons.home,
          ),
          const SizedBox(height: 16),

          // Address Line 2 (optional)
          _buildTextField(
            controller: _addressLine2Controller,
            label: 'Apartment, Suite, etc. (optional)',
            icon: Icons.apartment,
            required: false,
          ),
          const SizedBox(height: 16),

          // City, State, ZIP - stack on mobile
          if (isMobile) ...[
            _buildTextField(
              controller: _cityController,
              label: 'City',
              icon: Icons.location_city,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedState,
                    decoration: InputDecoration(
                      labelText: 'State',
                      prefixIcon: const Icon(Icons.map),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: _usStates.map((state) {
                      return DropdownMenuItem(value: state, child: Text(state));
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedState = value!);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _zipCodeController,
                    label: 'ZIP Code',
                    icon: Icons.mail,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ] else
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    controller: _cityController,
                    label: 'City',
                    icon: Icons.location_city,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedState,
                    decoration: InputDecoration(
                      labelText: 'State',
                      prefixIcon: const Icon(Icons.map),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: _usStates.map((state) {
                      return DropdownMenuItem(value: state, child: Text(state));
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedState = value!);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _zipCodeController,
                    label: 'ZIP Code',
                    icon: Icons.mail,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),

          // Phone (optional)
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number (optional)',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            required: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.cyanAccent.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.cyanAccent, width: 2),
        ),
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (required && (value == null || value.trim().isEmpty)) {
          return 'This field is required';
        }
        return null;
      },
    );
  }
}
