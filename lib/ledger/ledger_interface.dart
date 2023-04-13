// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:js_util';

import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:peercoin/tools/global_keys.dart';

import '../tools/logger_wrapper.dart';
import 'ledger_exceptions.dart';
import 'ledger_js_binding.dart';
import 'ledger_public_key.dart';

class LedgerInterface {
  late Object transport;
  late Btc btc; //Ledger JS binding class
  static final Map<String, LedgerInterface> _cache =
      <String, LedgerInterface>{};

  factory LedgerInterface() {
    return _cache.putIfAbsent(
      'ledgerinstance',
      () => LedgerInterface._internal(),
    );
  }
  LedgerInterface._internal();

  Future<void> init() async {
    try {
      final transport = await promiseToFuture(
        transportWebUSBCreate(),
      );
      btc = Btc(transport);
    } catch (e) {
      LoggerWrapper.logError(
        'LedgerInterface',
        'init',
        e.toString(),
      );

      if (e.toString().contains('TransportOpenUserCancelled')) {
        throw LedgerTransportOpenUserCancelled();
      }
      throw LedgerUnknownException();
    }
  }

  Future<LedgerPublicKey> getWalletPublicKey({
    required String path,
    bool verify = false,
    String format = 'legacy',
  }) async {
    try {
      final walletPublicKey = await promiseToFuture(
        btc.getWalletPublicKey(
          path,
          Options(
            verify: verify,
            format: format,
          ),
        ),
      );
      return LedgerPublicKey(
        publicKey: getProperty(walletPublicKey, 'publicKey'),
        chainCode: getProperty(walletPublicKey, 'chainCode'),
        address: getProperty(walletPublicKey, 'bitcoinAddress'),
      );
    } catch (e) {
      LoggerWrapper.logError(
        'LedgerInterface',
        'getWalletPublicKey',
        e.toString(),
      );

      if (e.toString().contains('0x6511')) {
        throw LedgerApplicationNotOpen();
      } else if (e.toString().contains('lock getWalletPublicKey')) {
        throw LedgerDeviceBusy();
      }
      throw LedgerUnknownException();
    }
  }

  Future<dynamic> performTransaction({
    required Future future,
    bool retried = false,
  }) async {
    try {
      return await future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw LedgerTimeout();
        },
      );
    } catch (e) {
      LoggerWrapper.logError(
        'LedgerInterface',
        'performTransaction',
        e.toString(),
      );

      final errorType = e.runtimeType;
      if (e.runtimeType == LedgerDeviceBusy && retried == false) {
        //try again!
        await Future.delayed(const Duration(seconds: 3));
        await performTransaction(
          future: future,
          retried: true,
        );
        return;
      }

      String errorText;

      switch (errorType) {
        case LedgerApplicationNotOpen:
          errorText =
              'Please open the Peercoin application on your Ledger'; //TODO i18n
          break;
        case LedgerTransportOpenUserCancelled:
          errorText =
              'Please allow the browser to access your Ledger'; //TODO i18n
          break;
        case LedgerTimeout:
          errorText =
              'Connection to Ledger timed out. Is the device unlocked? Please try again'; //TODO i18n
          break;
        case LedgerUnknownException:
        default:
          errorText =
              'An unknown error occured while communicating with Ledger. Please try again'; //TODO i18n
          break;
      }

      rootScaffoldMessengerKey.currentContext!.loaderOverlay.hide();
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(
          content: Text(
            errorText,
            textAlign: TextAlign.center,
          ),
          duration: const Duration(seconds: 5),
        ),
      );
      rethrow;
    }
  }
}



//TODO make it sign https://gist.github.com/miguelmota/62559d02a1b99cb291635de4b224349c
/*
	            "getWalletXpub",
	            "getWalletPublicKey",
	            "signP2SHTransaction",
	            "signMessageNew",
	            "createPaymentTransactionNew",
	            "getTrustedInput",
	            "getTrustedInputBIP143",
 */

//TODO path without setup