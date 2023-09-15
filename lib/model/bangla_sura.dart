import 'package:flutter/material.dart';
import 'sura_name.dart';

class BanglaSura {
  late final String suraId;
  late final List<String> ayatList;
  late final String tafsir;
  late SuraName suraName;

  //String imageUrl;
  int totalAyat = 0;

  BanglaSura(
      this.suraId,
      this.suraName,
      this.ayatList,
      this.tafsir);
}