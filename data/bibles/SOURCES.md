# Offline Bible texts

The `<code>.json.gz` files here are what the verse panel downloads on
demand and shows without a web view. They are built by
`python3 tool/build_bibles.py` from the eBible.org USFM downloads
(`https://ebible.org/Scriptures/<id>_usfm.zip`). The script keeps the 66
protocanonical books, the verse text, section headings, psalm titles and
paragraph/poetry breaks. It drops footnotes, cross references, Strong's
numbers and introductions. It makes no other change to the wording. The
divine name (`\nd`) is written in capitals, which is how it is printed in
small caps.

Only texts that are public domain, or under a licence that allows
redistribution, belong here. Check each one's copyright page before adding
it. The licence and copyright line travel inside each file (`license`,
`copyright`, `source`), and the app shows them under the passage.

| App code | Text | eBible id / source | Licence | Checked |
|---|---|---|---|---|
| `web` | World English Bible | `engwebp`: https://ebible.org/engwebp/copyright.htm | Public Domain ("World English Bible" is a trademark; the text is unchanged) | 2026-10-14 |
| `kjv` | King James Version (1769) | `eng-kjv2006`: https://ebible.org/eng-kjv2006/copyright.htm | Public Domain outside the UK. In the UK the Crown letters patent cover printing; this file is not distributed in print. | 2026-10-14 |
| `bbe` | Bible in Basic English (1965) | `engBBE`: https://ebible.org/engBBE/copyright.htm | Public Domain (published in the US without notice) | 2026-10-14 |
| `rv1909` | Reina-Valera 1909 | `spaRV1909`: https://ebible.org/spaRV1909/copyright.htm | Public Domain | 2026-10-14 |
| `lsg` | Louis Segond 1910 | `fraLSG`: https://ebible.org/fraLSG/copyright.htm | Public Domain | 2026-10-14 |
| `cuvmps` | 新标点和合本 (Chinese Union Version, simplified) | `cmn-cu89s`: https://ebible.org/cmn-cu89s/copyright.htm | eBible.org: Public Domain (see note) | 2026-10-14 |
| `cuvmpt` | 新標點和合本 (Chinese Union Version, traditional) | `cmn-cu89t`: https://ebible.org/cmn-cu89t/copyright.htm | eBible.org: Public Domain (see note) | 2026-10-14 |
| `ccb` | Biblica® Open Chinese Contemporary Bible (simplified) | `cmncbs`: https://ebible.org/cmncbs/copyright.htm | CC BY-SA 4.0, © 1979–2022 Biblica, Inc. | 2026-10-14 |
| `ccbt` | Biblica® Open Chinese Contemporary Bible (traditional) | `cmncbt`: https://ebible.org/cmncbt/copyright.htm | CC BY-SA 4.0, © 1979–2023 Biblica, Inc. | 2026-10-14 |
| `blivre` | Bíblia Livre (from Almeida 1819, Textus Receptus) | `porbr2018`: https://ebible.org/porbr2018/copyright.htm | CC BY 4.0 Brasil, © 2018 Diego Santos, Mario Sérgio, Marco Teles | 2026-10-14 |
| `snt` | Biblica® Open Kiswahili Contemporary Version (Neno: Bibilia Takatifu) | `swhonen`: https://ebible.org/swhonen/copyright.htm | CC BY-SA 4.0, © 1984–2015 Biblica, Inc. | 2026-10-14 |

## Notes

- **CC BY / CC BY-SA texts** (`ccb`, `ccbt`, `blivre`, `snt`). The
  attribution line in each file's `copyright` field is shown under every
  passage. Our conversion (markup removed, nothing reworded) is shared
  under the same licence as its source: CC BY-SA 4.0 for the Biblica texts
  and CC BY 4.0 BR for Bíblia Livre. The Biblica® trademark stays because
  the wording is unchanged, which is what Biblica's notice allows.
- **Chinese Union Version, New Punctuation** (`cuvmps`, `cuvmpt`). The 1919
  Union Version is public domain. eBible.org marks this punctuated edition
  "Public Domain" too, and that statement is what we rely on. Remove these
  two files if a rights holder disputes it.
- **The text may not match Bible Gateway exactly.** For codes that also
  open on Bible Gateway (`ccb`, `ccbt`, `snt`, `cuvmps`, `cuvmpt`, `lsg`,
  `kjv`, `web`, `bbe`), the eBible edition is the same translation, but its
  revision, punctuation or verse grouping can differ slightly. For example,
  the Biblica Open texts combine some verses ("1-2").
- **Not included:**
  - Reina-Valera 1960, NVI, the Almeida Revista e Corrigida (ARC 2009) and
    the 1952 Swahili Union Version: none are public domain, and eBible.org
    has no freely licensed copy.
  - `swh1850`: public domain, but New Testament only and incomplete.
  - Open English Bible: public domain, but only 17 Old Testament books.
  - Bíblia Portuguesa Mundial: public domain, but a draft under revision.
