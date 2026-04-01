import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_box.dart';

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
      appBar: AppBar(
        title: const Text('Zakat Calculator', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.secondaryGold),
      ),
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
                    'Total Zakat Payable',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'PKR ${_totalZakat.toStringAsFixed(2)}',
                    style: TextStyle(color: AppColors.secondaryGold, fontSize: 32.sp, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            _buildInputField('Cash in Hand/Bank', _cashController),
            _buildInputField('Value of Gold', _goldController),
            _buildInputField('Value of Silver', _silverController),
            _buildInputField('Investments/Shares', _investmentsController),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculateZakat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryGold,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: const Text('Calculate Zakat', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 24.h),
            GlassBox(
              padding: EdgeInsets.all(16.w),
              child: const Text(
                'Note: Zakat is 2.5% of your total wealth that exceeds the Nisab threshold for a full lunar year.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
        Text(label, style: TextStyle(color: AppColors.textMain, fontSize: 14.sp)),
        SizedBox(height: 8.h),
        GlassBox(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.textMain),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter amount...',
              hintStyle: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}
