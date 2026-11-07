import 'package:core/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/network_providers.dart';
import '../../auth/application/auth_providers.dart';
import '../../marketing/demo_wallet_state.dart';
import '../../marketing/wallet_providers.dart';
import '../data/planstar_user_api.dart';
import 'profile_providers.dart';
import 'user_api_providers.dart';

/// 签到状态。
///
/// 未登录时直接返回「未签到」占位状态，不发请求。
final signInStatusProvider = FutureProvider<SignInStatus>((ref) async {
  final auth = ref.watch(authControllerProvider);
  if (!auth.isLoggedIn) return SignInStatus.guest;

  if (ref.watch(dataSourcePolicyProvider).isDemo) {
    final DemoWalletState demo = ref.watch(demoWalletStateProvider);
    return SignInStatus(
      signed: demo.signedToday,
      todayReward: 100,
      balance: Money.fromMinorUnits(demo.balanceMinorUnits),
      signedAt: demo.signedOn,
    );
  }

  final result = await ref.watch(planstarUserApiProvider).fetchSignIn();
  return result.fold(
    onSuccess: (SignInStatus status) => status,
    onFailure: (failure) => throw failure,
  );
});

/// 签到提交结果。
final class SignInSubmitResult {
  const SignInSubmitResult._({
    required this.success,
    this.status,
    this.errorMessage,
  });

  const SignInSubmitResult.success(SignInStatus status)
    : this._(success: true, status: status);

  const SignInSubmitResult.failure(String message)
    : this._(success: false, errorMessage: message);

  final bool success;
  final SignInStatus? status;
  final String? errorMessage;
}

/// 签到提交控制器；`state` 表示是否正在提交。
class SignInController extends Notifier<bool> {
  @override
  bool build() => false;

  Future<SignInSubmitResult> submit() async {
    if (state) {
      return const SignInSubmitResult.failure('签到处理中，请稍候');
    }
    state = true;
    try {
      final SignInStatus status;
      if (ref.read(dataSourcePolicyProvider).isDemo) {
        final bool credited = ref
            .read(demoWalletStateProvider.notifier)
            .signIn();
        final DemoWalletState demo = ref.read(demoWalletStateProvider);
        status = SignInStatus(
          signed: true,
          todayReward: 100,
          balance: Money.fromMinorUnits(demo.balanceMinorUnits),
          alreadySigned: !credited,
          signedAt: demo.signedOn,
        );
      } else {
        final result = await ref.read(planstarUserApiProvider).signIn();
        if (result.isFailure) {
          return SignInSubmitResult.failure(result.failure!.message);
        }
        status = result.requireData;
      }

      ref.invalidate(signInStatusProvider);
      ref.invalidate(walletProvider);
      ref.invalidate(userProfileProvider);
      ref.invalidate(remoteProfileProvider);
      return SignInSubmitResult.success(status);
    } finally {
      state = false;
    }
  }
}

final signInControllerProvider = NotifierProvider<SignInController, bool>(
  SignInController.new,
);
