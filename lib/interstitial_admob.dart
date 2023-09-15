import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


/// loads an interstitial ad.
class InterstitialAdmob extends StatefulWidget {
  const InterstitialAdmob({super.key});

  @override
  InterstitialAdmobState createState() => InterstitialAdmobState();
}

class InterstitialAdmobState extends State<InterstitialAdmob> {

  InterstitialAd? _interstitialAd;
  final _gameLength = 30;
  late var _counter = _gameLength;
  bool isShowingAd = false;

  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() => _counter = _gameLength);
    _loadAd();
    _starTimer();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interstitial Example',
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Interstitial Example'),
          ),
          body: const Text('Aliyar')),
    );
  }

  /// Loads an interstitial ad.
  void _loadAd() {
    InterstitialAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (InterstitialAd ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {},
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  ad.dispose();
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  isShowingAd = false;
                  print('isShowingAd: $isShowingAd');
                  ad.dispose();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});

            // Keep a reference to the ad so you can show it later.
            _interstitialAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            // ignore: avoid_print
            print('InterstitialAd failed to load: $error');
          },
        ));
  }

  void _starTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _counter--);

      if (_counter == 0) {
        if (!isShowingAd) {
          isShowingAd = true;
        _interstitialAd?.show();
        timer.cancel();
        _startNewGame();
        }else{
          print('already showing ad...');
        }
      }
    });
  }

  @override
  void dispose() {
    isShowingAd = false;
    print('isShowingAd:$isShowingAd');
    _interstitialAd?.dispose();
    super.dispose();
  }
}