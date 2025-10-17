import 'package:tao996/tao996.dart';

enum Company {
   apple,
   google,
   microsoft,
   amazon,
   facebook,
}
class ConstHelper {
 static List<String> titles = [
    'Apple',
    'Google',
    'Microsoft',
    'Amazon',
    'Facebook',
    'Tencent',
    'Alibaba',
    'Baidu',
    'Toutiao',
    'JD',
  ];
 static  List<KV<Company>> kvTitles = kvCreateList<Company>({
    Company.apple: 'Apple',
    Company.google: 'Google',
    Company.microsoft: 'Microsoft',
    Company.amazon: 'Amazon',
    Company.facebook: 'Facebook',
 });
}