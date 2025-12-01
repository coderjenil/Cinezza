import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../models/premium_plan_model.dart';

class PaymentService {
  PaymentService._internal();
  static final PaymentService instance = PaymentService._internal();

  late Razorpay _razorpay;
  BuildContext? _context;
  PlanModel? _currentPlan;

  /// Public callback hooks
  VoidCallback? onSuccess;
  Function(String)? onError;

  /// MUST call once before using service
  void init() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _razorpaySuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _razorpayError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _razorpayWallet);
  }

  /// Entry point called from PremiumPlansPage
  Future<void> pay({
    required BuildContext context,
    required PlanModel plan,
    required String razorpayKey,
    required VoidCallback onPaymentSuccess,
    Function(String)? onPaymentFailed,
    String? userPhone,
    String? userEmail,
  }) async {
    _context = context;
    _currentPlan = plan;
    onSuccess = onPaymentSuccess;
    onError = onPaymentFailed;

    try {
      HapticFeedback.mediumImpact();

      final options = {
        "key": razorpayKey,
        "amount": (plan.price * 100),
        "currency": "INR",
        "name": "Cinezza Premium",
        'payment_capture': 1,
        "description": "${plan.title} Subscription",
        "retry": {"enabled": true, "max_count": 1},
        "prefill": {"contact": userPhone, "email": userEmail},
        'external': {
          'wallets': ['paytm'],
        },
      };

      _razorpay.open(options);
    } catch (e) {
      _handleError("Payment initialization failed");
    }
  }

  /// Success Callback
  void _razorpaySuccess(PaymentSuccessResponse response) {
    debugPrint("Payment Successful: ${response.paymentId}");

    onSuccess?.call();
  }

  /// Error Callback
  void _razorpayError(PaymentFailureResponse response) {
    debugPrint("Payment Failed: ${response.message}");

    final msg = response.message ?? "Payment failed, please try again.";
    _handleError(msg);
  }

  /// Wallet fallback (rarely used)
  void _razorpayWallet(ExternalWalletResponse response) {
    _showSnack("External Wallet Selected: ${response.walletName}");
  }

  /// Shared error handler
  void _handleError(String message) {
    onError?.call(message);

    _showDialog(
      title: "Payment Failed",
      message: message,
      color: Colors.redAccent,
    );
  }

  /// UI Helpers

  void _showSnack(String msg) {
    if (_context == null) return;
    ScaffoldMessenger.of(_context!).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showDialog({
    required String title,
    required String message,
    required Color color,
  }) {
    if (_context == null) return;

    showDialog(
      context: _context!,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black87,
        title: Text(
          title,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            child: const Text("OK", style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(_context!),
          ),
        ],
      ),
    );
  }

  void dispose() {
    _razorpay.clear();
  }
}
