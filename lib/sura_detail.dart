import 'package:al_quran/admob.dart';
import 'package:al_quran/interstitial_admob.dart';
import 'package:flutter/material.dart';
import 'model/sura_name.dart';
import 'model/bangla_sura.dart';

import 'dart:async';
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class SuraDetailScreen extends StatefulWidget {
  final BanglaSura banglaSura;
  SuraDetailScreen(this.banglaSura);

  @override
  State<SuraDetailScreen> createState() => _SuraDetailScreenState();
}

class _SuraDetailScreenState extends State<SuraDetailScreen> {

  //admob
  InterstitialAd? _interstitialAd;
  final _gameLength = 30;
  late var _counter = _gameLength;
  bool isShowingAd = false;

  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  //admob end

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

    int index = 0;
    print('bangla sura:${widget.banglaSura.ayatList}');

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(widget.banglaSura.suraName.bangla)
      ),
      body: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: widget.banglaSura.ayatList.length,
          itemBuilder: (context,index){
            final banglaAyat= widget.banglaSura.ayatList[index];
            return ListTile(title: Text(banglaAyat),
                onTap: (){
                  //print('did tap taped = ${banglaAyat}');
                }
            );
          }
      ),
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
        _interstitialAd?.show();
        timer.cancel();
        _startNewGame();
      }
    });
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }


}