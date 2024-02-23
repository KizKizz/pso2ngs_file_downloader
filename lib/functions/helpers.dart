bool isNumeric(String string) {
  if (string.isEmpty) {
    return false;
  }
  final number = num.tryParse(string);

  if (number == null) {
    return false;
  }

  return true;
}