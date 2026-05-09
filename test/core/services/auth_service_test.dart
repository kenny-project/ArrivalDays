import 'package:flutter_test/flutter_test.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

// Test the hashing logic extracted as pure functions
String hashPin(String pin, List<int> salt) {
  final bytes = utf8.encode(pin) + salt;
  return sha256.convert(bytes).toString();
}

void main() {
  group('PIN hashing', () {
    test('same PIN and salt produces same hash', () {
      final salt = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];
      final hash1 = hashPin('123456', salt);
      final hash2 = hashPin('123456', salt);
      expect(hash1, equals(hash2));
    });

    test('different PINs produce different hashes', () {
      final salt = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];
      final hash1 = hashPin('123456', salt);
      final hash2 = hashPin('654321', salt);
      expect(hash1, isNot(equals(hash2)));
    });

    test('different salts produce different hashes', () {
      final salt1 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];
      final salt2 = [16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1];
      final hash1 = hashPin('123456', salt1);
      final hash2 = hashPin('123456', salt2);
      expect(hash1, isNot(equals(hash2)));
    });

    test('PIN must be exactly 6 digits', () {
      expect(RegExp(r'^\d{6}$').hasMatch('123456'), isTrue);
      expect(RegExp(r'^\d{6}$').hasMatch('12345'), isFalse);
      expect(RegExp(r'^\d{6}$').hasMatch('1234567'), isFalse);
      expect(RegExp(r'^\d{6}$').hasMatch('abcdef'), isFalse);
    });
  });
}
