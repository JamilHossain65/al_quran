// import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'model/sura_name.dart';
import 'model/bangla_sura.dart';
import 'sura_detail.dart';
import 'interstitial_admob.dart';
import 'utils.dart';
import 'SharedPref.dart';

// Flutter DB Doc
// https://docs.flutter.dev/cookbook/persistence/sqlite

// Update app icon
// https://docs.flutter.dev/ui/assets/assets-and-images#asset-bundling

// Create google playstore account
// https://www.youtube.com/watch?v=5GHT4QtotE4

//Create app bundle
//https://www.youtube.com/watch?v=yzCksccyrtE
//https://www.youtube.com/watch?v=ofmI9-F1-Zs&t=215s
//https://docs.flutter.dev/deployment/android
//https://pub.dev/documentation/stack_appodeal_flutter/latest/

void main() {
  runApp(const AlQuran());
}

class AlQuran extends StatefulWidget {
  const AlQuran({super.key});

  @override
  State<AlQuran> createState() => _AlQuranState();
}

class _AlQuranState extends State<AlQuran> {
  int index = 0;
  String banglaOriginalText = '';

  var suraNameJson;

  // Fetch content from the json file
  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/sura_name.json');
    final data = await json.decode(response);
    setState(() {
      suraNameJson = data;
      //print('data:$data');
    });
  }
  void loadData(String filename) async {
    final loadedData = await rootBundle.loadString('assets/$filename');
    setState(() {
      banglaOriginalText = loadedData;
    });
  }

  SuraName getSuraName(BanglaSura banglaSura, String suraId){
    var suraSerialNo = banglaSura.suraId.split(",").first;
    var dataLanguage = suraNameJson["$suraSerialNo"];
    //print('dataLanguage:$dataLanguage');
    var suranameArabic = dataLanguage?["arabic"];
    var suranameBangla = dataLanguage?["bangla"];
    var suranameEnglish = dataLanguage?["english"];
    //print('suraname:$suranameArabic');

    SuraName suraName = SuraName(
        banglaSura.suraId,
        suranameBangla,
        suranameEnglish,
        suranameArabic
    );
    return suraName;
  }
  void loadSuraNameJson(String filename) async {

  }

  List<BanglaSura> getBanglaSuraList() {
    List<BanglaSura> banglaSuraList = [];
    List<String> banglaSuraText = banglaOriginalText.split("\n\n\n");

    int count = 0;
    for (final suraString in banglaSuraText){
      List<String> banglaAyatList = suraString.split("\n");
      String suraId = banglaAyatList.first;
      //print('suraId  = $suraId');
      Utils.refreshData().then((value) {
        banglaAyatList.add(value);
      });

      SuraName suraName = SuraName("", "", "", "");

      //remove first index
      banglaAyatList.remove(suraId);
      BanglaSura banglaSura = BanglaSura(suraId,suraName,banglaAyatList, 'tafsir');

      banglaSuraList.add(banglaSura);
      count += 1;
    }
    return banglaSuraList;
  }

  List<SuraName> getSuraNameList() {
    List<SuraName> suraNameList = [];
    return suraNameList;
  }

  @override
  void initState() {
    super.initState();
    loadData('verse_bangla.txt');
    readJson();
  }

  @override
  Widget build(BuildContext context) {
    List<BanglaSura> banglaSuraList = getBanglaSuraList();

    List<SuraName> suraNameList = getSuraNameList();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('আল কুরআন আমপারা'),
        ),
        body: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: banglaSuraList.length,
            itemBuilder: (context,index){
              var banglaSura = banglaSuraList[index];
              //var suraSerialNo = banglaSura.suraId.split(",").first;
              SuraName suraName = getSuraName(banglaSura, banglaSura.suraId);
              return ListTile(title: Text(suraName.bangla),
                  onTap: (){
                    banglaSura.suraName = getSuraName(banglaSura, banglaSura.suraId);
                    print('did tap taped = ${banglaSura.suraId}');
                    _navigateToNextScreen(context,banglaSura);
                  }
              );
            }
        ),
      ),
    );
  }

  void _navigateToNextScreen(BuildContext context,BanglaSura banglaSura) {
    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => SuraDetailScreen(banglaSura)
        )
    );
  }
}

