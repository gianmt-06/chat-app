import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:local_auth/local_auth.dart';

class FingerprintValidation extends StatefulWidget {
  const FingerprintValidation({super.key});

  @override
  State<FingerprintValidation> createState() => _FingerprintValidationState();
}

class _FingerprintValidationState extends State<FingerprintValidation> {
  final LocalAuthentication auth = LocalAuthentication();

  Future<void> _biometricAuth() async {
    try {
      bool canCheck = await auth.canCheckBiometrics;
      bool isAuthenticated = false;

      if (canCheck) {
        isAuthenticated = await auth.authenticate(
          localizedReason: "Usa tu huella o rostro para ingresar",
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
      }

      if (isAuthenticated) {
        if (!mounted) return;
        context.go('/home');
      }
    } catch (e) {
      debugPrint("Error al autenticar: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _biometricAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Icon(LucideIcons.lock, size: 35),
                  SizedBox(height: 20),
                  Text(
                    "ChatApp bloqueado",
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  _biometricAuth();
                },
                icon: Icon(LucideIcons.fingerprint, size: 40),
                padding: EdgeInsets.all(20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
