import 'dart:convert';
import 'dart:typed_data';

import 'package:dvote/models/build/dart/client-store/backup.pb.dart';
import 'package:dvote/models/build/dart/client-store/wallet.pb.dart';
import 'package:dvote/util/normalize.dart';
import 'package:dvote_crypto/main/encryption.dart';
import 'package:fixnum/fixnum.dart';

/// A wrapper for AccountBackup uses
class AccountBackups {
  /// Encrypts the seed with [pin] + [answers] and returns an [AccountBackup] model
  static Future<WalletBackup> createBackup(
      String alias,
      List<int> selectedQuestions,
      Wallet wallet,
      String passphrase,
      List<String> answers) async {
    // Encrypt seed with pin + questions
    final encryptedPassphrase = await Symmetric.encryptStringAsync(
        passphrase, normalizeAnswers(answers.join("")));
    if (selectedQuestions
        .any((element) => !isValidBackupQuestionIndex(element)))
      throw Exception("Invalid question indexes");
    final recovery = WalletBackup_Recovery(
        questionIds: selectedQuestions
            .map((e) => WalletBackup_Recovery_QuestionEnum.valueOf(e)),
        encryptedPassphrase: base64.decode(encryptedPassphrase));
    return WalletBackup(
      name: alias,
      timestamp: Int64(DateTime.now().millisecondsSinceEpoch ~/ 1000),
      passphraseRecovery: recovery,
      wallet: wallet,
    );
  }

  /// Decrypts first the passphrase, then the mnemonic, using [answers]
  static Future<String> decryptBackupPin(
      WalletBackup backup, List<String> answers) async {
    final normalizedAnswers = AccountBackups.normalizeAnswers(answers.join());
    return await Symmetric.decryptStringAsync(
        base64.encode(backup.passphraseRecovery.encryptedPassphrase),
        normalizedAnswers);
  }

  /// Decrypts first the passphrase, then the mnemonic, using [answers]
  static Future<String> decryptBackupMnemonic(
      WalletBackup backup, String pin) async {
    return await Symmetric.decryptStringAsync(
        base64.encode(backup.wallet.encryptedMnemonic), pin);
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
    final name = WalletBackup_Recovery_QuestionEnum.valueOf(idx).name;
    if (name == null || name.length == 0)
      throw Exception("Invalid question index");
    return name;
  }

  /// Determines if the given index is present in the enum of backup questions
  static bool isValidBackupQuestionIndex(int idx) {
    return WalletBackup_Recovery_QuestionEnum.values
        .any((element) => element.value == idx);
  }
}
