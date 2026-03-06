import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_button.dart';
import '../../../core/models/user_model.dart';
import '../providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _controller = TextEditingController();
  String _otp = '';
  int _countdown = 60;
  Timer? _timer;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown == 0) {
        t.cancel();
      } else {
        if (mounted) setState(() => _countdown--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_otp.length != 6) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _loading = false);
    // Mock: any 6-digit OTP works — use demo parent user
    ref.read(authProvider.notifier).loginAs(UserModel.parent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('OTP Verification'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              const Icon(
                Icons.sms_outlined,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Enter OTP',
                style: AppTypography.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'We sent a 6-digit OTP to your mobile number.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // OTP fields
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: _controller,
                onChanged: (v) => setState(() => _otp = v),
                onCompleted: (_) => _verify(),
                keyboardType: TextInputType.number,
                animationType: AnimationType.scale,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                  fieldHeight: 52,
                  fieldWidth: 44,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.divider,
                  selectedColor: AppColors.primary,
                  activeFillColor: AppColors.card,
                  inactiveFillColor: AppColors.card,
                  selectedFillColor: AppColors.primary.withValues(alpha: 0.05),
                ),
                enableActiveFill: true,
                textStyle: AppTypography.headlineMedium.copyWith(
                  color: AppColors.primary,
                ),
                cursorColor: AppColors.primary,
                autoDisposeControllers: false,
              ),

              const SizedBox(height: AppSpacing.xl),
              NcPrimaryButton(
                label: 'Verify OTP',
                fullWidth: true,
                loading: _loading,
                onPressed: _otp.length == 6 ? _verify : null,
              ),
              const SizedBox(height: AppSpacing.md),

              // Resend
              Center(
                child: _countdown > 0
                    ? Text.rich(
                        TextSpan(
                          text: 'Resend OTP in ',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: '${_countdown}s',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : TextButton(
                        onPressed: _startTimer,
                        child: Text(
                          'Resend OTP',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
              ),

              const Spacer(),
              Text(
                'Demo: Enter any 6 digits to proceed',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textDisabled,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
