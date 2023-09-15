import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


class Admob<InterstitialAdmob> {

  InterstitialAd? interstitialAd;
  final gameLength = 30;
  late var counter = gameLength;
  bool isShowingAd = false;

  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';


  //todo need delete
  // late final String suraId;
  // late final List<String> ayatList;
  // late final String tafsir;

  //String imageUrl;
  int totalAyat = 0;

  // Admob(
  //     this.suraId,
  //     this.ayatList,
  //     this.tafsir);

  @override
  void initState() {
    loadAd();
    starTimer();
  }


  /// Loads an interstitial ad.
  void loadAd() {
    print('======load ad mothod called.....=======');
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
            print('======= show ad========');
            interstitialAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            // ignore: avoid_print
            print('InterstitialAd failed to load: $error');
          },
        ));
  }

  void starTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      counter--;

      print('_counter:$counter == $interstitialAd');

      if (counter == 0) {
        if (!isShowingAd) {
          isShowingAd = true;
          interstitialAd?.show();
          timer.cancel();
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
    interstitialAd?.dispose();
    //super.dispose();
  }
}