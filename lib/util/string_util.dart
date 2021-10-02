import 'dart:math';

import 'package:intl/intl.dart';

class StringUtil {
  static List<String> _romanNumerals = [
    "I",
    "II",
    "III",
    "IV",
    "V",
    "VI",
    "VII",
    "VIII",
    "IX"
  ];
  static List<String> _chineseNumerals = [
    '一',
    '二',
    '三',
    '四',
    '五',
    '六',
    '七',
    '八',
    '九',
    '十',
    '十一',
    '十二'
  ];

  static String parseRomanNumeral(int number) {
    if (number < 1 || number > 9) return number.toString();
    return _romanNumerals[number - 1];
  }

  static String parseChineseNumeral(int number) {
    if (number < 1 || number > 12) return number.toString();
    return _chineseNumerals[number - 1];
  }

  static int charCount(String text) {
    var regExp = new RegExp(r'[\u4e00-\u9fa5]');
    int chineseCount = regExp.allMatches(text).length;
    int charCount = chineseCount * 2 + (text.length - chineseCount);
    return charCount;
  }

  static bool isPhoneNumber(String text) {
    return match(r'^((\+|00)86)?1\d{10}$', text);
  }

  static bool isTelephone(String text) {
    return match(r'^400[0-9]{4,10}|^(0[0-9]{2,3})?\-?[0-9]{4,8}$', text);
  }

  static bool isMobileOrTelephone(String text) {
    return isPhoneNumber(text) || isTelephone(text);
  }

  static bool match(String regExp, String text) {
    if (text == null) return false;
    RegExp exp = new RegExp(regExp);
    return exp.hasMatch(text);
  }

  static int parseInt(String str, {int defValue}) {
    if (str == null || str.isEmpty) return defValue;
    int ret;
    try {
      ret = int.parse(str);
    } catch (e) {
      ret = defValue;
    }
    return ret;
  }

  static String hidePhoneNumber(String phoneNumber) {
    if (isPhoneNumber(phoneNumber)) {
      return phoneNumber.substring(0, 3) +
          '****' +
          phoneNumber.substring(7, 11);
    }
    return phoneNumber;
  }

  static String runeSubstring({String input, int start, int end}) {
    String finalString = '';
    if (input == null) {
      return finalString;
    }
    List<int> individualRunes = input.runes.toList();
    individualRunes.sublist(start, end).forEach((rune) {
      String character = String.fromCharCode(rune);
      finalString = finalString + character;
    });
    return finalString; //return the substring
  }

  static String chunkStr(String input, int len, [suffix = "..."]) {
    if (input == null) {
      return '';
    }
    if (input.length <= len) {
      return input;
    }
    return input.substring(0, len) + suffix;
  }

  static bool _isUtf16Surrogate(int value) {
    return value & 0xF800 == 0xD800;
  }

  static String hide(String text, int start, {int count = -1}) {
    if (text == null || text.isEmpty || start >= text.length) return text;
    String prefix = runeSubstring(input: text, start: 0, end: start);
    // String prefix = text.substring(0, start);
    if (count == -1) return prefix + generate('*', text.length - start);
    int end = start + count + 1;
    end = min(end, text.length);
    String suffix =
        runeSubstring(input: text, start: end - 1, end: text.length);
    // String suffix = text.substring(end - 1);
    return prefix + generate('*', end - start - 1) + suffix;
  }

  static String generate(String s, int count) {
    StringBuffer sb = new StringBuffer();
    List.generate(count, (index) => sb.write(s));
    return sb.toString();
  }

  static String hideAll(String text, {bool hide = true}) {
    if (!hide || text == null) return text;
    return text.replaceAll(RegExp(r'.'), '*');
  }

  static String safeToString(dynamic object, {String defString = ''}) {
    if (object != null) return object.toString();
    return defString;
  }

  static String parseCount(int count, {bool showSuffix = true}) {
    if (count < 10000) {
      return showSuffix ? '$count次' : '$count';
    }
    double num = count / 10000;
    return showSuffix
        ? '${num.toStringAsFixed(1)}万次'
        : '${num.toStringAsFixed(1)}万';
  }

  static String parseTime(int seconds, {bool showHour = false}) {
    String hour = (seconds / 3600).toString();
    String minute = (seconds % 3600 ~/ 60).toString();
    String second = (seconds % 3600 % 60).toString();
    hour = hour.length == 1 ? '0$hour' : hour;
    minute = minute.length == 1 ? '0$minute' : minute;
    second = second.length == 1 ? '0$second' : second;
    String result = '$minute:$second';
    return showHour ? '$hour:$result' : result;
  }

  static bool isIdCard(String cardId) {
    if (cardId.length != 18) {
      return false; // 位数不够
    }
    // 身份证号码正则
    RegExp postalCode = new RegExp(
        r'^[1-9]\d{5}[1-9]\d{3}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{3}([0-9]|[Xx])$');
    // 通过验证，说明格式正确，但仍需计算准确性
    if (!postalCode.hasMatch(cardId)) {
      return false;
    }
    //将前17位加权因子保存在数组里
    final List idCardList = [
      "7",
      "9",
      "10",
      "5",
      "8",
      "4",
      "2",
      "1",
      "6",
      "3",
      "7",
      "9",
      "10",
      "5",
      "8",
      "4",
      "2"
    ];
    //这是除以11后，可能产生的11位余数、验证码，也保存成数组
    final List idCardYArray = [
      '1',
      '0',
      '10',
      '9',
      '8',
      '7',
      '6',
      '5',
      '4',
      '3',
      '2'
    ];
    // 前17位各自乖以加权因子后的总和
    int idCardWiSum = 0;

    for (int i = 0; i < 17; i++) {
      int subStrIndex = int.parse(cardId.substring(i, i + 1));
      int idCardWiIndex = int.parse(idCardList[i]);
      idCardWiSum += subStrIndex * idCardWiIndex;
    }
    // 计算出校验码所在数组的位置
    int idCardMod = idCardWiSum % 11;
    // 得到最后一位号码
    String idCardLast = cardId.substring(17, 18);
    //如果等于2，则说明校验码是10，身份证号码最后一位应该是X
    if (idCardMod == 2) {
      if (idCardLast != 'x' && idCardLast != 'X') {
        return false;
      }
    } else {
      //用计算出的验证码与最后一位身份证号码匹配，如果一致，说明通过，否则是无效的身份证号码
      if (idCardLast != idCardYArray[idCardMod]) {
        return false;
      }
    }
    return true;
  }

  static Map _getAreaCode() {
    Map hashtable = new Map();
    hashtable["11"] = ["北京"];
    hashtable["12"] = ["天津"];
    hashtable["13"] = ["河北"];
    hashtable["14"] = ["山西"];
    hashtable["15"] = ["内蒙古"];
    hashtable["21"] = ["辽宁"];
    hashtable["22"] = ["吉林"];
    hashtable["23"] = ["黑龙江"];
    hashtable["31"] = ["上海"];
    hashtable["32"] = ["江苏"];
    hashtable["33"] = ["浙江"];
    hashtable["34"] = ["安徽"];
    hashtable["35"] = ["福建"];
    hashtable["36"] = ["江西"];
    hashtable["37"] = ["山东"];
    hashtable["41"] = ["河南"];
    hashtable["42"] = ["湖北"];
    hashtable["43"] = ["湖南"];
    hashtable["44"] = ["广东"];
    hashtable["45"] = ["广西"];
    hashtable["46"] = ["海南"];
    hashtable["50"] = ["重庆"];
    hashtable["51"] = ["四川"];
    hashtable["52"] = ["贵州"];
    hashtable["53"] = ["云南"];
    hashtable["54"] = ["西藏"];
    hashtable["61"] = ["陕西"];
    hashtable["62"] = ["甘肃"];
    hashtable["63"] = ["青海"];
    hashtable["64"] = ["宁夏"];
    hashtable["65"] = ["新疆"];
    hashtable["71"] = ["台湾"];
    hashtable["81"] = ["香港"];
    hashtable["82"] = ["澳门"];
    hashtable["91"] = ["国外"];
    return hashtable;
  }

  static bool isDateFormat(String str) {
    DateFormat format = new DateFormat("yyyy-MM-dd");
    try {
      format.parse(str);
      return true;
    } catch (e) {}
    return false;
  }

  static bool isNumeric(String str) {
    RegExp exp = new RegExp(r'[0-9]*');
    return exp.hasMatch(str);
  }
}
