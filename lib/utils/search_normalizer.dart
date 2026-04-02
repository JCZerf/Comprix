String normalizeSearchText(String input) {
  var s = input;
  s = s.replaceAll(RegExp('[ÁÀÂÃÄáàâãä]'), 'a');
  s = s.replaceAll(RegExp('[ÉÈÊËéèêë]'), 'e');
  s = s.replaceAll(RegExp('[ÍÌÎÏíìîï]'), 'i');
  s = s.replaceAll(RegExp('[ÓÒÔÕÖóòôõö]'), 'o');
  s = s.replaceAll(RegExp('[ÚÙÛÜúùûü]'), 'u');
  s = s.replaceAll(RegExp('[Çç]'), 'c');
  s = s.replaceAll(RegExp('[Ññ]'), 'n');
  return s.toLowerCase();
}
