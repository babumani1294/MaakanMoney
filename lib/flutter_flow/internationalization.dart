import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleStorageKey = '__locale_key__';

class FFLocalizations {
  FFLocalizations(this.locale);

  final Locale locale;

  static FFLocalizations of(BuildContext context) =>
      Localizations.of<FFLocalizations>(context, FFLocalizations)!;

  static List<String> languages() => ['en', 'ta'];

  static late SharedPreferences _prefs;
  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();
  static Future storeLocale(String locale) =>
      _prefs.setString(_kLocaleStorageKey, locale);
  static Locale? getStoredLocale() {
    final locale = _prefs.getString(_kLocaleStorageKey);
    return locale != null && locale.isNotEmpty ? createLocale(locale) : null;
  }

  String get languageCode => locale.toString();
  String? get languageShortCode =>
      _languagesWithShortCode.contains(locale.toString())
          ? '${locale.toString()}_short'
          : null;
  int get languageIndex => languages().contains(languageCode)
      ? languages().indexOf(languageCode)
      : 0;

  String getText(String key) =>
      (kTranslationsMap[key] ?? {})[locale.toString()] ?? '';

  String getVariableText({
    String? enText = '',
    String? taText = '',
  }) =>
      [enText, taText][languageIndex] ?? '';

  static const Set<String> _languagesWithShortCode = {
    'ar',
    'az',
    'ca',
    'cs',
    'da',
    'de',
    'dv',
    'en',
    'es',
    'et',
    'fi',
    'fr',
    'gr',
    'he',
    'hi',
    'hu',
    'it',
    'km',
    'ku',
    'mn',
    'ms',
    'no',
    'pt',
    'ro',
    'ru',
    'rw',
    'sv',
    'th',
    'uk',
    'vi',
  };
}

class FFLocalizationsDelegate extends LocalizationsDelegate<FFLocalizations> {
  const FFLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    final language = locale.toString();
    return FFLocalizations.languages().contains(
      language.endsWith('_')
          ? language.substring(0, language.length - 1)
          : language,
    );
  }

  @override
  Future<FFLocalizations> load(Locale locale) =>
      SynchronousFuture<FFLocalizations>(FFLocalizations(locale));

  @override
  bool shouldReload(FFLocalizationsDelegate old) => false;
}

Locale createLocale(String language) => language.contains('_')
    ? Locale.fromSubtags(
        languageCode: language.split('_').first,
        scriptCode: language.split('_').last,
      )
    : Locale(language);

final kTranslationsMap = <Map<String, Map<String, String>>>[
  // CreateAccount
  {
    'd3ivgk4j': {
      'en': 'MAAKAAN',
      'ta': 'மகான்',
    },
    'skoktae6': {
      'en': 'Phone Sign In',
      'ta': 'தொலைபேசி உள்நுழைவு',
    },
    'd72tu5vd': {
      'en': 'Your Phone Number...',
      'ta': 'உங்கள் தொலைபேசி எண்...',
    },
    'fvkz53zt': {
      'en': '+1 (204) 204-2056',
      'ta': '+1 (204) 204-2056',
    },
    'rvbh1o4t': {
      'en': 'Submit',
      'ta': 'சமர்ப்பிக்கவும்',
    },
    '6o8ommu4': {
      'en': 'Home',
      'ta': 'வீடு',
    },
  },
  // Budget
  {
    'zgmnjxtf': {
      'en': 'Dashboard',
      'ta': 'டாஷ்போர்டு',
    },
    '45gbukuf': {
      'en': 'BABU',
      'ta': 'பாபு',
    },
    'hv0w50bv': {
      'en': '9876543210',
      'ta': '9876543210',
    },
    'tfqctng2': {
      'en': 'Net Balance',
      'ta': 'நிகர இருப்பு',
    },
    'znh71h7i': {
      'en': '50 Rs',
      'ta': '50 ரூ',
    },
    'yu5n01v8': {
      'en': '50 Rs',
      'ta': '50 ரூ',
    },
    '3h2rk3th': {
      'en': '10 Rs',
      'ta': '10 ரூ',
    },
    '8dygp1d6': {
      'en': 'Transactions',
      'ta': 'பரிவர்த்தனைகள்',
    },
    '0gxk52re': {
      'en': 'Deposit',
      'ta': 'வைப்பு',
    },
    '5vsqssjz': {
      'en': '18-05-2023',
      'ta': '18-05-2023',
    },
    'wj09pzkg': {
      'en': '50.00 Rs',
      'ta': '50.00 ரூ',
    },
    'axjjb2kd': {
      'en': 'Deposit',
      'ta': 'வைப்பு',
    },
    'yag4aln1': {
      'en': '18-05-2023',
      'ta': '18-05-2023',
    },
    'whrp4ij9': {
      'en': '80.00 Rs',
      'ta': '80.00 ரூ',
    },
    'hg7nan2y': {
      'en': 'Deposit',
      'ta': 'வைப்பு',
    },
    '354wr7od': {
      'en': '18-05-2023',
      'ta': '18-05-2023',
    },
    'vev9aaot': {
      'en': '80.00 Rs',
      'ta': '80.00 ரூ',
    },
    'gtqvcm0z': {
      'en': 'Deposit',
      'ta': 'வைப்பு',
    },
    'bkbg2fek': {
      'en': '18-05-2023',
      'ta': '18-05-2023',
    },
    'wesum831': {
      'en': '80.00 Rs',
      'ta': '80.00 ரூ',
    },
    '28rk90kn': {
      'en': 'Deposit',
      'ta': 'வைப்பு',
    },
    'e7hg2azs': {
      'en': '18-05-2023',
      'ta': '18-05-2023',
    },
    '6ek1yhns': {
      'en': '80.00 Rs',
      'ta': '80.00 ரூ',
    },
    'z91fv8bp': {
      'en': 'Deposit',
      'ta': 'வைப்பு',
    },
    'zsspx0t1': {
      'en': '18-05-2023',
      'ta': '18-05-2023',
    },
    'tahb3x36': {
      'en': '80.00 Rs',
      'ta': '80.00 ரூ',
    },
    '6xw5u9gr': {
      'en': 'Home',
      'ta': 'வீடு',
    },
  },
  // BudgetCopy
  {
    '8ex1kzlh8': {
      'en': 'Good Morning',
      'ta': 'காலை வணக்கம்',
    },
    '8ex1kzlh': {
      'en': 'Dashboard',
      'ta': 'டாஷ்போர்டு',
    },
    'ypk7wpoq': {
      'en': 'Anand - Admin',
      'ta': 'ஆனந்த் - நிர்வாகம்',
    },
    'x6nw4jl8': {
      'en': '9876543210',
      'ta': '9876543210',
    },
    'lfgx5yff': {
      'en': 'Net Balance',
      'ta': 'நிகர இருப்பு',
    },
    'p8ej2kg6': {
      'en': '50 Rs',
      'ta': '50 ரூ',
    },
    'x2e1wpw3': {
      'en': 'Credited',
      'ta': 'வரவு',
    },
    '0qxzch1c': {
      'en': 'Debited',
      'ta': 'பற்று வைக்கப்பட்டது',
    },
    'so8xg5if': {
      'en': '50 Rs',
      'ta': '50 ரூ',
    },
    '5e448t9e': {
      'en': '10 Rs',
      'ta': '10 ரூ',
    },
    'e503tryi': {
      'en': 'Transactions',
      'ta': 'பரிவர்த்தனைகள்',
    },
    'yrmjm832': {
      'en': 'Anand',
      'ta': 'ஆனந்த்',
    },
    '8qh37u94': {
      'en': 'MM00024, 9041253698',
      'ta': 'MM00024, 9041253698',
    },
    '19bd2zcr': {
      'en': 'Last transaction - 24-03-1998',
      'ta': 'கடைசி பரிவர்த்தனை - 24-03-1998',
    },
    '08s28642': {
      'en': '50 Rs',
      'ta': '50 ரூ',
    },
    'pd2zqqvw': {
      'en': 'Anand',
      'ta': 'ஆனந்த்',
    },
    'ldxbahad': {
      'en': 'MM00024, 9041253698',
      'ta': 'MM00024, 9041253698',
    },
    '8i3nrw2q': {
      'en': 'Last transaction - 24-03-1998',
      'ta': 'கடைசி பரிவர்த்தனை - 24-03-1998',
    },
    'pjv9524o': {
      'en': '50 Rs',
      'ta': '50 ரூ',
    },
    'yn6yja90': {
      'en': 'Anand',
      'ta': 'ஆனந்த்',
    },
    'r801xyh8': {
      'en': 'MM00024, 9041253698',
      'ta': 'MM00024, 9041253698',
    },
    '901fzrwc': {
      'en': 'Last transaction - 24-03-1998',
      'ta': 'கடைசி பரிவர்த்தனை - 24-03-1998',
    },
    'rxzbnswb': {
      'en': '50 Rs',
      'ta': '50 ரூ',
    },
    'hbpa3k0s': {
      'en': 'Anand',
      'ta': 'ஆனந்த்',
    },
    'l8nl5z1o': {
      'en': 'MM00024, 9041253698',
      'ta': 'MM00024, 9041253698',
    },
    '2jxxdsvq': {
      'en': 'Last transaction - 24-03-1998',
      'ta': 'கடைசி பரிவர்த்தனை - 24-03-1998',
    },
    'ey3gjpf3': {
      'en': '50 Rs',
      'ta': '50 ரூ',
    },
    '550hdn54': {
      'en': 'Anand',
      'ta': 'ஆனந்த்',
    },
    'dx954yw1': {
      'en': 'MM00024, 9041253698',
      'ta': 'MM00024, 9041253698',
    },
    'o3jls7lt': {
      'en': 'Last transaction - 24-03-1998',
      'ta': 'கடைசி பரிவர்த்தனை - 24-03-1998',
    },
    '22plg2nm': {
      'en': '50 Rs',
      'ta': '50 ரூ',
    },
    'ujazv8wn': {
      'en': 'Anand',
      'ta': 'ஆனந்த்',
    },
    'gy0bqmgu': {
      'en': 'MM00024, 9041253698',
      'ta': 'MM00024, 9041253698',
    },
    '4jte7jmr': {
      'en': 'Last transaction - 24-03-1998',
      'ta': 'கடைசி பரிவர்த்தனை - 24-03-1998',
    },
    '60ydu4op': {
      'en': '50 Rs',
      'ta': '50 ரூ',
    },
    '5k6wr0sh': {
      'en': 'Home',
      'ta': 'வீடு',
    },
  },
  // Adduser
  {
    'uzh1m0n9': {
      'en': 'MM00026',
      'ta': 'MM00026',
    },
    '0nbq1nrp': {
      'en': 'NAME',
      'ta': 'NAME',
    },
    'jfu76k1i': {
      'en': 'MOBILE NUMBER',
      'ta': 'கைபேசி எண்',
    },
    'jdq9v5wm': {
      'en': 'Add User',
      'ta': 'பயனரைச் சேர்க்கவும்',
    },
    'l3nh6fz4': {
      'en': 'User will receive an SMS with their account details',
      'ta': 'பயனர் தனது கணக்கு விவரங்களுடன் ஒரு எஸ்எம்எஸ் பெறுவார்',
    },
    '3usdhnov': {
      'en': 'Add user',
      'ta': 'பயனரைச் சேர்க்கவும்',
    },
  },
  // UpdateMoney
  {
    'sbu9dn9o': {
      'en': 'Withdrawn',
      'ta': 'திரும்பப் பெறப்பட்டது',
    },
    '0jd4um7o': {
      'en': 'Deposited',
      'ta': 'டெபாசிட் செய்யப்பட்டது',
    },
    'ertqpqwi': {
      'en': 'Rs 50',
      'ta': 'ரூ 50',
    },
    'x6zinb8w': {
      'en': 'Updaate',
      'ta': 'புதுப்பிக்கவும்',
    },
    'z21qzzg8': {
      'en': 'Home',
      'ta': 'வீடு',
    },
  },
  // Miscellaneous
  {
    'ggn6f537': {
      'en': '',
      'ta': '',
    },
    '8ojl76dy': {
      'en': '',
      'ta': '',
    },
    'nicdn8qv': {
      'en': '',
      'ta': '',
    },
    'v8na2n5z': {
      'en': '',
      'ta': '',
    },
    'j26dm1ph': {
      'en': '',
      'ta': '',
    },
    'uzt647yr': {
      'en': '',
      'ta': '',
    },
    '6epemkv1': {
      'en': '',
      'ta': '',
    },
    'jm19muw3': {
      'en': '',
      'ta': '',
    },
    'mdk5gzih': {
      'en': '',
      'ta': '',
    },
    'ljph860t': {
      'en': '',
      'ta': '',
    },
    'vdlk9ecv': {
      'en': '',
      'ta': '',
    },
    'wtnhxr4d': {
      'en': '',
      'ta': '',
    },
    'xmgjjroa': {
      'en': '',
      'ta': '',
    },
    '6d0303zd': {
      'en': '',
      'ta': '',
    },
    '7ld50ygt': {
      'en': '',
      'ta': '',
    },
    'm05t6fla': {
      'en': '',
      'ta': '',
    },
    'lahyxk3b': {
      'en': '',
      'ta': '',
    },
    '1wy3yg49': {
      'en': '',
      'ta': '',
    },
    'c9xegjws': {
      'en': '',
      'ta': '',
    },
    'jgypea7x': {
      'en': '',
      'ta': '',
    },
    'o4hprha1': {
      'en': '',
      'ta': '',
    },
  },
].reduce((a, b) => a..addAll(b));
