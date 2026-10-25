/// A word used more than once in a passage.
class RepeatedWord {
  /// The word as the passage usually writes it ("faith", "Abraham").
  final String word;
  final int count;

  const RepeatedWord(this.word, this.count);

  @override
  bool operator ==(Object other) =>
      other is RepeatedWord && other.word == word && other.count == count;

  @override
  int get hashCode => Object.hash(word, count);

  @override
  String toString() => '$word×$count';
}

/// Letters, then letters, apostrophes and inner hyphens.
final RegExp _wordPattern =
    RegExp(r"\p{L}[\p{L}\p{M}'’]*(?:-\p{L}[\p{L}\p{M}'’]*)*", unicode: true);

/// A possessive or contraction ending that doesn't make a new word.
final RegExp _possessive = RegExp(r"['’](?:s|S)?$");

/// The words in [text] used at least [minCount] times, most used first,
/// at most [limit] of them — leaving out [languageCode]'s small words
/// ("the", "and", "unto") and the names that fill every page (God, Jesus,
/// Israel, ...), so what's left is what this passage keeps coming back to.
///
/// Words are matched without case; each is shown in the form the passage
/// uses most. Languages written without spaces (Chinese) get nothing.
List<RepeatedWord> repeatedWords(String text,
    {String languageCode = 'en', int minCount = 2, int limit = 20}) {
  final String language =
      languageCode.toLowerCase().split(RegExp('[_-]')).first;
  if (language == 'zh' || language == 'ja') return const [];
  final Set<String> skip = {
    ...?_stopWords[language],
    ...?_commonNames[language],
  };

  final Map<String, int> counts = {};
  final Map<String, Map<String, int>> forms = {};
  for (final Match m in _wordPattern.allMatches(text)) {
    final String form = m[0]!.replaceFirst(_possessive, '');
    if (form.length < 2) continue;
    final String key = form.toLowerCase();
    if (skip.contains(key)) continue;
    counts[key] = (counts[key] ?? 0) + 1;
    final Map<String, int> seen = forms.putIfAbsent(key, () => {});
    // All-caps LORD-style renderings count as the lowercase form.
    final String shown =
        form == form.toUpperCase() && form.length > 1 ? key : form;
    seen[shown] = (seen[shown] ?? 0) + 1;
  }

  String display(String key) {
    final Map<String, int> seen = forms[key]!;
    // A word only capitalized where it starts a sentence shows lowercase.
    if (seen.containsKey(key)) {
      final int lower = seen[key]!;
      final int other = seen.values.fold(0, (a, b) => a + b) - lower;
      if (lower >= other) return key;
    }
    return seen.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  }

  final List<RepeatedWord> words = [
    for (final MapEntry<String, int> e in counts.entries)
      if (e.value >= minCount) RepeatedWord(display(e.key), e.value)
  ]..sort((a, b) {
      final int byCount = b.count.compareTo(a.count);
      return byCount != 0
          ? byCount
          : a.word.toLowerCase().compareTo(b.word.toLowerCase());
    });
  return words.length > limit ? words.sublist(0, limit) : words;
}

Set<String> _words(String list) =>
    list.split(RegExp(r'\s+')).toSet()..remove('');

final Map<String, Set<String>> _stopWords = {
  'en': _words('''
    a about above after again against all also am an and another any are
    aren't as at be because been before being below between both but by can
    cannot could did do does doing done down during each either even ever
    every few for from further had has have having he her here hers herself
    him himself his how however i if in into is it its itself just let me
    more most much must my myself neither no nor not now of off on once
    one only or other ought our ours ourselves out over own same shall she
    should so some such than that the their theirs them themselves then
    there these they this those through thus to too toward towards under
    until up upon us very was we were what when where whether which while
    who whom whose why will with within without would yet you your yours
    yourself yourselves
    thee thou thy thine ye hath hast doth dost art shalt wilt unto saith
    said say says saying behold lo also verily therefore wherefore whereas
    thereof therein whom whosoever whoever whatever o oh yea nay
    s t don't didn't isn't wasn't won't can't i'm it's let's that's
    '''),
  'es': _words('''
    a al algo algunos ante antes aquel aquella aquellas aquellos aquí así
    aun aunque bajo bien cada como con contra cual cuales cuando cuanto de
    del desde donde dos e el él ella ellas ellos en entre era eran es esa
    esas ese eso esos esta está están estas este esto estos fue fueron ha
    han hasta hay la las le les lo los más me mi mis mismo mucho muy nada
    ni no nos nosotros nuestra nuestro nuestros o os otra otro otros para
    pero por porque pues que qué quien quienes se sea según ser si sí sido
    sin sino sobre son su sus también tan te tenía ti tiene todo todos tu
    tus un una unas uno unos vosotros y ya yo dijo dice he aquí
    '''),
  'fr': _words('''
    à au aux avec ce ceci cela celle celles celui ces cet cette chacun
    comme d dans de des donc du elle elles en encore est et étaient était
    être eu eux fait il ils je l la le les leur leurs lui ma mais me même
    mes moi mon n ne ni nos notre nous on ont ou où par parce pas pour
    qu quand que quel quelle qui s sa sans se ses si son sont sur ta te
    tes toi ton tous tout toute toutes tu un une vos votre vous y c j m t
    a dit voici car ainsi
    '''),
  'pt': _words('''
    a ao aos aquele aquela aqueles aquelas aqui as até com como da das de
    dela dele deles depois do dos e é ela elas ele eles em entre era eram
    essa essas esse esses esta está estão estas este estes eu foi foram
    há isso isto já lhe lhes mais mas me mesmo meu meus minha minhas muito
    na nas nem no nos nós nossa nosso nossos num numa o os ou para pela
    pelas pelo pelos por porque pois quando que quem se sem ser seu seus
    só sua suas também te teu tua tem tinha todo todos tu um uma umas uns
    vos vós disse diz eis
    '''),
  'sw': _words('''
    na ya wa za la kwa katika ni si kama hiyo hii huo hao wao yeye mimi
    sisi ninyi wewe yule ule huyo hicho hivyo hapo pale kule huko lakini
    au pia tena kwamba ili kisha bali hata basi ndiyo hapana nao naye
    nami nawe kila wote yote zote kuwa alikuwa walikuwa akasema wakasema
    alisema ambaye ambao ambayo ambalo ambacho ambavyo ambazo mpaka hadi
    juu chini ndani nje
    '''),
};

/// Names on nearly every page, which would top every list.
final Map<String, Set<String>> _commonNames = {
  'en': _words('''
    god god's lord jesus christ israel israelites israelite jerusalem judah
    jews jew david moses
    '''),
  'es': _words('''
    dios señor jesús jesucristo cristo israel israelitas jerusalén judá
    judíos judío david moisés
    '''),
  'fr': _words('''
    dieu seigneur éternel jésus christ israël israélites jérusalem juda
    juifs juif david moïse
    '''),
  'pt': _words('''
    deus senhor jesus cristo israel israelitas jerusalém judá judeus judeu
    davi moisés
    '''),
  'sw': _words('''
    mungu bwana yesu kristo israeli waisraeli yerusalemu yuda wayahudi
    myahudi daudi musa
    '''),
};
