import 'package:local_auth/local_auth.dart';
import 'package:pinkledger/core/security/settings_service.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
  final SettingsService _settings = SettingsService();

  Future<bool> isDeviceSupported() async {
    return await _auth.isDeviceSupported();
  }

  Future<bool> canCheckBiometrics() async {
    return await _auth.canCheckBiometrics;
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _auth.getAvailableBiometrics();
  }

  Future<bool> authenticate({String reason = 'Authenticate to access PINKLEDGER'}) async {
    final enabled = await _settings.getBiometricEnabled();
    if (!enabled) return false;
    return await _auth.authenticate(
      localizedReason: reason,
      options: const AuthenticationOptions(
        stickyAuth: true,
        biometricOnly: true,
      ),
    );
  }
}
