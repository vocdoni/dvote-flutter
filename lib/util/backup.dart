import 'dart:convert';
import 'dart:typed_data';

import 'package:dvote/models/build/dart/client-store/backup.pb.dart';
import 'package:dvote/util/normalize.dart';
import 'package:dvote_crypto/main/encryption.dart';

/// A wrapper for AccountBackup uses
class AccountBackups {
  /// Encrypts the seed with [pin] + [answers] and returns an [AccountBackup] model
  static Future<AccountBackup> createBackup(
      String alias,
      List<int> selectedQuestions,
      AccountBackup_Auth auth,
      String seed,
      String pin,
      List<String> answers) async {
    // Encrypt seed with pin + questions
    final encryptedSeed = await Symmetric.encryptStringAsync(
        seed, pin + normalizeAnswers(answers.join("")));
    if (selectedQuestions
        .any((element) => !isValidBackupQuestionIndex(element)))
      throw Exception("Invalid question indexes");
    return AccountBackup(
        questions:
            selectedQuestions.map((e) => AccountBackup_Questions.valueOf(e)),
        auth: auth,
        key: base64.decode(encryptedSeed),
        alias: alias);
  }

  /// Decrypts the key using [pin]+[answers]
  static Future<String> decryptKey(
      Uint8List encryptedKey, String pin, List<String> answers) async {
    final normalizedAnswers = AccountBackups.normalizeAnswers(answers.join());
    final decryptedKey = await Symmetric.decryptStringAsync(
        base64.encode(encryptedKey), pin + normalizedAnswers);
    return decryptedKey;
  }

  /// Normalizes a set of concatenated answers to be used for backup generation
  static String normalizeAnswers(String concatenatedAnswers) {
    String normalized = concatenatedAnswers.replaceAll(RegExp(r"\s+"), "");
    normalized = normalized.toLowerCase();
    normalized = Normalize.removeDiacritics(normalized);
    return normalized;
  }

  /// Retrieves the language key from the given question index
  static String getBackupQuestionLanguageKey(int idx) {
    final name = AccountBackup_Questions.valueOf(idx).name;
    if (name == null || name.length == 0)
      throw Exception("Invalid question index");
    return name;
  }

  /// Determines if the given index is present in the enum of backup questions
  static bool isValidBackupQuestionIndex(int idx) {
    return AccountBackup_Questions.values
        .any((element) => element.value == idx);
  }
}
