import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:coinslib/coinslib.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:peercoin/tools/app_localizations.dart';
import 'package:coinslib/src/utils/script.dart';
import 'package:coinslib/src/utils/constants/op.dart';
import 'package:hex/hex.dart';

import '../models/availablecoins.dart';
import '../models/coinwallet.dart';
import '../tools/notification.dart';
import '../models/walletaddress.dart';
import '../models/wallettransaction.dart';
import '../models/walletutxo.dart';
import '../providers/encryptedbox.dart';

class ActiveWallets with ChangeNotifier {
  final EncryptedBox _encryptedBox;
  ActiveWallets(this._encryptedBox);
  late String _seedPhrase;
  String _unusedAddress = '';
  late Box _walletBox;
  Box? _vaultBox;
  // ignore: prefer_final_fields
  Map<String?, CoinWallet?> _specificWallet = {};
  WalletAddress? _transferedAddress;

  Future<void> init() async {
    _vaultBox = await _encryptedBox.getGenericBox('vaultBox');
    _walletBox = await _encryptedBox.getWalletBox();
  }

  Future<String> get seedPhrase async {
    _seedPhrase = _vaultBox!.get('mnemonicSeed') ?? '';
    return _seedPhrase;
  }

  String get getUnusedAddress {
    return _unusedAddress;
  }

  set unusedAddress(String newAddr) {
    _unusedAddress = newAddr;
    notifyListeners();
  }

  Uint8List seedPhraseUint8List(String words) {
    return bip39.mnemonicToSeed(words);
  }

  Future<void> createPhrase(
      [String? providedPhrase, int strength = 128]) async {
    if (providedPhrase == null) {
      var mnemonicSeed = bip39.generateMnemonic(strength: strength);
      await _vaultBox!.put('mnemonicSeed', mnemonicSeed);
      _seedPhrase = mnemonicSeed;
    } else {
      await _vaultBox!.put('mnemonicSeed', providedPhrase);
      _seedPhrase = providedPhrase;
    }
  }

  Future<List<CoinWallet>> get activeWalletsValues async {
    return _walletBox.values.toList() as FutureOr<List<CoinWallet>>;
  }

  Future<List> get activeWalletsKeys async {
    return _walletBox.keys.toList();
  }

  CoinWallet getSpecificCoinWallet(String identifier) {
    if (_specificWallet[identifier] == null) {
      //cache wallet
      _specificWallet[identifier] = _walletBox.get(identifier);
    }
    return _specificWallet[identifier]!;
  }

  Future<void> addWallet(String name, String title, String letterCode) async {
    var box = await Hive.openBox<CoinWallet>('wallets',
        encryptionCipher: HiveAesCipher(await _encryptedBox.key as List<int>));
    await box.put(name, CoinWallet(name, title, letterCode));
    notifyListeners();
  }

  Future<String?> getAddressFromDerivationPath(
      String identifier, int account, int chain, int address,
      [master = false]) async {
    final network = AvailableCoins().getSpecificCoin(identifier).networkType;
    var hdWallet = HDWallet.fromSeed(
      seedPhraseUint8List(await seedPhrase),
      network: network,
    );

    if (master == true) {
      return hdWallet.address;
    } else {
      var derivePath = "m/$account'/$chain/$address";
      log(derivePath);

      return hdWallet.derivePath(derivePath).address;
    }
  }

  Future<void> addAddressFromWif(
      String identifier, String wif, String publicAddress) async {
    var openWallet = getSpecificCoinWallet(identifier);

    openWallet.addNewAddress = WalletAddress(
      address: publicAddress,
      addressBookName: '',
      used: true,
      status: null,
      isOurs: true,
      wif: wif,
    );

    await openWallet.save();
  }

  Future<void> generateUnusedAddress(String identifier) async {
    var openWallet = getSpecificCoinWallet(identifier);
    final network = AvailableCoins().getSpecificCoin(identifier).networkType;
    var hdWallet = HDWallet.fromSeed(
      seedPhraseUint8List(await seedPhrase),
      network: network,
    );
    if (openWallet.addresses.isEmpty) {
      //generate new address
      openWallet.addNewAddress = WalletAddress(
        address: hdWallet.address!,
        addressBookName: '',
        used: false,
        status: null,
        isOurs: true,
        wif: hdWallet.wif,
      );
      unusedAddress = hdWallet.address!;
    } else {
      //wallet is not brand new, lets find an unused address
      var unusedAddr;
      openWallet.addresses.forEach((walletAddr) {
        if (walletAddr.used == false && walletAddr.status == null) {
          unusedAddr = walletAddr.address;
        }
      });
      if (unusedAddr != null) {
        //unused address available
        unusedAddress = unusedAddr;
      } else {
        //not empty, but all used -> create new one
        var numberOfOurAddr = openWallet.addresses
            .where((element) => element.isOurs == true)
            .length;
        var derivePath = "m/0'/$numberOfOurAddr/0";
        var newHdWallet = hdWallet.derivePath(derivePath);

        final res = openWallet.addresses.firstWhereOrNull(
            (element) => element.address == newHdWallet.address);

        if (res != null) {
          //next addr in derivePath is already used for some reason
          numberOfOurAddr++;
          derivePath = "m/0'/$numberOfOurAddr/0";
          newHdWallet = hdWallet.derivePath(derivePath);
        }

        openWallet.addNewAddress = WalletAddress(
          address: newHdWallet.address!,
          addressBookName: '',
          used: false,
          status: null,
          isOurs: true,
          wif: newHdWallet.wif,
        );

        unusedAddress = newHdWallet.address!;
      }
    }
    await openWallet.save();
  }

  Future<List<WalletAddress>> getWalletAddresses(String identifier) async {
    var openWallet = getSpecificCoinWallet(identifier);
    return openWallet.addresses;
  }

  Future<List<WalletTransaction>> getWalletTransactions(
      String identifier) async {
    var openWallet = getSpecificCoinWallet(identifier);
    return openWallet.transactions;
  }

  Future<String?> getWalletAddressStatus(
      String identifier, String address) async {
    var addresses = await getWalletAddresses(identifier);
    var targetWallet =
        addresses.firstWhereOrNull((element) => element.address == address);
    return targetWallet?.status;
  }

  Future<List> getUnkownTxFromList(String identifier, List newTxList) async {
    var storedTransactions = await getWalletTransactions(identifier);
    var unkownTx = [];
    newTxList.forEach((newTx) {
      var found = false;
      storedTransactions.forEach((storedTx) {
        if (storedTx.txid == newTx['tx_hash']) {
          found = true;
        }
      });
      if (found == false) {
        unkownTx.add(newTx['tx_hash']);
      }
    });
    return unkownTx;
  }

  Future<void> updateWalletBalance(String identifier) async {
    var openWallet = getSpecificCoinWallet(identifier);

    var balanceConfirmed = 0;
    var unconfirmedBalance = 0;

    openWallet.utxos.forEach((walletUtxo) {
      if (walletUtxo.height > 0 ||
          openWallet.transactions.firstWhereOrNull(
                (tx) => tx.txid == walletUtxo.hash && tx.direction == 'out',
              ) !=
              null) {
        balanceConfirmed += walletUtxo.value;
      } else {
        unconfirmedBalance += walletUtxo.value;
      }
    });

    openWallet.balance = balanceConfirmed;
    openWallet.unconfirmedBalance = unconfirmedBalance;

    await openWallet.save();
    notifyListeners();
  }

  Future<void> putUtxos(String identifier, String address, List utxos) async {
    var openWallet = getSpecificCoinWallet(identifier);

    //clear utxos for address
    openWallet.clearUtxo(address);

    //put them in again
    utxos.forEach((tx) {
      openWallet.putUtxo(
        WalletUtxo(
          hash: tx['tx_hash'],
          txPos: tx['tx_pos'],
          height: tx['height'],
          value: tx['value'],
          address: address,
        ),
      );
    });

    await updateWalletBalance(identifier);
    await openWallet.save();
    notifyListeners();
  }

  Future<void> putTx(String identifier, String address, Map tx,
      [bool scanMode = false]) async {
    var openWallet = getSpecificCoinWallet(identifier);
    log('$address puttx: $tx');

    if (scanMode == true) {
      //write phantom tx that are not displayed in tx list but known to the wallet
      //so they won't be parsed again and cause weird display behaviour
      openWallet.putTransaction(
        WalletTransaction(
          txid: tx['txid'],
          timestamp: -1, //flags phantom tx
          value: 0,
          fee: 0,
          address: address,
          direction: 'in',
          broadCasted: true,
          confirmations: 0,
          broadcastHex: '',
          opReturn: '',
        ),
      );
    } else {
      //check if that tx is already in the db
      var txInWallet = openWallet.transactions;
      var isInWallet = false;
      txInWallet.forEach((walletTx) {
        if (walletTx.txid == tx['txid']) {
          isInWallet = true;
          if (isInWallet == true) {
            if (walletTx.timestamp == 0 || walletTx.timestamp == null) {
              //did the tx confirm?
              walletTx.newTimestamp = tx['blocktime'] ?? 0;
            }
            if (tx['confirmations'] != null &&
                walletTx.confirmations < tx['confirmations']) {
              //more confirmations?
              walletTx.newConfirmations = tx['confirmations'];
            }
          }
        }
      });
      //it's not in wallet yet
      if (!isInWallet) {
        //check if that tx addresses more than one of our addresses
        var utxoInWallet = openWallet.utxos
            .firstWhereOrNull((elem) => elem.hash == tx['txid']);
        var direction = utxoInWallet == null ? 'out' : 'in';

        if (direction == 'in') {
          List voutList = tx['vout'].toList();
          voutList.forEach((vOut) {
            final asMap = vOut as Map;
            if (asMap['scriptPubKey']['type'] != 'nulldata') {
              asMap['scriptPubKey']['addresses'].forEach((addr) {
                if (openWallet.addresses.firstWhereOrNull(
                        (element) => element.address == addr) !=
                    null) {
                  //address is ours, add new tx
                  final txValue = (vOut['value'] * 1000000).toInt();

                  //increase notification value for addr
                  final addrInWallet = openWallet.addresses
                      .firstWhere((element) => element.address == addr);
                  addrInWallet.newNotificationBackendCount =
                      addrInWallet.notificationBackendCount + 1;
                  openWallet.save();

                  //write tx
                  openWallet.putTransaction(
                    WalletTransaction(
                        txid: tx['txid'],
                        timestamp: tx['blocktime'] ?? 0,
                        value: txValue,
                        fee: 0,
                        address: addr,
                        direction: direction,
                        broadCasted: true,
                        confirmations: tx['confirmations'] ?? 0,
                        broadcastHex: '',
                        opReturn: ''),
                  );
                }
              });
            }
          });

          //scan for OP_RETURN messages
          //obtain transaction object
          final txData = Uint8List.fromList(HEX.decode(tx['hex']));
          final txFromBuffer = Transaction.fromBuffer(txData);

          //loop through outputs to find OP_RETURN outputs
          for (final out in txFromBuffer.outs) {
            final script = decompile(out.script)!;
            // Find OP_RETURN + push data
            if (script.length == 2 &&
                script[0] == OPS['OP_RETURN'] &&
                script[1] is Uint8List) {
              String? parsedMessage;

              try {
                parsedMessage = utf8.decode(script[1]);
              } catch (e) {
                print(e);
              } finally {
                openWallet.putTransaction(
                  WalletTransaction(
                    txid: tx['txid'],
                    timestamp: tx['blocktime'] ?? 0,
                    value: 0,
                    fee: 0,
                    address: 'Metadata',
                    direction: direction,
                    broadCasted: true,
                    confirmations: tx['confirmations'] ?? 0,
                    broadcastHex: '',
                    opReturn: parsedMessage ??
                        'There was an error decoding this message',
                  ),
                );
              }
            }
          }
        }
        // trigger notification
        var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

        if (direction == 'in') {
          await flutterLocalNotificationsPlugin.show(
            DateTime.now().millisecondsSinceEpoch ~/ 10000,
            AppLocalizations.instance.translate(
                'notification_title', {'walletTitle': openWallet.title}),
            tx['txid'],
            LocalNotificationSettings.platformChannelSpecifics,
            payload: identifier,
          );
        }
      }
    }

    notifyListeners();
    await openWallet.save();
  }

  Future<void> putOutgoingTx(String identifier, String address, Map tx) async {
    var openWallet = getSpecificCoinWallet(identifier);

    openWallet.putTransaction(
      WalletTransaction(
        txid: tx['txid'],
        timestamp: tx['blocktime'] ?? 0,
        value: tx['outValue'],
        fee: tx['outFees'],
        address: address,
        direction: 'out',
        broadCasted: false,
        confirmations: 0,
        broadcastHex: tx['hex'],
        opReturn: tx['opReturn'],
      ),
    );

    notifyListeners();
    await openWallet.save();
  }

  Future<void> prepareForRescan(String identifier) async {
    var openWallet = getSpecificCoinWallet(identifier);
    openWallet.utxos.removeRange(0, openWallet.utxos.length);

    openWallet.transactions
        .removeWhere((element) => element.txid == 'notification_dummy');
    openWallet.transactions
        .removeWhere((element) => element.broadCasted == false);

    await updateWalletBalance(identifier);
    await openWallet.save();
  }

  Future<void> updateAddressStatus(
      String identifier, String address, String? status) async {
    log('updating $address to $status');
    //set address to used
    //update status for address
    var openWallet = getSpecificCoinWallet(identifier);
    var addrInWallet = openWallet.addresses
        .firstWhereOrNull((element) => element.address == address);
    if (addrInWallet != null) {
      addrInWallet.newUsed = status == null ? false : true;
      addrInWallet.newStatus = status;

      if (addrInWallet.wif!.isEmpty || addrInWallet.wif == null) {
        await getWif(identifier, address);
      }
    }
    await openWallet.save();
    await generateUnusedAddress(identifier);
  }

  Future<String> getAddressForTx(String identifier, String txid) async {
    var openWallet = getSpecificCoinWallet(identifier);
    var tx =
        openWallet.utxos.firstWhereOrNull((element) => element.hash == txid);
    if (tx != null) {
      return tx.address;
    }
    return '';
  }

  Future<String> getWif(
    String identifier,
    String address,
  ) async {
    var network = AvailableCoins().getSpecificCoin(identifier).networkType;
    var openWallet = getSpecificCoinWallet(identifier);
    var walletAddress = openWallet.addresses
        .firstWhereOrNull((element) => element.address == address);

    if (walletAddress != null) {
      if (walletAddress.wif == null || walletAddress.wif == '') {
        var _wifs = {};
        var hdWallet = HDWallet.fromSeed(
          seedPhraseUint8List(await seedPhrase),
          network: network,
        );

        for (var i = 0; i <= openWallet.addresses.length + 5; i++) {
          //parse 5 extra WIFs, just to be sure
          final child = hdWallet.derivePath("m/0'/$i/0");
          _wifs[child.address] = child.wif;
        }
        _wifs[hdWallet.address] = hdWallet.wif;
        walletAddress.newWif = _wifs[address]; //save
        await openWallet.save();
        return _wifs[walletAddress.address];
      }
    } else if (walletAddress == null) {
      return '';
    }
    return walletAddress.wif ?? '';
  }

  Future<Map> buildTransaction(
      String identifier, String address, String amount, int fee,
      [bool dryRun = false, String opReturn = '']) async {
    //convert amount
    var _txAmount = (double.parse(amount) * 1000000).toInt();
    var openWallet = getSpecificCoinWallet(identifier);
    var _hex = '';
    var _destroyedChange = 0;

    //check if tx needs change
    var _needsChange = true;
    if (_txAmount == openWallet.balance) {
      _needsChange = false;
      log('needschange $_needsChange, fee $fee');
      log('change needed $_txAmount - $fee');
    }

    if (_txAmount <= openWallet.balance) {
      if (openWallet.utxos.isNotEmpty) {
        //find eligible input utxos
        var _totalInputValue = 0;
        var inputTx = <WalletUtxo>[];
        var coin = AvailableCoins().getSpecificCoin(identifier);

        openWallet.utxos.forEach((utxo) {
          if (utxo.value > 0 && utxo.height > 0) {
            if (_totalInputValue <= (_txAmount + fee)) {
              _totalInputValue += utxo.value;
              inputTx.add(utxo);
            }
          }
        });
        var coinParams = AvailableCoins().getSpecificCoin(identifier);
        var network = coinParams.networkType;

        //start building tx
        final tx = TransactionBuilder(network: network);
        tx.setVersion(coinParams.txVersion);
        if (_needsChange == true) {
          var changeAmount = _totalInputValue - _txAmount - fee;
          log('change amount $changeAmount');

          if (changeAmount <= coin.minimumTxValue) {
            //change is too small! no change output
            _destroyedChange = changeAmount;
            if (_txAmount == 0) {
              tx.addOutput(address, _txAmount);
            } else {
              tx.addOutput(address, _txAmount - fee);
            }
          } else {
            tx.addOutput(address, _txAmount);
            tx.addOutput(_unusedAddress, changeAmount);
          }
        } else {
          tx.addOutput(address, _txAmount - fee);
        }

        //add OP_RETURN if exists
        if (opReturn.isNotEmpty) {
          tx.addNullOutput(opReturn);
        }

        //generate keyMap
        Future<Map<int, Map>> generateKeyMap() async {
          var keyMap = <int, Map>{};
          for (var inputUtxo in inputTx) {
            var inputKey = inputTx.indexOf(inputUtxo);
            //find key to that utxo
            for (var walletAddr in openWallet.addresses) {
              if (walletAddr.address == inputUtxo.address) {
                var wif = await getWif(identifier, walletAddr.address);
                keyMap[inputKey] = ({'wif': wif, 'addr': inputUtxo.address});
                tx.addInput(inputUtxo.hash, inputUtxo.txPos);
              }
            }
          }
          return keyMap;
        }

        var keyMap = await generateKeyMap();
        //sign
        keyMap.forEach((key, value) {
          log("signing - ${value["addr"]}");
          tx.sign(
            vin: key,
            keyPair: ECPair.fromWIF(value['wif'], network: network),
          );
        });

        final intermediate = tx.build();
        var number = ((intermediate.txSize) / 1000 * coin.feePerKb)
            .toStringAsFixed(coin.fractions);
        var asDouble = double.parse(number) * 1000000;
        var requiredFeeInSatoshis = asDouble.toInt();

        log('fee $requiredFeeInSatoshis, size: ${intermediate.txSize}');
        if (dryRun == false) {
          log('intermediate size: ${intermediate.txSize}');
          _hex = intermediate.toHex();

          //flag addr as change addr
          var addrInWallet = openWallet.addresses
              .firstWhereOrNull((element) => element.address == _unusedAddress);
          if (addrInWallet != null) {
            addrInWallet.isChangeAddr = true;
            //increase notification value
            addrInWallet.newNotificationBackendCount =
                addrInWallet.notificationBackendCount + 1;
          }
        }
        //generate new wallet addr
        await generateUnusedAddress(identifier);
        return {
          'fee': dryRun == false
              ? requiredFeeInSatoshis
              : requiredFeeInSatoshis +
                  10, //TODO 10 satoshis added here because tx virtualsize out of coinslib varies by 1 byte
          'hex': _hex,
          'id': intermediate.getId(),
          'destroyedChange': _destroyedChange,
          'opReturn': opReturn
        };
      } else {
        throw ('no utxos available');
      }
    } else {
      throw ('tx amount greater wallet balance');
    }
  }

  Future<Map> getWalletScriptHashes(String identifier,
      [String? address]) async {
    List<WalletAddress>? addresses;
    var answerMap = {};
    if (address == null) {
      //get all
      addresses = await getWalletAddresses(identifier);
      addresses.forEach((addr) {
        if (addr.isOurs == true || addr.isOurs == null) {
          // == null for backwards compatability
          answerMap[addr.address] = getScriptHash(identifier, addr.address);
        }
      });
    } else {
      //get just one
      answerMap[address] = getScriptHash(identifier, address);
    }
    return answerMap;
  }

  String getScriptHash(String identifier, String address) {
    var network = AvailableCoins().getSpecificCoin(identifier).networkType;
    var script = Address.addressToOutputScript(address, network);
    var hash = sha256.convert(script).toString();
    return (reverseString(hash));
  }

  Future<void> updateBroadcasted(
      String identifier, String txId, bool broadcasted) async {
    var openWallet = getSpecificCoinWallet(identifier);
    var tx =
        openWallet.transactions.firstWhere((element) => element.txid == txId);
    tx.broadCasted = broadcasted;
    tx.resetBroadcastHex();
    await openWallet.save();
  }

  Future<void> updateRejected(
      String identifier, String txId, bool rejected) async {
    var openWallet = getSpecificCoinWallet(identifier);
    var tx = openWallet.transactions.firstWhere(
        (element) => element.txid == txId && element.confirmations != -1);
    if (rejected) {
      tx.newConfirmations = -1;
    } else {
      tx.newConfirmations = 0;
    }
    tx.resetBroadcastHex();
    await openWallet.save();
    notifyListeners();
  }

  void updateLabel(String identifier, String address, String label) {
    var openWallet = getSpecificCoinWallet(identifier);
    var addr = openWallet.addresses.firstWhereOrNull(
      (element) => element.address == address,
    );
    if (addr != null) {
      addr.newAddressBookName = label;
    } else {
      openWallet.addNewAddress = WalletAddress(
        address: address,
        addressBookName: label,
        used: true,
        status: null,
        isOurs: false,
        wif: '',
      );
    }

    openWallet.save();
    notifyListeners();
  }

  void addAddressFromScan(String identifier, String address) async {
    var openWallet = getSpecificCoinWallet(identifier);
    var addr = openWallet.addresses.firstWhereOrNull(
      (element) => element.address == address,
    );
    if (addr == null) {
      openWallet.addNewAddress = WalletAddress(
          address: address,
          addressBookName: '',
          used: true,
          status: null,
          isOurs: true,
          wif: await getWif(identifier, address));
    } else {
      await updateAddressStatus(identifier, address, null);
    }

    await openWallet.save();
  }

  void removeAddress(String identifier, WalletAddress addr) {
    var openWallet = getSpecificCoinWallet(identifier);
    openWallet.removeAddress(addr);
    notifyListeners();
  }

  String getLabelForAddress(String identifier, String address) {
    var openWallet = getSpecificCoinWallet(identifier);
    var addr = openWallet.addresses.firstWhereOrNull(
      (element) => element.address == address,
    );
    if (addr == null) return '';
    return addr.addressBookName ?? '';
  }

  set transferedAddress(newAddress) {
    _transferedAddress = newAddress;
  }

  WalletAddress? get transferedAddress {
    return _transferedAddress;
  }

  String reverseString(String input) {
    var items = [];
    for (var i = 0; i < input.length; i++) {
      items.add(input[i]);
    }
    var itemsReversed = [];
    items.asMap().forEach((index, value) {
      if (index % 2 == 0) {
        itemsReversed.insert(0, items[index + 1]);
        itemsReversed.insert(0, value);
      }
    });
    return itemsReversed.join();
  }
}
