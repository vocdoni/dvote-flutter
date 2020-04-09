import 'package:flutter_test/flutter_test.dart';
import 'package:dvote/dvote.dart';

void hdWallet() {
  _hdWalletSync();
  _hdWalletAsync();
}

void _hdWalletSync() {
  test('Generate random mnemonics', () {
    final mnemonicRegExp = new RegExp(r"^[a-z]+( [a-z]+)+$");

    final wallet1 = EthereumWallet.random();
    expect(mnemonicRegExp.hasMatch(wallet1.mnemonic), true);
    expect(wallet1.mnemonic.split(" ").length, 18);

    final wallet2 = EthereumWallet.random();
    expect(mnemonicRegExp.hasMatch(wallet2.mnemonic), true);
    expect(wallet1.mnemonic != wallet2.mnemonic, true);
    expect(wallet2.mnemonic.split(" ").length, 18);

    final wallet3 = EthereumWallet.random(size: 160);
    expect(mnemonicRegExp.hasMatch(wallet3.mnemonic), true);
    expect(wallet1.mnemonic != wallet3.mnemonic, true);
    expect(wallet2.mnemonic != wallet3.mnemonic, true);
    expect(wallet3.mnemonic.split(" ").length, 15);

    final wallet4 = EthereumWallet.random(size: 128);
    expect(mnemonicRegExp.hasMatch(wallet4.mnemonic), true);
    expect(wallet1.mnemonic != wallet4.mnemonic, true);
    expect(wallet2.mnemonic != wallet4.mnemonic, true);
    expect(wallet3.mnemonic != wallet4.mnemonic, true);
    expect(wallet4.mnemonic.split(" ").length, 12);
  });

  test("Create a wallet for a given mnemonic", () {
    EthereumWallet wallet = EthereumWallet.fromMnemonic(
        'coral imitate swim axis note super success public poem frown verify then');
    expect(wallet.privateKey,
        '0x975a999c921f77c1812833d903799cdb7780b07809eb67070ac2598f45e9fb3f');
    expect(wallet.publicKey,
        '0x046fbd249af1bf365abd8d0cfc390c87ff32a997746c53dceab3794e2913d4cb26e055c8177faab65b404ea24754d8f56ef5df909a39d99ee0e7ca291a11556b37');
    expect(wallet.address, '0x6AAa00b7c22021F96B09BB52cb9135F0cB865c5D');

    wallet = EthereumWallet.fromMnemonic(
        'almost slush girl resource piece meadow cable fancy jar barely mother exhibit');
    expect(wallet.privateKey,
        '0x32fa4a65b9cb770235a8f0af497536035a459a98179c2c667972be279fbd1a1a');
    expect(wallet.publicKey,
        '0x0425eb0aac23fe343e7ac5c8a792898a4f1d55b3150f3609cde6b7ada2dff029a89430669dd7f39ffe72eb9b8335fef52fd70863d123ba0015e90cbf68b58385eb');
    expect(wallet.address, '0xf0492A8Dc9c84E6c5b66e10D0eC1A46A96FF74D3');

    wallet = EthereumWallet.fromMnemonic(
        'civil very heart sock decade library moment permit retreat unhappy clown infant');
    expect(wallet.privateKey,
        '0x1b3711c03353ecbbf7b686127e30d6a37a296ed797793498ef24c04504ca5048');
    expect(wallet.publicKey,
        '0x04ae5f2ecb63c4b9c71e1b396c8206720c02bddceb01da7c9f590aa028f110c035fa54045f6361fa0c6b5914a33e0d6f2f435818f0268ec8196062d1521ea8451a');
    expect(wallet.address, '0x9612bD0deB9129536267d154D672a7f1281eb468');

    wallet = EthereumWallet.fromMnemonic(
        'life noble news naive know verb leaf parade brisk chuckle midnight play');
    expect(wallet.privateKey,
        '0x3c21df88530a25979494c4c7789334ba5dd1c8c73d23c4077a7f223c2274830f');
    expect(wallet.publicKey,
        '0x041d792012043464ac528d15e3309d4e55b41205380dfe14a01e2be95a30d0ac80a313dbc6881d5f034c38d091cb27a0301b42faca820274e6a84d2268f8c4f556');
    expect(wallet.address, '0x34E3b8a0299dc7Dc53de09ce8361b41A7D888EC4');
  });

  test("Compute the private key for a given mnemonic and derivation path", () {
    // index 0
    EthereumWallet wallet = EthereumWallet.fromMnemonic(
        'civil very heart sock decade library moment permit retreat unhappy clown infant',
        hdPath: "m/44'/60'/0'/0/0");
    expect(wallet.privateKey,
        '0x1b3711c03353ecbbf7b686127e30d6a37a296ed797793498ef24c04504ca5048');
    expect(wallet.publicKey,
        '0x04ae5f2ecb63c4b9c71e1b396c8206720c02bddceb01da7c9f590aa028f110c035fa54045f6361fa0c6b5914a33e0d6f2f435818f0268ec8196062d1521ea8451a');
    expect(wallet.address, '0x9612bD0deB9129536267d154D672a7f1281eb468');

    // index 1
    wallet = EthereumWallet.fromMnemonic(
        'civil very heart sock decade library moment permit retreat unhappy clown infant',
        hdPath: "m/44'/60'/0'/0/1");
    expect(wallet.privateKey,
        '0x2b8642b869998d77243669463b68058299260349eba6c893d892d4b74eae95d4');
    expect(wallet.publicKey,
        '0x04d8b869ceb2d90c2ab0b0eecd2f4215f42cb40a82e7de854ca14e85a1a84e00a45e1c37334666acb08b62b19f42c18524d9d5952fb43054363350820f5190f17d');
    expect(wallet.address, '0x67b5615fDC5c65Afce9B97bD217804f1dB04bC1b');

    // index 2
    wallet = EthereumWallet.fromMnemonic(
        'civil very heart sock decade library moment permit retreat unhappy clown infant',
        hdPath: "m/44'/60'/0'/0/2");
    expect(wallet.privateKey,
        '0x562870cd36727fdca458ada4c2a34e0170b7b4cc4d3dc3b60cba3582bf8c3167');
    expect(wallet.publicKey,
        '0x04887f399e99ce751f82f73a9a88ab015db74b40f707534f54a807fa6e10982cbfaffe93414466b347b83cd43bc0d1a147443576446b49d0e3d6db24f37fe02567');
    expect(wallet.address, '0x0887fb27273A36b2A641841Bf9b47470d5C0E420');
  });
}

void _hdWalletAsync() {
  test('Generate random mnemonics [async]', () async {
    final mnemonicRegExp = RegExp(r"^[a-z]+( [a-z]+)+$");

    final wallet1 = await EthereumWallet.randomAsync();
    expect(mnemonicRegExp.hasMatch(wallet1.mnemonic), true);
    expect(wallet1.mnemonic.split(" ").length, 18);

    final wallet2 = await EthereumWallet.randomAsync();
    expect(mnemonicRegExp.hasMatch(wallet2.mnemonic), true);
    expect(wallet1.mnemonic != wallet2.mnemonic, true);
    expect(wallet2.mnemonic.split(" ").length, 18);

    final wallet3 = await EthereumWallet.randomAsync(size: 160);
    expect(mnemonicRegExp.hasMatch(wallet3.mnemonic), true);
    expect(wallet1.mnemonic != wallet3.mnemonic, true);
    expect(wallet2.mnemonic != wallet3.mnemonic, true);
    expect(wallet3.mnemonic.split(" ").length, 15);

    final wallet4 = await EthereumWallet.randomAsync(size: 128);
    expect(mnemonicRegExp.hasMatch(wallet4.mnemonic), true);
    expect(wallet1.mnemonic != wallet4.mnemonic, true);
    expect(wallet2.mnemonic != wallet4.mnemonic, true);
    expect(wallet3.mnemonic != wallet4.mnemonic, true);
    expect(wallet4.mnemonic.split(" ").length, 12);
  });

  test("Create a wallet for a given mnemonic [async]", () async {
    EthereumWallet wallet = EthereumWallet.fromMnemonic(
        'coral imitate swim axis note super success public poem frown verify then');
    expect(await wallet.privateKeyAsync,
        '0x975a999c921f77c1812833d903799cdb7780b07809eb67070ac2598f45e9fb3f');
    expect(await wallet.publicKeyAsync,
        '0x046fbd249af1bf365abd8d0cfc390c87ff32a997746c53dceab3794e2913d4cb26e055c8177faab65b404ea24754d8f56ef5df909a39d99ee0e7ca291a11556b37');
    expect(await wallet.addressAsync,
        '0x6AAa00b7c22021F96B09BB52cb9135F0cB865c5D');

    wallet = EthereumWallet.fromMnemonic(
        'almost slush girl resource piece meadow cable fancy jar barely mother exhibit');
    expect(await wallet.privateKeyAsync,
        '0x32fa4a65b9cb770235a8f0af497536035a459a98179c2c667972be279fbd1a1a');
    expect(await wallet.publicKeyAsync,
        '0x0425eb0aac23fe343e7ac5c8a792898a4f1d55b3150f3609cde6b7ada2dff029a89430669dd7f39ffe72eb9b8335fef52fd70863d123ba0015e90cbf68b58385eb');
    expect(await wallet.addressAsync,
        '0xf0492A8Dc9c84E6c5b66e10D0eC1A46A96FF74D3');

    wallet = EthereumWallet.fromMnemonic(
        'civil very heart sock decade library moment permit retreat unhappy clown infant');
    expect(await wallet.privateKeyAsync,
        '0x1b3711c03353ecbbf7b686127e30d6a37a296ed797793498ef24c04504ca5048');
    expect(await wallet.publicKeyAsync,
        '0x04ae5f2ecb63c4b9c71e1b396c8206720c02bddceb01da7c9f590aa028f110c035fa54045f6361fa0c6b5914a33e0d6f2f435818f0268ec8196062d1521ea8451a');
    expect(await wallet.addressAsync,
        '0x9612bD0deB9129536267d154D672a7f1281eb468');

    wallet = EthereumWallet.fromMnemonic(
        'life noble news naive know verb leaf parade brisk chuckle midnight play');
    expect(await wallet.privateKeyAsync,
        '0x3c21df88530a25979494c4c7789334ba5dd1c8c73d23c4077a7f223c2274830f');
    expect(await wallet.publicKeyAsync,
        '0x041d792012043464ac528d15e3309d4e55b41205380dfe14a01e2be95a30d0ac80a313dbc6881d5f034c38d091cb27a0301b42faca820274e6a84d2268f8c4f556');
    expect(await wallet.addressAsync,
        '0x34E3b8a0299dc7Dc53de09ce8361b41A7D888EC4');
  });

  test("Compute the private key for a given mnemonic and derivation path [async]",
      () async {
    // index 0
    EthereumWallet wallet = EthereumWallet.fromMnemonic(
        'civil very heart sock decade library moment permit retreat unhappy clown infant',
        hdPath: "m/44'/60'/0'/0/0");
    expect(await wallet.privateKeyAsync,
        '0x1b3711c03353ecbbf7b686127e30d6a37a296ed797793498ef24c04504ca5048');
    expect(await wallet.publicKeyAsync,
        '0x04ae5f2ecb63c4b9c71e1b396c8206720c02bddceb01da7c9f590aa028f110c035fa54045f6361fa0c6b5914a33e0d6f2f435818f0268ec8196062d1521ea8451a');
    expect(await wallet.addressAsync,
        '0x9612bD0deB9129536267d154D672a7f1281eb468');

    // index 1
    wallet = EthereumWallet.fromMnemonic(
        'civil very heart sock decade library moment permit retreat unhappy clown infant',
        hdPath: "m/44'/60'/0'/0/1");
    expect(await wallet.privateKeyAsync,
        '0x2b8642b869998d77243669463b68058299260349eba6c893d892d4b74eae95d4');
    expect(await wallet.publicKeyAsync,
        '0x04d8b869ceb2d90c2ab0b0eecd2f4215f42cb40a82e7de854ca14e85a1a84e00a45e1c37334666acb08b62b19f42c18524d9d5952fb43054363350820f5190f17d');
    expect(await wallet.addressAsync,
        '0x67b5615fDC5c65Afce9B97bD217804f1dB04bC1b');

    // index 2
    wallet = EthereumWallet.fromMnemonic(
        'civil very heart sock decade library moment permit retreat unhappy clown infant',
        hdPath: "m/44'/60'/0'/0/2");
    expect(await wallet.privateKeyAsync,
        '0x562870cd36727fdca458ada4c2a34e0170b7b4cc4d3dc3b60cba3582bf8c3167');
    expect(await wallet.publicKeyAsync,
        '0x04887f399e99ce751f82f73a9a88ab015db74b40f707534f54a807fa6e10982cbfaffe93414466b347b83cd43bc0d1a147443576446b49d0e3d6db24f37fe02567');
    expect(await wallet.addressAsync,
        '0x0887fb27273A36b2A641841Bf9b47470d5C0E420');
  });
}
