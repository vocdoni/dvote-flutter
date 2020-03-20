import "./metadata.dart";
import "./wallets.dart";
import "./signatures.dart";
import "./vote.dart";

void main() async {
  await metadata();
  wallets();
  signatures();
  await vote();
}
