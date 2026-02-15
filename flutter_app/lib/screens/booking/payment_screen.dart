import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/trip_provider.dart';
import '../../providers/auth_provider.dart';

import 'package:go_router/go_router.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> args;
  const PaymentScreen({super.key, required this.args});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardholderNameController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isProcessing = false;
  String _cardType = 'Unknown'; // 'Visa', 'MasterCard', 'Unknown'

  @override
  void initState() {
    super.initState();
    _cardNumberController.text = "4242 4242 4242 4242";
    _cardholderNameController.text = "Sama Bay";
    _expiryDateController.text = "12/28";
    _cvvController.text = "123";
    _cardType = 'Visa'; // Set initial state directly
  }

  void _detectCardType(String number) {
    String cleanNumber = number.replaceAll(' ', '');
    if (cleanNumber.startsWith('4')) {
      if (_cardType != 'Visa') setState(() => _cardType = 'Visa');
    } else if (cleanNumber.startsWith('5') || cleanNumber.startsWith('2')) {
      // Master card range: 2221-2720 or 51-55. Simple check for 5 or 2.
      if (_cardType != 'MasterCard') setState(() => _cardType = 'MasterCard');
    } else {
      if (_cardType != 'Unknown') setState(() => _cardType = 'Unknown');
    }
  }

  Color _getCardColor() {
    if (_cardType == 'Visa') return Colors.blue;
    if (_cardType == 'MasterCard') return Colors.orange;
    return Colors.grey;
  }

  Widget _buildCardIcon() {
    if (_cardType == 'Visa') {
      return Container(
        key: const ValueKey('visa'),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text('VISA',
            style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic)),
      );
    } else if (_cardType == 'MasterCard') {
      return Container(
        key: const ValueKey('master'),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Colors.orange, Colors.red]),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text('MASTER',
            style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold)),
      );
    }
    return const Icon(Icons.credit_card,
        key: ValueKey('unknown'), color: Colors.grey);
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardholderNameController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  String _formatCardNumber(String value) {
    value = value.replaceAll(' ', '');
    String formatted = '';
    for (int i = 0; i < value.length; i++) {
      if (i > 0 && i % 4 == 0) formatted += ' ';
      formatted += value[i];
    }
    return formatted;
  }

  String _formatExpiryDate(String value) {
    value = value.replaceAll('/', '');
    if (value.length >= 2) {
      return '${value.substring(0, 2)}/${value.substring(2)}';
    }
    return value;
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    // 🔒 MOCK PAYMENT VALIDATION - Only accept test cards
    final cardDigits = _cardNumberController.text.replaceAll(' ', '');
    const allowedCards = [
      '4242424242424242', // Visa Test Card
      '5555555555554444', // Mastercard Test Card
    ];

    if (!allowedCards.contains(cardDigits)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Card Declined! Please use a valid test card:\n'
              '• Visa: 4242 4242 4242 4242\n'
              '• Mastercard: 5555 5555 5555 4444'),
          backgroundColor: AppTheme.dangerColor,
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // Use booking data from widget arguments
    final args = widget.args;

    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userEmail = authProvider.user?.email ?? '';
    final totalAmount = (args['totalPrice'] ??
        args['totalAmount'] ??
        args['price'] ??
        0.0) as double;

    try {
      // 1) Create booking (pending)
      final createRes = await tripProvider.createBooking(
        tripId: widget.args['tripId'],
        passengerEmail: userEmail,
        numberOfSeats: args['numberOfSeats'],
        amount: totalAmount,
        seatClass: (args['seatClass'] ?? '').toString(),
      );

      if (createRes['success'] != true) {
        throw Exception(createRes['message'] ?? 'Failed to create booking');
      }

      final dynamic bookingData = createRes['data'];
      final bookingId = bookingData is Map<String, dynamic>
          ? (bookingData['Booking_ID'] ?? bookingData['id'])
          : null;

      print('✅ Booking Created! ID: $bookingId');

      if (bookingId == null) {
        print('❌ Booking data dump: $bookingData');
        throw Exception('Booking created but missing Booking_ID');
      }

      // 2) Process payment (confirms booking)
      final cardDigits = _cardNumberController.text.replaceAll(' ', '');
      final paymentRes = await tripProvider.processPayment(
        bookingId: bookingId,
        paymentMethod: 'credit_card',
        cardNumber: cardDigits,
        cardHolder: _cardholderNameController.text.trim(),
        expiryDate: _expiryDateController.text.trim(),
        cvv: _cvvController.text.trim(),
      );

      if (paymentRes['success'] != true) {
        throw Exception(paymentRes['message'] ?? 'Payment failed');
      }

      final booking = (paymentRes['data']?['booking'] ??
          paymentRes['data']?['reservation'] ??
          bookingData) as dynamic;

      if (!mounted) return;
      setState(() => _isProcessing = false);

      // Navigate to ticket screen with confirmed booking data using GoRouter
      context.pushReplacement(
        '/ticket',
        extra: {
          ...args,
          'paymentMethod': 'Credit/Debit Card',
          'cardLastFour': cardDigits.length >= 4
              ? cardDigits.substring(cardDigits.length - 4)
              : cardDigits,
          'booking': booking,
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppTheme.dangerColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    final totalPrice = (args['totalPrice'] ?? 0.0) as double;
    final trip = args['trip'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Summary
              Card(
                color: AppTheme.primaryColor.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Summary',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      if (trip != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Route:'),
                            Text(
                              '${trip['origin']} → ${trip['destination']}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Train:'),
                            Text(trip['trainName'] ?? 'N/A'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Class:'),
                            Text(args['seatClass'] ?? 'N/A'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Seats:'),
                            Text('${args['numberOfSeats']} seat(s)'),
                          ],
                        ),
                        const Divider(height: 24),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            '\$${totalPrice.toStringAsFixed(2)}',
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(
                                  color: AppTheme.primaryColor,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Payment Method Header
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.credit_card,
                          color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Credit / Debit Card',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Preset 1: Sama (Visa)
                      InkWell(
                        onTap: () {
                          setState(() {
                            _cardNumberController.text = "4242 4242 4242 4242";
                            _cardholderNameController.text = "Sama Bay";
                            _expiryDateController.text = "12/28";
                            _cvvController.text = "123";
                            _detectCardType(_cardNumberController.text);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: const Text('Sama (Visa)',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Preset 2: Mohamed (Master)
                      InkWell(
                        onTap: () {
                          setState(() {
                            _cardNumberController.text = "5555 5555 5555 4444";
                            _cardholderNameController.text = "Mohamed Reda";
                            _expiryDateController.text = "11/27";
                            _cvvController.text = "456";
                            _detectCardType(_cardNumberController.text);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: const Text('Mohamed (Master)',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Helper info (Modified to dynamic)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _getCardColor().withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _getCardColor().withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: _getCardColor()),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _cardType == 'Visa'
                            ? 'Visa Card Detected • Sama Bay'
                            : (_cardType == 'MasterCard'
                                ? 'MasterCard Detected • Mohamed Reda'
                                : 'Enter card details'),
                        style: TextStyle(
                            fontSize: 13,
                            color: _getCardColor(),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Card Number
              TextFormField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  hintText: '0000 0000 0000 0000',
                  prefixIcon: const Icon(Icons.credit_card),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: _buildCardIcon(),
                    ),
                  ),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                  LengthLimitingTextInputFormatter(19),
                ],
                onChanged: (value) {
                  _detectCardType(value);
                  final formatted = _formatCardNumber(value);
                  if (formatted != value) {
                    _cardNumberController.value = TextEditingValue(
                      text: formatted,
                      selection:
                          TextSelection.collapsed(offset: formatted.length),
                    );
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter card number';
                  }
                  final digits = value.replaceAll(' ', '');
                  if (digits.length < 13 || digits.length > 19) {
                    return 'Invalid card number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Cardholder Name
              TextFormField(
                controller: _cardholderNameController,
                decoration: const InputDecoration(
                  labelText: 'Cardholder Name',
                  hintText: 'JOHN DOE',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cardholder name';
                  }
                  if (value.length < 3) {
                    return 'Name is too short';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Expiry Date and CVV
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryDateController,
                      decoration: const InputDecoration(
                        labelText: 'Expiry Date',
                        hintText: 'MM/YY',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      onChanged: (value) {
                        final formatted = _formatExpiryDate(value);
                        _expiryDateController.value = TextEditingValue(
                          text: formatted,
                          selection:
                              TextSelection.collapsed(offset: formatted.length),
                        );
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (!value.contains('/') || value.length != 5) {
                          return 'Invalid';
                        }
                        final parts = value.split('/');
                        final month = int.tryParse(parts[0]);
                        if (month == null || month < 1 || month > 12) {
                          return 'Invalid month';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (value.length != 3) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Security Notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppTheme.successColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.security, color: AppTheme.successColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your payment information is encrypted and secure',
                        style: const TextStyle(
                          color: AppTheme.successColor,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Pay \$${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }
}
