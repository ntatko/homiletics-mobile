#!/usr/bin/env python3
"""Merges lib/l10n/src/*_<locale>.arb fragments into lib/l10n/app_<locale>.arb.

Fragments let several people extract strings at once without editing the
same file. Keys must be unique across fragments (prefix them by area).
Run from the project root, then `flutter gen-l10n`.
"""
import glob, json, os, re, sys
from collections import OrderedDict

frags = sorted(glob.glob('lib/l10n/src/*_*.arb'))
by_locale = {}
for path in frags:
    m = re.match(r'.*/[a-z0-9]+_([A-Za-z_]+)\.arb$', path)
    if not m:
        continue
    locale = m.group(1)
    with open(path, encoding='utf-8') as f:
        data = json.load(f, object_pairs_hook=OrderedDict)
    merged = by_locale.setdefault(locale, OrderedDict([('@@locale', locale)]))
    for k, v in data.items():
        if k == '@@locale':
            continue
        if k in merged and merged[k] != v:
            sys.exit(f'duplicate key {k} in {path}')
        merged[k] = v
for locale, data in by_locale.items():
    with open(f'lib/l10n/app_{locale}.arb', 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write('\n')
    print(f'app_{locale}.arb: {sum(1 for k in data if not k.startswith("@"))} strings')
