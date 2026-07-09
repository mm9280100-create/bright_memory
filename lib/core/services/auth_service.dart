import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_realtime_auth.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const _remotePath = 'auth_accounts';
  static const _timeout = Duration(seconds: 6);
  static const _kUser = 'user_data';
  static const _kAccounts = 'auth_accounts_v2';
  static const _passwordPepper = 'br_memory_2026_family_auth';

  final _http = http.Client();

  Map<String, String> get _headers =>
      {'Content-Type': 'application/json', 'Accept': 'application/json'};

  Future<AppUser?> get currentUser async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUser);
    if (raw == null) return null;
    try {
      return AppUser.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  Future<bool> get isLoggedIn async => (await currentUser) != null;

  Future<AuthResult> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      final emailError = validateEmail(normalizedEmail);
      if (emailError != null) return AuthResult.failure(emailError);

      final passwordError = validateStrongPassword(password);
      if (passwordError != null) return AuthResult.failure(passwordError);

      final exists = await _emailExists(normalizedEmail);
      if (exists) return AuthResult.failure('Email already registered.');

      final user = AppUser(
        id: _authDeviceId(normalizedEmail),
        fullName: fullName.trim(),
        email: normalizedEmail,
        phone: phone.trim(),
        authProvider: 'email',
      );
      final account = _accountEntry(
        user: user,
        passwordHash: _hashPassword(normalizedEmail, password),
      );

      await _saveLocalAccount(account);
      final synced = await _saveRemoteAccount(account);
      if (!synced) {
        return AuthResult.failure(
          'Server is unavailable. Try again so the account works on all devices.',
        );
      }
      await _saveUser(user);
      return AuthResult.success(user);
    } catch (error) {
      return AuthResult.failure(_netError(error));
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      final emailError = validateEmail(normalizedEmail);
      if (emailError != null) return AuthResult.failure(emailError);
      if (password.isEmpty) return AuthResult.failure('Password is required.');

      final all = [
        ...await _localAuthEntries(),
        ...await _fetchRemoteAuthEntries(),
      ];
      final matches = all.where((entry) {
        final readings = entry['readings'];
        if (entry['device_type'] != 'auth' ||
            readings?['action'] != 'register' ||
            readings?['email']?.toString().toLowerCase() != normalizedEmail) {
          return false;
        }

        final storedHash = readings?['passwordHash']?.toString();
        if (storedHash != null && storedHash.isNotEmpty) {
          return storedHash == _hashPassword(normalizedEmail, password);
        }

        return readings?['password']?.toString() == password;
      }).toList();
      final match = matches.isEmpty ? null : matches.last;

      if (match == null) {
        return AuthResult.failure('Invalid email or password.');
      }

      final readings = match['readings'];
      final user = AppUser(
        id: match['device_id']?.toString() ?? 'uid',
        fullName: readings['fullName']?.toString() ?? '',
        email: readings['email']?.toString() ?? '',
        phone: readings['phone']?.toString(),
        authProvider: readings['authProvider']?.toString() ?? 'email',
      );
      await _saveUser(user);
      return AuthResult.success(user);
    } catch (error) {
      return AuthResult.failure(_netError(error));
    }
  }

  Future<AuthResult> continueWithProvider({
    required String provider,
    required String email,
  }) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      final emailError = validateEmail(normalizedEmail, provider: provider);
      if (emailError != null) return AuthResult.failure(emailError);

      final existing = await _findAccountEntryByEmail(normalizedEmail);
      if (existing != null) {
        final readings = existing['readings'];
        final user = AppUser(
          id: existing['device_id']?.toString() ??
              _authDeviceId(normalizedEmail),
          fullName: readings?['fullName']?.toString() ??
              _displayNameFromEmail(normalizedEmail),
          email: normalizedEmail,
          phone: readings?['phone']?.toString(),
          authProvider: readings?['authProvider']?.toString() ?? provider,
        );
        await _saveUser(user);
        return AuthResult.success(user);
      }

      final displayName = _displayNameFromEmail(normalizedEmail);
      final user = AppUser(
        id: _authDeviceId(normalizedEmail),
        fullName: displayName,
        email: normalizedEmail,
        authProvider: provider,
      );
      final account = _accountEntry(user: user, passwordHash: '');
      await _saveLocalAccount(account);
      final synced = await _saveRemoteAccount(account);
      if (!synced) {
        return AuthResult.failure(
          'Server is unavailable. Try again so the account works on all devices.',
        );
      }
      await _saveUser(user);
      return AuthResult.success(user);
    } catch (error) {
      return AuthResult.failure(_netError(error));
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUser);
  }

  Future<AuthResult> sendPasswordResetEmail(String email) async {
    final normalizedEmail = _normalizeEmail(email);
    final emailError = validateEmail(normalizedEmail);
    if (emailError != null) return AuthResult.failure(emailError);
    final exists = await _emailExists(normalizedEmail);
    if (!exists) return AuthResult.failure('Email is not registered.');
    return AuthResult.success(
      AppUser(
        id: 'reset_$normalizedEmail',
        fullName: '',
        email: normalizedEmail,
      ),
    );
  }

  Future<AuthResult> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async =>
      AuthResult.failure('Not available yet.');

  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required void Function(String) onCodeSent,
    required void Function(String) onError,
  }) async =>
      onError('Not available yet.');

  Future<AuthResult> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      final emailError = validateEmail(normalizedEmail);
      if (emailError != null) return AuthResult.failure(emailError);
      if (newPassword != confirmPassword) {
        return AuthResult.failure('Passwords do not match.');
      }
      final passwordError = validateStrongPassword(newPassword);
      if (passwordError != null) return AuthResult.failure(passwordError);

      final existing = await _findUserByEmail(normalizedEmail);
      if (existing == null) {
        return AuthResult.failure('Email is not registered.');
      }

      final user = AppUser(
        id: existing.id,
        fullName: existing.fullName,
        email: normalizedEmail,
        phone: existing.phone,
        authProvider: 'email',
      );
      final account = _accountEntry(
        user: user,
        passwordHash: _hashPassword(normalizedEmail, newPassword),
        extraReadings: {'resetAt': DateTime.now().toIso8601String()},
      );
      await _saveLocalAccount(account);
      final synced = await _saveRemoteAccount(account);
      if (!synced) {
        return AuthResult.failure('Server is unavailable. Try again.');
      }
      await _saveUser(user);
      return AuthResult.success(user);
    } catch (error) {
      return AuthResult.failure(_netError(error));
    }
  }

  Future<bool> _emailExists(String email) async {
    try {
      final all = [
        ...await _localAuthEntries(),
        ...await _fetchRemoteAuthEntries(),
      ];
      return all.any(
        (entry) =>
            entry['device_type'] == 'auth' &&
            entry['readings']?['email']?.toString().toLowerCase() ==
                email.toLowerCase(),
      );
    } catch (_) {
      return false;
    }
  }

  Future<AppUser?> _findUserByEmail(String email) async {
    try {
      final all = [
        ...await _localAuthEntries(),
        ...await _fetchRemoteAuthEntries(),
      ];
      final matches = all
          .where(
            (entry) =>
                entry['device_type'] == 'auth' &&
                entry['readings']?['email']?.toString().toLowerCase() ==
                    email.toLowerCase(),
          )
          .toList();
      if (matches.isEmpty) return null;
      final latest = matches.last;
      final readings = latest['readings'];
      return AppUser(
        id: latest['device_id']?.toString() ?? 'uid',
        fullName:
            readings?['fullName']?.toString() ?? _displayNameFromEmail(email),
        email: email,
        phone: readings?['phone']?.toString(),
        authProvider: readings?['authProvider']?.toString() ?? 'email',
      );
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _findAccountEntryByEmail(String email) async {
    final all = [
      ...await _localAuthEntries(),
      ...await _fetchRemoteAuthEntries(),
    ];
    final matches = all
        .where(
          (entry) =>
              entry['device_type'] == 'auth' &&
              entry['readings']?['email']?.toString().toLowerCase() ==
                  email.toLowerCase(),
        )
        .toList();
    if (matches.isEmpty) return null;
    return matches.last;
  }

  Future<List<Map<String, dynamic>>> _fetchRemoteAuthEntries() async {
    try {
      final response = await _http
          .get(await FirebaseRealtimeAuth.uri(_remotePath), headers: _headers)
          .timeout(_timeout);
      if (response.statusCode != 200) return [];
      final decoded = jsonDecode(response.body);
      if (decoded == null) return [];
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((entry) => Map<String, dynamic>.from(entry))
            .where((entry) => entry['device_type'] == 'auth')
            .toList();
      }
      if (decoded is Map) {
        return decoded.values
            .whereType<Map>()
            .map((entry) => Map<String, dynamic>.from(entry))
            .where((entry) => entry['device_type'] == 'auth')
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _localAuthEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kAccounts);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((entry) => Map<String, dynamic>.from(entry))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveLocalAccount(Map<String, dynamic> account) async {
    final prefs = await SharedPreferences.getInstance();
    final accounts = await _localAuthEntries();
    final email = account['readings']?['email']?.toString().toLowerCase();
    accounts.removeWhere(
      (entry) => entry['readings']?['email']?.toString().toLowerCase() == email,
    );
    accounts.add(account);
    await prefs.setString(_kAccounts, jsonEncode(accounts));
  }

  Future<bool> _saveRemoteAccount(Map<String, dynamic> account) async {
    try {
      final response = await _http
          .put(
            await FirebaseRealtimeAuth.uri(
              '$_remotePath/${account['device_id']}',
            ),
            headers: _headers,
            body: jsonEncode(account),
          )
          .timeout(_timeout);
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> _accountEntry({
    required AppUser user,
    required String passwordHash,
    Map<String, dynamic>? extraReadings,
  }) =>
      {
        'device_id': _authDeviceId(user.email),
        'device_type': 'auth',
        'readings': {
          'action': 'register',
          'fullName': user.fullName,
          'email': _normalizeEmail(user.email),
          'phone': user.phone ?? '',
          'passwordHash': passwordHash,
          'passwordVersion': 2,
          'authProvider': user.authProvider,
          ...?extraReadings,
        },
        'timestamp': DateTime.now().toIso8601String(),
      };

  Future<void> _saveUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUser, jsonEncode(user.toJson()));
  }

  String _netError(dynamic error) {
    final message = error.toString();
    if (message.contains('timeout')) return 'Connection timeout.';
    if (message.contains('SocketException')) return 'No internet connection.';
    return 'Network error. Try again.';
  }

  static String? validateEmail(String email, {String? provider}) {
    if (email.trim().isEmpty) return 'Email is required.';
    final isValid = RegExp(
      r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$',
      caseSensitive: false,
    ).hasMatch(email);
    if (!isValid) return 'Enter a valid email address.';

    final domain = email.split('@').last.toLowerCase();
    if (provider == 'google' && domain != 'gmail.com') {
      return 'Use a Gmail address.';
    }
    if (provider == 'icloud' &&
        !{'icloud.com', 'me.com', 'mac.com'}.contains(domain)) {
      return 'Use an iCloud address.';
    }
    return null;
  }

  static String? validateStrongPassword(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password needs an uppercase letter.';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password needs a lowercase letter.';
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      return 'Password needs a number.';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=/\\]').hasMatch(password)) {
      return 'Password needs a special character.';
    }
    return null;
  }

  static String _normalizeEmail(String email) => email.trim().toLowerCase();

  static String _authDeviceId(String email) =>
      'auth_${_normalizeEmail(email).replaceAll(RegExp(r'[@.]'), '_')}';

  static String _hashPassword(String email, String password) {
    final bytes = utf8.encode(
      '${_normalizeEmail(email)}|$password|$_passwordPepper',
    );
    return sha256.convert(bytes).toString();
  }

  static String _displayNameFromEmail(String email) {
    final name = email.split('@').first.replaceAll(RegExp(r'[._-]+'), ' ');
    if (name.trim().isEmpty) return 'Family Member';
    return name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}

class AppUser {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String authProvider;

  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.authProvider = 'email',
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id']?.toString() ?? '',
        fullName: json['fullName']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString(),
        authProvider: json['authProvider']?.toString() ?? 'email',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'authProvider': authProvider,
      };
}

class AuthResult {
  final AppUser? user;
  final String? error;

  bool get isSuccess => error == null;

  AuthResult._({this.user, this.error});

  factory AuthResult.success(AppUser? user) => AuthResult._(user: user);

  factory AuthResult.failure(String error) => AuthResult._(error: error);
}
