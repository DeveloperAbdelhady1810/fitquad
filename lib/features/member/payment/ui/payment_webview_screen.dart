import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebviewScreen extends StatefulWidget {
  static const routeName = '/payment-webview';

  final String paymentUrl;
  final double totalAmount;
  final String coachName;
  final bool isOrder;
  final VoidCallback? onSuccess;

  const PaymentWebviewScreen({
    super.key,
    required this.paymentUrl,
    required this.totalAmount,
    this.coachName = '',
    this.isOrder = false,
    this.onSuccess,
  });

  @override
  State<PaymentWebviewScreen> createState() => _PaymentWebviewScreenState();
}

class _PaymentWebviewScreenState extends State<PaymentWebviewScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _resultShown = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _loading = true),
        onPageFinished: (_) => setState(() => _loading = false),
        onNavigationRequest: (req) {
          if (req.url.startsWith('https://app.fitquad.local/payment-result')) {
            _handleRedirect(req.url);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _handleRedirect(String url) {
    if (_resultShown) return;
    _resultShown = true;
    try {
      final success = Uri.parse(url).queryParameters['success'];
      _showResult(success: success == 'true');
    } catch (_) {
      _showResult(success: false);
    }
  }

  void _showResult({required bool success}) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        icon: Icon(
          success ? Icons.check_circle : Icons.cancel,
          color: success ? AppColors.emerald : AppColors.red,
          size: 48.r,
        ),
        title: Text(
          success ? 'Payment Successful!' : 'Payment Failed',
          style: AppTextStyles.font16WhiteBold,
          textAlign: TextAlign.center,
        ),
        content: Text(
          success
              ? widget.isOrder
                  ? 'Your order is confirmed and payment was received. Our supplier will call you to arrange delivery. Delivery fees will be collected upon delivery.'
                  : 'Your session with ${widget.coachName} has been booked. They will contact you to confirm the time.'
              : 'The payment could not be processed. Please try again.',
          style: AppTextStyles.font14GreyRegular,
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (success) widget.onSuccess?.call();
              context.pop();
            },
            child: Text(
              success ? 'Done' : 'Close',
              style: AppTextStyles.font14GreyRegular.copyWith(
                  color: success ? AppColors.emerald : AppColors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: Text('Pay — ${widget.totalAmount.toStringAsFixed(0)} EGP',
            style: AppTextStyles.font16WhiteBold),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.grey),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(child: CircularProgressIndicator(color: AppColors.teal)),
        ],
      ),
    );
  }
}
