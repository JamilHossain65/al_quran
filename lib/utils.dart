
import 'SharedPref.dart';

//for production mode
class Utils {
  static String kAdShownLastTime = 'K_AD_SHOWN_LAST_TIME';
  static String kTotalAdShown = 'K_TOTAL_AD_SHOWN';

  static log(String value){
    print(value);
  }

  static Future <String> refreshData() async{
    var totalAds = await SharedPref.getInt(Utils.kTotalAdShown) ?? 0;
    var newVersionString = '0.0.$totalAds';
    return newVersionString;
  }
}