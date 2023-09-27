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
import 'utils.dart';

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
  //var delayMin = 12;
  //final int _gameLength = SharedPref.getInt('K_AD_TIME_INTERVAL') ?? 30;
  final int _delayMax = 3;//4;
  final int _delayUnit =10; //20;
  late var _delayTotal = _delayMax * _delayUnit; //in sec
  late var _counter = _delayMax;

  int appodealRatio = 4;
  int admobRatio = 1;

  final String _adUnitId = Platform.isIOS
      ? 'ca-app-pub-9133033983333483/4055714014'
      : 'ca-app-pub-3940256099942544/1033173712';
  //admob end

  BanglaSura? _banglaSura;

  @override
  void initState() {
    super.initState();
    _startLoadNewAd();

    // By default autocache is enabled for all ad types
    Appodeal.setAutoCache(AppodealAdType.Interstitial, true); //default - true
    Appodeal.cache(AppodealAdType.Interstitial);

    // Set testing mode
    Appodeal.setTesting(true); //default - false
    Appodeal.initialize(
        appKey: "f1b504adc7bf6653c973d87b7387d191517fccd089b79c14",
        adTypes: [
          AppodealAdType.Interstitial,
        ],
        onInitializationFinished: (errors) => {
        });

     //var timestamp = DateTime.now().millisecondsSinceEpoch;
    // final DateTime date1 = DateTime.fromMillisecondsSinceEpoch(timestamp);
    // //var formattedDate  = DateFormat.yMMMd().format(date1);
    // var formattedDate1 = DateFormat.M().format(date1);
    //
    // Utils.log('date1date1:$formattedDate1');
  }

  void _startLoadNewAd() {
    sleep(const Duration(seconds: 1));
    setState(() => _counter = _delayMax);
    //_counter = _gameLength;
    _loadAd();
    _starTimer();
  }

  void _saveAdShownTime() async {
    var timestamp = DateTime.now().millisecondsSinceEpoch;
    await SharedPref.setInt(Utils.kAdShownLastTime,timestamp);
    var time = await SharedPref.setInt(Utils.kAdShownLastTime,timestamp);
    increaseTotalAdShownBy(1);
  }

  void increaseTotalAdShownBy(int value) async{
    var prevAds = await SharedPref.getInt(Utils.kTotalAdShown) ?? 0;
    prevAds++;
    await SharedPref.setInt(Utils.kTotalAdShown,prevAds);
    var newAds = await SharedPref.getInt(Utils.kTotalAdShown) ?? 0;
    Utils.log('newAds:$newAds');
    setState(() => {
      Utils.refreshData().then((value) {
        var totalAyat = (_banglaSura?.ayatList.length ?? 0) - 1;
        if(totalAyat > 0){
          _banglaSura?.ayatList[totalAyat] = value;
        }
      })
    });
  }

  Future<bool> _isTimePastToAd() async {
    var timestamp = DateTime.now().millisecondsSinceEpoch;
    var lastTimeShownAd = await SharedPref.getInt(Utils.kAdShownLastTime) ?? 0;
    Utils.log('timestamp:$timestamp - lastTimeShownAd:$lastTimeShownAd');
    if(timestamp - lastTimeShownAd >= 1000 * _delayTotal){
      return true;
    }
    return false;
  }

  Future<bool> _isShowAdmobAd() async {
    var totalAds = await SharedPref.getInt(Utils.kTotalAdShown) ?? 0;
    Utils.log('totalAds:$totalAds');
    var totalRatio = appodealRatio + admobRatio;
    if (totalAds % totalRatio == 0){
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    int index = 0;
    _banglaSura = widget.banglaSura;

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
            var banglaAyat = widget.banglaSura.ayatList[index];
            if (widget.banglaSura.ayatList.length == index + 1) {
              banglaAyat = _banglaSura!.ayatList[index];
            }
            return ListTile(title: Text(banglaAyat),
                onTap: (){
                  //Utils.log('did tap taped = ${banglaAyat}');
                }
            );
          }
      ),
    );
  }
  
  //Add footer of list view
  //https://dev.to/hemunt_sharma/how-to-add-a-static-widget-at-the-end-of-listview-in-flutter-2p62

  /// Loads an interstitial ad.
  void _loadAd() {
    //RequestConfiguration.Builder().setTestDeviceIds(Arrays.asList("236A58E9281628EE2DC990D4807A5A4C"))

    InterstitialAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (InterstitialAd ad) async {
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
            if (await _isTimePastToAd()) {
              ad.show();
              _saveAdShownTime();
            }
            Utils.log('load ad:$ad');
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            // ignore: avoid_print
            Utils.log('InterstitialAd failed to load: $error');
          },
        ));
  }

  void _starTimer() {
    Timer.periodic(Duration(seconds: _delayUnit), (timer) async {
      setState(() => _counter--);

      if (_counter == _delayMax - 1){
        if (await _isShowAdmobAd()){
          _loadAd();
        }

        var isLoaded = await Appodeal.isLoaded(AppodealAdType.Interstitial);
        Utils.log('isLoaded:$isLoaded');
        if (!isLoaded){
          Appodeal.setInterstitialCallbacks(
              onInterstitialLoaded: (isPrecache) => {},
              onInterstitialFailedToLoad: () => {

              },
              onInterstitialShown: () => {},
              onInterstitialShowFailed: () => {},
              onInterstitialClicked: () => {},
              onInterstitialClosed: () => {},
              onInterstitialExpired: () => {});
        }
      }

      Utils.log('_counter:$_counter, _interstitialAd:$_interstitialAd');
      if (_counter == 0) {
        if (await _isShowAdmobAd()){
          _interstitialAd?.show();
          _saveAdShownTime();
        }else{
          var isCanShow = await Appodeal.canShow(AppodealAdType.Interstitial);
          Utils.log('isCanShow::$isCanShow');
          if (isCanShow) {
            //saveTime();
            Appodeal.show(AppodealAdType.Interstitial);
            _saveAdShownTime();
          }else{
            _interstitialAd?.show();
            _saveAdShownTime();
          }
        }

        timer.cancel();
        _startLoadNewAd();
      }
    });
  }

  /*
  void saveTime() async {
    Utils.log('====== save time method ======');

    //Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();
    var today = prefs.getString('K_TODAY');
    var yesterday = prefs.getString('K_YESTERDAY');

    Utils.log('====== K_TODAY::$today');
    Utils.log('====== K_YESTERDAY::$yesterday');

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

    Utils.log('todayHour:$todayHour');
    Utils.log('yesterdayHour:$yesterdayHour');
    Utils.log('nowHour:$nowHour');

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

    Utils.log('today:$today');
    Utils.log('yesterday:$yesterday');

    todaysAds = await SharedPref.getInt('K_TODAYS_ADS');
    yesterdaysAds = await SharedPref.getInt('K_YESTERDAYS_ADS');
    var adInterval = await SharedPref.getInt('K_AD_TIME_INTERVAL');

    Utils.log('todaysAds:$todaysAds');
    Utils.log('yesterdaysAds:$yesterdaysAds');
    Utils.log('K_AD_TIME_INTERVAL:$adInterval');
  }
*/
  // @override
  // void dispose() {
  //   _interstitialAd?.dispose();
  //   super.dispose();
  // }
}


