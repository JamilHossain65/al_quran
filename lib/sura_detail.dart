import 'package:al_quran/admob.dart';
import 'package:al_quran/interstitial_admob.dart';
import 'package:flutter/material.dart';
import 'model/sura_name.dart';
import 'model/bangla_sura.dart';

import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';//timestamp
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SuraDetailScreen extends StatefulWidget {
  final BanglaSura banglaSura;
  SuraDetailScreen(this.banglaSura);

  @override
  State<SuraDetailScreen> createState() => _SuraDetailScreenState();
}

class _SuraDetailScreenState extends State<SuraDetailScreen> {

  Future<String> getFromLocalMemory(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString(key) as String;
    return user;
  }

  //admob
  InterstitialAd? _interstitialAd;
  final _gameLength = 30;
  late var _counter = _gameLength;

  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-9133033983333483/4055714014'
      : 'ca-app-pub-3940256099942544/1033173712';
  //admob end

  bool adShownFirstAd = false;
  bool isLoadFirstAd = false;

  @override
  void initState() {
    super.initState();
    _startLoadNewAd();

    // var userInfo;
    // getFromLocalMemory('user').then((value) =>
    // userInfo = value
    // );
    //
    // print('userInfouserInfo::$userInfo');

    // Set ad auto caching enabled or disabled
// By default autocache is enabled for all ad types
    Appodeal.setAutoCache(AppodealAdType.Interstitial, true); //default - true
    //Appodeal.cache(AppodealAdType.Interstitial);

// Set testing mode
    Appodeal.setTesting(true); //default - false

    Appodeal.initialize(
        appKey: "f1b504adc7bf6653c973d87b7387d191517fccd089b79c14",
        adTypes: [
          AppodealAdType.Interstitial
        ],
        onInitializationFinished: (errors) => {
        });

    // var timestamp = DateTime.now().millisecondsSinceEpoch;
    // final DateTime date1 = DateTime.fromMillisecondsSinceEpoch(timestamp);
    // //var formattedDate  = DateFormat.yMMMd().format(date1);
    // var formattedDate1 = DateFormat.M().format(date1);
    //
    // print('date1date1:$formattedDate1');
  }

  void _startLoadNewAd() {
    sleep(const Duration(seconds: 1));
    setState(() => _counter = _gameLength);
    _loadAd();
    _starTimer();
  }

  @override
  Widget build(BuildContext context) {

    int index = 0;
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(widget.banglaSura.suraName.bangla),
          // actions: <Widget>[
          //   TextButton(
          //     onPressed: () {},
          //     child: Text('Save'),
          //   ),
          // ]
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
            if (!adShownFirstAd){
              adShownFirstAd = true;
              //ad.show();
            }
            print('load ad:$ad');
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            // ignore: avoid_print
            print('InterstitialAd failed to load: $error');
          },
        ));
  }

  void _starTimer() {
    Timer.periodic(const Duration(seconds: 20), (timer) async {
      setState(() => _counter--);
      if (_counter == 1){
        _loadAd();

        Appodeal.setInterstitialCallbacks(
            onInterstitialLoaded: (isPrecache) => {
            },
            onInterstitialFailedToLoad: () => {},
            onInterstitialShown: () => {},
            onInterstitialShowFailed: () => {},
            onInterstitialClicked: () => {},
            onInterstitialClosed: () => {},
            onInterstitialExpired: () => {});
      }

      if (!isLoadFirstAd && _counter == _gameLength - 1){
        _loadAd();
        isLoadFirstAd = true;
      }

      print('_counter:$_counter adShown:[$adShownFirstAd] == _interstitialAd:$_interstitialAd');
      if (_counter == 0) {

        //_interstitialAd?.show();
        // Show interstitial
        // Check that interstitial
        var isCanShow = await Appodeal.canShow(AppodealAdType.Interstitial);
        if (isCanShow) {
          Appodeal.show(AppodealAdType.Interstitial);
        }

        timer.cancel();
        _startLoadNewAd();
      }
    });
  }

  // @override
  // void dispose() {
  //   _interstitialAd?.dispose();
  //   super.dispose();
  // }
}
