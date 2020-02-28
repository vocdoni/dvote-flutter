import "./metadata.dart";
import "./wallets.dart";
import "./signatures.dart";
import "./hashing.dart";
import "./vote.dart";

void main() async {
  await metadata();
  wallets();
  await signatures();
  // await hashing();
  await vote();
}
