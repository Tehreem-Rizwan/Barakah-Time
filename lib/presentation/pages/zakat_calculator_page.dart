import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_box.dart';
import '../../core/localization/app_localizations.dart';

class ZakatCalculatorPage extends StatefulWidget {
  const ZakatCalculatorPage({super.key});

  @override
  State<ZakatCalculatorPage> createState() => _ZakatCalculatorPageState();
}

class _ZakatCalculatorPageState extends State<ZakatCalculatorPage> {
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _goldController = TextEditingController();
  final TextEditingController _silverController = TextEditingController();
  final TextEditingController _investmentsController = TextEditingController();

  double _totalZakat = 0;

  void _calculateZakat() {
    final cash = double.tryParse(_cashController.text) ?? 0;
    final gold = double.tryParse(_goldController.text) ?? 0;
    final silver = double.tryParse(_silverController.text) ?? 0;
    final investments = double.tryParse(_investmentsController.text) ?? 0;

    // Simple 2.5% calculation
    setState(() {
      _totalZakat = (cash + gold + silver + investments) * 0.025;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: AppBar(title: Text(context.l10n.zakat_calculator)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassBox(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  Text(
                    context.l10n.total_zakat_payable,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'PKR ${_totalZakat.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: AppColors.secondaryGold,
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            _buildInputField(context.l10n.cash_in_hand, _cashController),
            _buildInputField(context.l10n.gold_value, _goldController),
            _buildInputField(context.l10n.silver_value, _silverController),
            _buildInputField(
              context.l10n.investments_shares,
              _investmentsController,
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculateZakat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryGold,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  context.l10n.calculate_zakat,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            GlassBox(
              padding: EdgeInsets.all(16.w),
              child: Text(
                context.l10n.zakat_note,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.textMain, fontSize: 14.sp),
        ),
        SizedBox(height: 8.h),
        GlassBox(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.textMain),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: context.l10n.enter_amount,
              hintStyle: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}
