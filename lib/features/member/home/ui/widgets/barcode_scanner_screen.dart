import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../data/repositories/member_repository.dart';

/// Full-screen barcode scanner. Returns the matched food item Map or null.
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _ctrl = MobileScannerController();
  bool _processing = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing) return;
    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode == null || barcode.isEmpty) return;

    setState(() { _processing = true; _error = null; });
    await _ctrl.stop();

    try {
      final food = await MemberRepository.getFoodItemByBarcode(barcode);
      if (mounted) Navigator.pop(context, food);
    } catch (e) {
      setState(() {
        _error = 'Product not found for barcode: $barcode';
        _processing = false;
      });
      await _ctrl.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Scan Food Barcode', style: AppTextStyles.font16WhiteBold),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
            onPressed: () => _ctrl.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _ctrl,
            onDetect: _onDetect,
          ),
          // Scan window overlay
          Center(
            child: Container(
              width: 260.w,
              height: 260.w,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.teal, width: 2.5),
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
          // Corner accents
          Center(
            child: SizedBox(
              width: 260.w,
              height: 260.w,
              child: Stack(
                children: [
                  _Corner(top: 0, left: 0, topLeft: true),
                  _Corner(top: 0, right: 0, topRight: true),
                  _Corner(bottom: 0, left: 0, bottomLeft: true),
                  _Corner(bottom: 0, right: 0, bottomRight: true),
                ],
              ),
            ),
          ),
          // Scanning line animation
          Center(
            child: SizedBox(
              width: 250.w,
              child: const _ScanLine(),
            ),
          ),
          // Status
          Positioned(
            bottom: 60.h,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (_processing)
                  Column(
                    children: [
                      const CircularProgressIndicator(color: AppColors.teal),
                      vGap(12),
                      Text('Looking up product...',
                          style: AppTextStyles.font14GreyRegular
                              .copyWith(color: Colors.white)),
                    ],
                  )
                else if (_error != null)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 24.w),
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(_error!,
                        style: AppTextStyles.font14GreyRegular
                            .copyWith(color: Colors.white),
                        textAlign: TextAlign.center),
                  )
                else
                  Text('Point camera at a food barcode',
                      style: AppTextStyles.font14GreyRegular
                          .copyWith(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final bool topLeft;
  final bool topRight;
  final bool bottomLeft;
  final bool bottomRight;

  const _Corner({
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 28.r,
        height: 28.r,
        decoration: BoxDecoration(
          border: Border(
            top: topLeft || topRight
                ? const BorderSide(color: AppColors.emerald, width: 3)
                : BorderSide.none,
            bottom: bottomLeft || bottomRight
                ? const BorderSide(color: AppColors.emerald, width: 3)
                : BorderSide.none,
            left: topLeft || bottomLeft
                ? const BorderSide(color: AppColors.emerald, width: 3)
                : BorderSide.none,
            right: topRight || bottomRight
                ? const BorderSide(color: AppColors.emerald, width: 3)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _ScanLine extends StatefulWidget {
  const _ScanLine();

  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _position;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _position = Tween<double>(begin: -120, end: 120).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _position,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _position.value),
        child: Container(
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.teal,
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
