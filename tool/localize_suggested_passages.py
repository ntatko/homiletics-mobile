#!/usr/bin/env python3
"""Adds translated display fields to data/suggested-passages.json.

Run from the project root after adding or editing weeks:

    python3 tool/localize_suggested_passages.py

Only the English fields need writing by hand ("passage", "study",
"lesson", "rollout"). This fills in, without touching those:

  * top-level "studies": {study url: {locale: display name}}
  * per week "lesson_i18n":  {locale: "BSF Romanos #4"}
  * per week "passage_i18n": {locale: "Romanos 3:1-20"}

The app shows these when they exist for the current language and falls
back to the English fields otherwise. The English "passage" is always the
one sent to Bible Gateway and matched against saved studies, so it must
stay an English reference. Older app versions ignore the extra fields.

Locale keys match Language.code in lib/classes/language.dart.
"""
import json
import re
import sys
from collections import OrderedDict

PATH = 'data/suggested-passages.json'
LOCALES = ['es', 'zh_Hans', 'zh_Hant', 'fr', 'pt', 'sw']

# English book name -> localized name. Add a row when a new book appears;
# the script refuses to guess.
BOOKS = {
    #                es              zh_Hans      zh_Hant      fr              pt              sw
    'Romans':       ('Romanos',      '罗马书',     '羅馬書',     'Romains',      'Romanos',      'Warumi'),
    'Revelation':   ('Apocalipsis',  '启示录',     '啟示錄',     'Apocalypse',   'Apocalipse',   'Ufunuo'),
    'Exodus':       ('Éxodo',        '出埃及记',   '出埃及記',   'Exode',        'Êxodo',        'Kutoka'),
    'Psalm':        ('Salmo',        '诗篇',       '詩篇',       'Psaume',       'Salmo',        'Zaburi'),
    'Psalms':       ('Salmos',       '诗篇',       '詩篇',       'Psaumes',      'Salmos',       'Zaburi'),
    'Daniel':       ('Daniel',       '但以理书',   '但以理書',   'Daniel',       'Daniel',       'Danieli'),
    'Zechariah':    ('Zacarías',     '撒迦利亚书', '撒迦利亞書', 'Zacharie',     'Zacarias',     'Zekaria'),
    'Nehemiah':     ('Nehemías',     '尼希米记',   '尼希米記',   'Néhémie',      'Neemias',      'Nehemia'),
    'Ezra':         ('Esdras',       '以斯拉记',   '以斯拉記',   'Esdras',       'Esdras',       'Ezra'),
    'John':         ('Juan',         '约翰福音',   '約翰福音',   'Jean',         'João',         'Yohana'),
    'Esther':       ('Ester',        '以斯帖记',   '以斯帖記',   'Esther',       'Ester',        'Esta'),
    'Ezekiel':      ('Ezequiel',     '以西结书',   '以西結書',   'Ézéchiel',     'Ezequiel',     'Ezekieli'),
    'Acts':         ('Hechos',       '使徒行传',   '使徒行傳',   'Actes',        'Atos',         'Matendo'),
    'Ephesians':    ('Efesios',      '以弗所书',   '以弗所書',   'Éphésiens',    'Efésios',      'Waefeso'),
    '2 Peter':      ('2 Pedro',      '彼得后书',   '彼得後書',   '2 Pierre',     '2 Pedro',      '2 Petro'),
    '1 Chronicles': ('1 Crónicas',   '历代志上',   '歷代志上',   '1 Chroniques', '1 Crônicas',   '1 Mambo ya Nyakati'),
    'Haggai':       ('Hageo',        '哈该书',     '哈該書',     'Aggée',        'Ageu',         'Hagai'),
    'Malachi':      ('Malaquías',    '玛拉基书',   '瑪拉基書',   'Malachie',     'Malaquias',    'Malaki'),
    'Joel':         ('Joel',         '约珥书',     '約珥書',     'Joël',         'Joel',         'Yoeli'),
}

# Weeks whose "passage" is a word rather than a reference.
WORDS = {
    'Summary':     ('Resumen',     '总结',  '總結',  'Résumé',          'Resumo',      'Muhtasari'),
    'Reflections': ('Reflexiones', '反思',  '反思',  'Réflexions',      'Reflexões',   'Tafakari'),
    'Overview':    ('Panorama',    '概览',  '概覽',  "Vue d’ensemble",  'Visão geral', 'Muhtasari wa jumla'),
}

# Study url -> (English name, then LOCALES order). The English name is
# also the lesson prefix the data uses ("BSF Romans #4").
STUDIES = {
    'bsfinternational.org/bsf/our-studies/romans/':
        ('BSF Romans', 'BSF Romanos', 'BSF 罗马书', 'BSF 羅馬書', 'BSF Romains', 'BSF Romanos', 'BSF Warumi'),
    'bsfinternational.org/exile-and-return/':
        ('BSF Exile', 'BSF Exilio', 'BSF 被掳归回', 'BSF 被擄歸回', 'BSF Exil', 'BSF Exílio', 'BSF Uhamisho'),
    'bsfinternational.org/revelation':
        ('BSF Revelation', 'BSF Apocalipsis', 'BSF 启示录', 'BSF 啟示錄', 'BSF Apocalypse', 'BSF Apocalipse', 'BSF Ufunuo'),
    'bsfinternational.org/john':
        ('BSF John', 'BSF Juan', 'BSF 约翰福音', 'BSF 約翰福音', 'BSF Jean', 'BSF João', 'BSF Yohana'),
    '13one.org/exodus':
        ('The Exodus', 'El Éxodo', '出埃及', '出埃及', "L’Exode", 'O Êxodo', 'Kutoka'),
    'https://13one.org/psalms-of-the-sons-of-korah':
        ('13one | Summer 2025', '13one | Verano 2025', '13one | 2025 夏季', '13one | 2025 夏季',
         '13one | Été 2025', '13one | Verão 2025', '13one | Kiangazi 2025'),
}

# How "<study> #<n>" reads per locale.
LESSON_FORMAT = {
    'es': '{name} #{n}',
    'zh_Hans': '{name} 第{n}课',
    'zh_Hant': '{name} 第{n}課',
    'fr': '{name} n° {n}',
    'pt': '{name} nº {n}',
    'sw': '{name} #{n}',
}

BOOK_RE = re.compile(r'^\s*((?:[1-3] )?[A-Za-z]+(?: [A-Za-z]+)*)(.*)$')


def localize_passage(passage, i):
    if passage.strip() in WORDS:
        return WORDS[passage.strip()][i]
    out = []
    for part in passage.split(';'):
        m = BOOK_RE.match(part)
        if not m:  # a bare chapter range continuing the previous book
            out.append(part.strip())
            continue
        book, rest = m.group(1), m.group(2)
        if book not in BOOKS:
            sys.exit(f'Unknown book "{book}" in "{passage}": add it to BOOKS')
        name = BOOKS[book][i]
        out.append((name + rest) if rest.strip() else name)
    sep = '；' if LOCALES[i].startswith('zh') else '; '
    return sep.join(p.strip() for p in out)


def main():
    with open(PATH, encoding='utf-8') as f:
        doc = json.load(f, object_pairs_hook=OrderedDict)
    studies = OrderedDict()
    for week in doc['data']:
        study = week['study']
        if study not in STUDIES:
            sys.exit(f'Unknown study "{study}": add it to STUDIES')
        names = STUDIES[study]
        studies[study] = OrderedDict(
            [('en', names[0])] + [(loc, names[i + 1]) for i, loc in enumerate(LOCALES)])
        m = re.search(r'#\s*(\d+)\s*$', week['lesson'])
        if m:
            n = m.group(1)
            week['lesson_i18n'] = OrderedDict(
                (loc, LESSON_FORMAT[loc].format(name=names[i + 1], n=n))
                for i, loc in enumerate(LOCALES))
        week['passage_i18n'] = OrderedDict(
            (loc, localize_passage(week['passage'], i)) for i, loc in enumerate(LOCALES))
    out = OrderedDict([('studies', studies)])
    out.update((k, v) for k, v in doc.items() if k != 'studies')
    with open(PATH, 'w', encoding='utf-8') as f:
        json.dump(out, f, ensure_ascii=False, indent=2)
        f.write('\n')
    print(f'{len(doc["data"])} weeks, {len(studies)} studies localized for {", ".join(LOCALES)}')


if __name__ == '__main__':
    main()
