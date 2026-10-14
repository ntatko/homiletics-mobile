#!/usr/bin/env python3
"""Builds the offline Bible texts the verse panel can show natively.

Run from the project root:

    python3 tool/build_bibles.py            # every translation in TEXTS
    python3 tool/build_bibles.py web kjv    # just these app codes

For each entry in TEXTS this downloads the eBible.org USFM zip, keeps the
66 protocanonical books, and writes data/bibles/<app code>.json.gz. The
app downloads those files on demand from GitHub raw (see
lib/services/bible_text_service.dart), so commit them after building.
Every text here must be public domain or under a licence that allows
redistribution; record each one in data/bibles/SOURCES.md.

Output (gzipped, compact JSON):

    {
      "format": 1, "code": "web", "name": "...", "short": "WEB",
      "language": "en", "license": "Public Domain", "copyright": "...",
      "source": "https://ebible.org/engwebp/",
      "books": [
        {"id": "GEN", "osis": "Gen", "name": "Genesis",
         "chapters": [
           {"c": 1,
            "v": [[1, "In the beginning..."], [2, "..."], [9, "...", 10]],
            "h": [[1, "The Creation"], [1, "A Psalm by David.", 1]],
            "p": [1, 3],     # verses that start a paragraph
            "l": [2, 4]}     # verses that start a new line (poetry)
         ]}
      ]
    }

A verse is [number, text] or [first, text, last] for a combined range.
"\n" inside a verse is a poetry line break. A heading is [verse it comes
before, text] with a trailing 1 for a psalm title/description.
"""
import gzip
import io
import json
import os
import re
import sys
import urllib.request
import zipfile

OUT_DIR = os.path.join('data', 'bibles')
CACHE_DIR = os.path.join('build', 'bible_sources')

# App translation code -> eBible.org translation id and licence notes.
# Only add texts that are public domain or freely redistributable, and
# check https://ebible.org/<id>/copyright.htm first.
TEXTS = {
    'web': dict(ebible='engwebp', name='World English Bible', short='WEB',
                language='en', license='Public Domain',
                copyright='World English Bible — Public Domain. eBible.org'),
    'kjv': dict(ebible='eng-kjv2006', name='King James Version', short='KJV',
                language='en', license='Public Domain',
                copyright='King James Version (1769 text) — Public Domain '
                          'outside the United Kingdom.'),
    'bbe': dict(ebible='engBBE', name='Bible in Basic English', short='BBE',
                language='en', license='Public Domain',
                copyright='Bible in Basic English (1965) — Public Domain.'),
    'rv1909': dict(ebible='spaRV1909', name='Reina-Valera 1909',
                   short='RV1909', language='es', license='Public Domain',
                   copyright='Santa Biblia Reina-Valera 1909 — Dominio público.'),
    'lsg': dict(ebible='fraLSG', name='Louis Segond 1910', short='LSG',
                language='fr', license='Public Domain',
                copyright='Louis Segond 1910 — Domaine public.'),
    'cuvmps': dict(ebible='cmn-cu89s', name='新标点和合本（简体）',
                   short='CUVMPS', language='zh', license='Public Domain',
                   copyright='新标点和合本 — eBible.org 标为公共领域（Public Domain）。'),
    'cuvmpt': dict(ebible='cmn-cu89t', name='新標點和合本（繁體）',
                   short='CUVMPT', language='zh', license='Public Domain',
                   copyright='新標點和合本 — eBible.org 標為公共領域（Public Domain）。'),
    'ccb': dict(ebible='cmncbs', name='当代译本（简体）', short='CCB',
                language='zh', license='CC BY-SA 4.0',
                copyright='Biblica® 圣经当代译本™开放资源 版权所有©1979, 2005, '
                          '2007, 2011, 2022 Biblica, Inc. 按照 CC BY-SA 4.0 '
                          '许可证提供；可在 www.biblica.com 和 open.bible 免费使用。'),
    'ccbt': dict(ebible='cmncbt', name='當代譯本（繁體）', short='CCBT',
                 language='zh', license='CC BY-SA 4.0',
                 copyright='Biblica® 聖經，當代譯本™開放資源 版權所有©1979, 2005, '
                           '2007, 2012, 2023 Biblica, Inc. 按照 CC BY-SA 4.0 '
                           '許可證提供；可在 www.biblica.com 和 open.bible 免費使用。'),
    'blivre': dict(ebible='porbr2018', name='Bíblia Livre', short='BLIVRE',
                   language='pt', license='CC BY 4.0 BR',
                   copyright='Bíblia Livre (BLIVRE), Copyright © Diego Santos, '
                             'Mario Sérgio, e Marco Teles, fevereiro de 2018. '
                             'Licença Creative Commons Atribuição 4.0 Brasil.'),
    'snt': dict(ebible='swhonen', name='Neno: Bibilia Takatifu', short='SNT',
                language='sw', license='CC BY-SA 4.0',
                copyright='Biblica® Toleo Wazi Neno: Bibilia Takatifu™ '
                          'copyright © 1984, 1989, 2009, 2015 Biblica, Inc. '
                          'Licensed CC BY-SA 4.0; free at www.biblica.com '
                          'and open.bible.'),
}

# The 66 books: USFM code, OSIS id, English name.
BOOKS = [
    ('GEN', 'Gen', 'Genesis'), ('EXO', 'Exod', 'Exodus'),
    ('LEV', 'Lev', 'Leviticus'), ('NUM', 'Num', 'Numbers'),
    ('DEU', 'Deut', 'Deuteronomy'), ('JOS', 'Josh', 'Joshua'),
    ('JDG', 'Judg', 'Judges'), ('RUT', 'Ruth', 'Ruth'),
    ('1SA', '1Sam', '1 Samuel'), ('2SA', '2Sam', '2 Samuel'),
    ('1KI', '1Kgs', '1 Kings'), ('2KI', '2Kgs', '2 Kings'),
    ('1CH', '1Chr', '1 Chronicles'), ('2CH', '2Chr', '2 Chronicles'),
    ('EZR', 'Ezra', 'Ezra'), ('NEH', 'Neh', 'Nehemiah'),
    ('EST', 'Esth', 'Esther'), ('JOB', 'Job', 'Job'),
    ('PSA', 'Ps', 'Psalms'), ('PRO', 'Prov', 'Proverbs'),
    ('ECC', 'Eccl', 'Ecclesiastes'), ('SNG', 'Song', 'Song of Songs'),
    ('ISA', 'Isa', 'Isaiah'), ('JER', 'Jer', 'Jeremiah'),
    ('LAM', 'Lam', 'Lamentations'), ('EZK', 'Ezek', 'Ezekiel'),
    ('DAN', 'Dan', 'Daniel'), ('HOS', 'Hos', 'Hosea'),
    ('JOL', 'Joel', 'Joel'), ('AMO', 'Amos', 'Amos'),
    ('OBA', 'Obad', 'Obadiah'), ('JON', 'Jonah', 'Jonah'),
    ('MIC', 'Mic', 'Micah'), ('NAM', 'Nah', 'Nahum'),
    ('HAB', 'Hab', 'Habakkuk'), ('ZEP', 'Zeph', 'Zephaniah'),
    ('HAG', 'Hag', 'Haggai'), ('ZEC', 'Zech', 'Zechariah'),
    ('MAL', 'Mal', 'Malachi'),
    ('MAT', 'Matt', 'Matthew'), ('MRK', 'Mark', 'Mark'),
    ('LUK', 'Luke', 'Luke'), ('JHN', 'John', 'John'),
    ('ACT', 'Acts', 'Acts'), ('ROM', 'Rom', 'Romans'),
    ('1CO', '1Cor', '1 Corinthians'), ('2CO', '2Cor', '2 Corinthians'),
    ('GAL', 'Gal', 'Galatians'), ('EPH', 'Eph', 'Ephesians'),
    ('PHP', 'Phil', 'Philippians'), ('COL', 'Col', 'Colossians'),
    ('1TH', '1Thess', '1 Thessalonians'), ('2TH', '2Thess', '2 Thessalonians'),
    ('1TI', '1Tim', '1 Timothy'), ('2TI', '2Tim', '2 Timothy'),
    ('TIT', 'Titus', 'Titus'), ('PHM', 'Phlm', 'Philemon'),
    ('HEB', 'Heb', 'Hebrews'), ('JAS', 'Jas', 'James'),
    ('1PE', '1Pet', '1 Peter'), ('2PE', '2Pet', '2 Peter'),
    ('1JN', '1John', '1 John'), ('2JN', '2John', '2 John'),
    ('3JN', '3John', '3 John'), ('JUD', 'Jude', 'Jude'),
    ('REV', 'Rev', 'Revelation'),
]
BOOK_INDEX = {code: i for i, (code, _, _) in enumerate(BOOKS)}

# Notes and cross references, removed with their content.
_NOTE_RE = re.compile(r'\\(f|fe|ef|x|ex)\s.*?\\\1\*', re.S)
# Character styles whose content is dropped (alternate numbering, figures,
# inline cross-reference quotes).
_DROP_RE = re.compile(r'\\\+?(ca|va|vp|fig|rq|cat)\s.*?\\\+?\1\*', re.S)
# \w word|lemma="..."\w*  ->  word
_WORD_RE = re.compile(r'\\\+?(w|wg|wh|wa)\s+([^|\\]*?)(\|[^\\]*?)?\\\+?\1\*')
# Divine name, shown in capitals (the printed small caps).
_ND_RE = re.compile(r'\\\+?nd\s+(.*?)\\\+?nd\*', re.S)
# Remaining character style markers (opening and closing); text is kept.
_CHAR_STYLES = ('add|bk|bd|bdit|dc|em|it|k|lit|no|ord|pn|png|addpn|qac|qs|qt|'
                'sc|sig|sls|tl|wj|ior|iqt|rb|sup|xt|jmp|litl|fv')
_CHAR_RE = re.compile(r'\\\+?(?:%s)\*|\\\+?(?:%s)\s' % (_CHAR_STYLES, _CHAR_STYLES))
_MARKER_RE = re.compile(r'\\([a-z]+[0-9]*\*?)[ \t]?')

# Markers that begin a new paragraph or poetry line.
_PARA = {'p', 'm', 'pmo', 'pm', 'pmc', 'pmr', 'pc', 'pr', 'mi', 'cls',
         'pi', 'pi1', 'pi2', 'pi3', 'ph', 'ph1', 'ph2', 'ph3',
         'li', 'li1', 'li2', 'li3', 'li4', 'lim', 'lim1', 'lim2'}
_LINE = {'q', 'q1', 'q2', 'q3', 'q4', 'qr', 'qc', 'qm', 'qm1', 'qm2', 'qm3',
         'qd'}
_HEADING = {'s', 's1', 's2', 's3', 's4', 'ms', 'ms1', 'ms2', 'ms3', 'qa',
            'sp', 'mte', 'mte1', 'mte2'}
# Table cells and the like: text continues on the same line.
_INLINE = {'tr', 'th1', 'th2', 'th3', 'th4', 'tc1', 'tc2', 'tc3', 'tc4',
           'tcr1', 'tcr2', 'tcr3', 'tcr4', 'thr1', 'thr2', 'nb'}

_SPACE_RE = re.compile(r'[ \t\r\n]+')
# ASCII spaces between two non-ASCII characters (CJK line joins).
_CJK_SPACE_RE = re.compile(r'(?<=[^\x00-\x7f]) +(?=[^\x00-\x7f])')


def _clean(text, cjk):
    text = _SPACE_RE.sub(' ', text)
    if cjk:
        text = _CJK_SPACE_RE.sub('', text)
    return text


def _strip_inline(text):
    text = _NOTE_RE.sub('', text)
    text = _DROP_RE.sub('', text)
    # Nested \+w inside \nd etc.: unwrap words before the divine name.
    for _ in range(2):
        text = _WORD_RE.sub(lambda m: m.group(2), text)
    text = _ND_RE.sub(lambda m: m.group(1).upper(), text)
    text = _CHAR_RE.sub('', text)
    return text


def parse_book(usfm, cjk):
    """Returns (USFM code, display name, chapters) for one book file."""
    text = _strip_inline(usfm.replace('\ufeff', ''))
    tokens = _MARKER_RE.split(text)
    # tokens: [lead, marker, content, marker, content, ...]
    code = None
    name = None
    toc2 = None
    chapters = []
    chapter = None
    verse = None  # the verse list entry being filled
    pending_para = False
    pending_line = False
    pending_headings = []

    def start_verse(spec, rest):
        nonlocal verse, pending_para, pending_line
        m = re.match(r'(\d+)\w?(?:\s*[-\u2013]\s*(\d+)\w?)?', spec)
        if not m or chapter is None:
            return
        first = int(m.group(1))
        last = int(m.group(2)) if m.group(2) else None
        verse = [first, ''] + ([last] if last and last != first else [])
        chapter['v'].append(verse)
        for heading in pending_headings:
            chapter['h'].append([first] + heading)
        pending_headings.clear()
        if pending_para or len(chapter['v']) == 1:
            chapter['p'].append(first)
        elif pending_line:
            chapter['l'].append(first)
        pending_para = pending_line = False
        verse[1] += rest

    for i in range(1, len(tokens), 2):
        marker = tokens[i]
        content = tokens[i + 1]
        if marker == 'id':
            code = content.split()[0].upper() if content.split() else None
        elif marker == 'h':
            name = _clean(content, cjk).strip()
        elif marker == 'toc2':
            toc2 = _clean(content, cjk).strip()
        elif marker == 'c':
            parts = content.strip().split(None, 1)
            if not parts:
                continue
            chapter = {'c': int(re.match(r'\d+', parts[0]).group()),
                       'v': [], 'h': [], 'p': [], 'l': []}
            chapters.append(chapter)
            verse = None
            pending_para = True
            pending_line = False
            pending_headings.clear()
        elif chapter is None:
            continue  # book title / introduction before chapter 1
        elif marker == 'v':
            parts = content.split(None, 1)
            if parts:
                start_verse(parts[0], parts[1] if len(parts) > 1 else '')
        elif marker in _HEADING:
            heading = _clean(content, cjk).strip()
            if heading:
                pending_headings.append([heading])
                verse = None
                pending_para = True
        elif marker == 'd':
            heading = _clean(content, cjk).strip()
            if heading:
                pending_headings.append([heading, 1])
                pending_para = True
        elif marker in ('b', 'ib'):
            pending_para = True
            if verse is not None and content.strip():
                verse[1] += '\n' + content
        elif marker in _PARA or marker in _LINE:
            if content.strip() and verse is not None and verse[1].strip():
                # A new line (or paragraph) inside the current verse.
                verse[1] = verse[1].rstrip() + '\n' + content
            else:
                # The next \v starts the line / paragraph.
                if marker in _LINE:
                    pending_line = True
                else:
                    pending_para = True
                if verse is not None:
                    verse[1] += content
        elif marker in _INLINE:
            if verse is not None:
                verse[1] += ' ' + content
        elif marker.startswith('i') or marker in (
                'mt', 'mt1', 'mt2', 'mt3', 'mt4', 'mr', 'sr', 'r', 'cl', 'cp',
                'cd', 'ide', 'rem', 'toc1', 'toc3', 'sts', 'periph', 'restore',
                'usfm', 'ref', 'toca1', 'toca2', 'toca3'):
            continue  # titles, introductions, parallel references, labels
        elif marker.endswith('*'):
            if verse is not None:
                verse[1] += content
        else:
            if verse is not None:
                verse[1] += content

    for ch in chapters:
        for v in ch['v']:
            lines = [_clean(line, cjk).strip() for line in v[1].split('\n')]
            v[1] = '\n'.join(line for line in lines if line)
        ch['v'] = [v for v in ch['v'] if v[1]]
        kept = {v[0] for v in ch['v']}
        ch['p'] = sorted(set(n for n in ch['p'] if n in kept))
        ch['l'] = sorted(set(n for n in ch['l'] if n in kept) - set(ch['p']))
        for key in ('h', 'p', 'l'):
            if not ch[key]:
                del ch[key]
    chapters = [ch for ch in chapters if ch['v']]
    # \toc2 is the short name in normal case (some \h lines are capitals).
    return code, toc2 or name or code, chapters


def fetch(ebible_id):
    os.makedirs(CACHE_DIR, exist_ok=True)
    path = os.path.join(CACHE_DIR, f'{ebible_id}_usfm.zip')
    if not os.path.exists(path):
        url = f'https://ebible.org/Scriptures/{ebible_id}_usfm.zip'
        print(f'  downloading {url}')
        req = urllib.request.Request(url, headers={'User-Agent': 'homiletics-build'})
        with urllib.request.urlopen(req, timeout=120) as resp:
            data = resp.read()
        with open(path + '.part', 'wb') as f:
            f.write(data)
        os.replace(path + '.part', path)
    with open(path, 'rb') as f:
        return f.read()


def build(code, info):
    print(f'{code} <- {info["ebible"]}')
    cjk = info['language'] == 'zh'
    archive = zipfile.ZipFile(io.BytesIO(fetch(info['ebible'])))
    books = {}
    for entry in archive.namelist():
        if not entry.lower().endswith(('.usfm', '.sfm')):
            continue
        usfm = archive.read(entry).decode('utf-8-sig')
        book, name, chapters = parse_book(usfm, cjk)
        if book in BOOK_INDEX and chapters:
            books[book] = (name, chapters)
    out_books = []
    verses = 0
    for usfm_code, osis, english in BOOKS:
        if usfm_code not in books:
            print(f'  ! missing {english}')
            continue
        name, chapters = books[usfm_code]
        verses += sum(len(ch['v']) for ch in chapters)
        out_books.append({'id': usfm_code, 'osis': osis, 'name': name,
                          'chapters': chapters})
    doc = {
        'format': 1,
        'code': code,
        'name': info['name'],
        'short': info['short'],
        'language': info['language'],
        'license': info['license'],
        'copyright': info['copyright'],
        'source': f'https://ebible.org/{info["ebible"]}/',
        'books': out_books,
    }
    raw = json.dumps(doc, ensure_ascii=False, separators=(',', ':')).encode('utf-8')
    os.makedirs(OUT_DIR, exist_ok=True)
    out = os.path.join(OUT_DIR, f'{code}.json.gz')
    # mtime=0 keeps rebuilds of unchanged text byte-identical.
    with open(out, 'wb') as f:
        with gzip.GzipFile(fileobj=f, mode='wb', compresslevel=9, mtime=0) as gz:
            gz.write(raw)
    size = os.path.getsize(out)
    print(f'  {len(out_books)} books, {verses} verses, '
          f'{len(raw) / 1e6:.1f} MB json, {size / 1e6:.2f} MB gz -> {out}')
    return size


def main(argv):
    codes = argv or list(TEXTS)
    unknown = [c for c in codes if c not in TEXTS]
    if unknown:
        sys.exit(f'Unknown translation code(s): {", ".join(unknown)}')
    sizes = {code: build(code, TEXTS[code]) for code in codes}
    print('\nDownload sizes (bytes) for Translation.offlineBytes:')
    for code, size in sizes.items():
        print(f'  {code}: {size}')


if __name__ == '__main__':
    main(sys.argv[1:])
