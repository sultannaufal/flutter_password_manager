import 'dart:math';

String generatePassword({
  bool letter = true,
  bool isNumber = true,
  bool isSpecial = true,
  bool isUpper = true,
  int length = 20,
}) {
  var charLength = length;
  const letterLowerCase = "abcdefghijklmnopqrstuvwxyz";
  const letterUpperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  const number = '0123456789';
  const special = '-@#%^*>\$@?/^=+_(){}[]|';

  String chars = "";
  if (letter) chars += letterLowerCase;
  if (isUpper) chars += letterUpperCase;
  if (isNumber) chars += number;
  if (isSpecial) chars += special;

  return List.generate(charLength, (index) {
    final indexRandom = Random.secure().nextInt(chars.length);
    return chars[indexRandom];
  }).join('');
}
