import 'package:flutter/material.dart';

class SuraName {
  late String serial;
  late String bangla;
  late String english;
  late String arabic;

  SuraName(
      this.serial ,
      this.bangla,
      this.english,
      this.arabic
      );

  // factory SuraName.fromJson(Map<String, dynamic> json) => SuraName(
  //   serial : json["serial"]  == null ? null : json["serial"],
  //   bangla : json["bangla"]  == null ? null : json["bangla"],
  //   english: json["english"] == null ? null : json["english"],
  //   arabic : json["arabic"]  == null ? null : json["arabic"],
  // );

  Map<String, dynamic> toJson() => {
    "serial" : serial  == null ? null : serial,
    "bangla" : bangla  == null ? null : bangla,
    "english": english == null ? null : english,
    "arabic" : arabic  == null ? null : arabic,
  };
}