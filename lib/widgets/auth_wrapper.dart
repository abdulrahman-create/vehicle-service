import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/vehicle_provider.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isSigningUp = ref.watch(isSigningUpProvider);

    // Listen for auth changes to trigger initial sync
    ref.listen(authStateProvider, (previous, next) {
      if (previous?.value == null && next.value != null && !isSigningUp) {
        // Just logged in (not during signup), sync from cloud to local
        ref.read(vehicleProvider.notifier).syncCloudToLocal();
      }
    });

    return authState.when(
      data: (user) {
        // If we are currently signing up, ignore the 'user' state
        // because we will immediately sign out anyway.
        if (user != null && !isSigningUp) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (error, stack) =>
              Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }
}
