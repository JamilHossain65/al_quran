import 'package:flutter/material.dart';
import 'model/sura_name.dart';
import 'model/bangla_sura.dart';

class SuraDetailScreen extends StatelessWidget {
  final BanglaSura banglaSura;
  SuraDetailScreen(this.banglaSura);

  @override
  Widget build(BuildContext context) {

    int index = 0;
    print('bangla sura:${banglaSura.ayatList}');

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(banglaSura.suraName.bangla)
      ),
      body: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: banglaSura.ayatList.length,
          itemBuilder: (context,index){
            final banglaAyat= banglaSura.ayatList[index];
            return ListTile(title: Text(banglaAyat),
                onTap: (){
                  //print('did tap taped = ${banglaAyat}');
                }
            );
          }
      ),
    );
  }
}