import 'package:al_quran/SharedPref.dart';
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

class _SuraDetailScreenState extends State<SuraDetailScreen>{

  //admob
  InterstitialAd? _interstitialAd;
  ///var _delayMax = 30;
  var delayMin = 12;
  //final int _gameLength = SharedPref.getInt('K_AD_TIME_INTERVAL') ?? 30;
  final int _delayMax = 12;
  late var _counter = _delayMax;

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
    setState(() => _counter = _delayMax);
    //_counter = _gameLength;
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
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      setState(() => _counter--);
      //_counter-- ;
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

      if (!isLoadFirstAd && _counter == _delayMax - 1){
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
          saveTime();
          Appodeal.show(AppodealAdType.Interstitial);
        }

        timer.cancel();
        _startLoadNewAd();
      }
    });
  }

  void saveTime() async {
    print('====== save time method ======');

    //Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();
    var today = prefs.getString('K_TODAY');
    var yesterday = prefs.getString('K_YESTERDAY');

    print('====== K_TODAY::$today');
    print('====== K_YESTERDAY::$yesterday');

    if(today == null){
      await prefs.setString('K_TODAY', DateTime.now().toString());
      today = prefs.getString('K_TODAY');
      SharedPref.setInt('K_AD_TIME_INTERVAL', _delayMax);
    }

    DateTime todayDate = DateTime.parse(today!);
    var todayHour = DateFormat.H().format(todayDate);
    var nowHour = DateFormat.H().format(DateTime.now());

    if (yesterday == null){
      var timestamp = DateTime.now().millisecondsSinceEpoch - 1*3600*1000; //3 hours past in mili sec
      final DateTime yesterdayDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      await prefs.setString('K_YESTERDAY', yesterdayDate.toString());
      yesterday = prefs.getString('K_YESTERDAY');
    }

    var yesterdayDate = DateTime.parse(yesterday!);
    var yesterdayHour = DateFormat.H().format(yesterdayDate);

    print('todayHour:$todayHour');
    print('yesterdayHour:$yesterdayHour');
    print('nowHour:$nowHour');

    //save todays ads
    var todaysAds = prefs.getInt('K_TODAYS_ADS');
    var yesterdaysAds = prefs.getInt('K_YESTERDAYS_ADS');

    if(nowHour == todayHour){
      var totalTodaysAds = 0;
      if (todaysAds == null){
        totalTodaysAds = 1;
      }else{
        totalTodaysAds = todaysAds + 1;
      }
      await prefs.setInt('K_TODAYS_ADS', totalTodaysAds);
    }else{
      //save yesterdays ads
      // yesterdayHour = todayHour;
      // todayHour = nowHour;

      await prefs.setString('K_TODAY', today);
      await prefs.setString('K_YESTERDAY', yesterday);

      //todays ads passing into yesterday
      var totalYesterdaysAds = prefs.getInt('K_TODAYS_ADS') ?? 0;
      await prefs.setInt('K_YESTERDAYS_ADS', totalYesterdaysAds);
      await prefs.setInt('K_TODAYS_ADS', 1);

      //check if previous day is yesterday
      if (todayDate != null) {
        DateTime tempYesterday = todayDate.subtract(Duration(hours: 1));
        var tempYesterdayHour = DateFormat.H().format(tempYesterday);
            if (tempYesterdayHour == yesterdayHour){ //real yesterday
              await prefs.setInt('K_YESTERDAYS_ADS', totalYesterdaysAds);
            }else{ // long before yesterday
              await prefs.setInt('K_YESTERDAYS_ADS', 0);
            }
      }

      //calculate new ad interval
      if(totalYesterdaysAds >0){
        var decreaseTodaysInterval = prefs.getInt('K_AD_TIME_INTERVAL') ?? 0;
        if(decreaseTodaysInterval > _delayMax){
          decreaseTodaysInterval = _delayMax; //set max to 30*20 = 600 sec, 10 min
          await prefs.setInt('K_AD_TIME_INTERVAL', decreaseTodaysInterval);
        }else{
          if(decreaseTodaysInterval <= 3){
            decreaseTodaysInterval = 3; //set min to 3*20 = 60 sec, 1 min
            //3*(20 sec interval) = 60 seconds, so increase 1 min
            await prefs.setInt('K_AD_TIME_INTERVAL', decreaseTodaysInterval);
          }else{
            decreaseTodaysInterval =  decreaseTodaysInterval - 3; //3*(20 sec interval) = 60 seconds, so decrease 1 min
            await prefs.setInt('K_AD_TIME_INTERVAL', decreaseTodaysInterval);
          }
        }
      }else{ //yesterday did not used
        var increaseTodaysInterval = prefs.getInt('K_AD_TIME_INTERVAL') ?? 0;
        if(increaseTodaysInterval >= _delayMax){
          increaseTodaysInterval = _delayMax; //set max to 30*20 = 600 sec, 10 min
          await prefs.setInt('K_AD_TIME_INTERVAL', increaseTodaysInterval);
        }else{
          if(increaseTodaysInterval < 3){
            increaseTodaysInterval = 3; //set min to 3*20 = 60 sec, 1 min
            //3*(20 sec interval) = 60 seconds, so increase 1 min
            await prefs.setInt('K_AD_TIME_INTERVAL', increaseTodaysInterval);
          }else{
            increaseTodaysInterval = increaseTodaysInterval + 3; //3*(20 sec interval) = 60 seconds, so increase 1 min
            await prefs.setInt('K_AD_TIME_INTERVAL', increaseTodaysInterval);
          }
        }
      } //end interval
    }

    print('today:$today');
    print('yesterday:$yesterday');

    todaysAds = await SharedPref.getInt('K_TODAYS_ADS');
    yesterdaysAds = await SharedPref.getInt('K_YESTERDAYS_ADS');
    var adInterval = await SharedPref.getInt('K_AD_TIME_INTERVAL');

    print('todaysAds:$todaysAds');
    print('yesterdaysAds:$yesterdaysAds');
    print('K_AD_TIME_INTERVAL:$adInterval');
  }

  // @override
  // void dispose() {
  //   _interstitialAd?.dispose();
  //   super.dispose();
  // }
}


