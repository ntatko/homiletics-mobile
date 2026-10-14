# Translations

The interface text lives in `lib/l10n/app_<locale>.arb`. `app_en.arb` is the
source: every key has an `@key` description telling translators where the
string appears and what the homiletic terms mean. Run `flutter gen-l10n`
after editing (it also runs on `flutter run`/`build`).
`test/l10n_completeness_test.dart` fails if a language is missing a string or
drops a placeholder.

All non-English translations are machine-drafted best efforts. Users can
report wording problems from **Help → Feedback → Translation issue**; those
reports arrive titled `[Translation issue] …` and include the app language
and Bible translation codes. The lists below are the choices the drafts were
least sure about — check reports against them first.

| Locale | File | Register |
|---|---|---|
| Spanish | `app_es.arb` | Neutral Latin-American, "tú" |
| Chinese (Simplified) | `app_zh.arb` + `app_zh_Hans.arb` (keep identical) | Mainland, 和合本 vocabulary |
| Chinese (Traditional) | `app_zh_Hant.arb` | Taiwan, 和合本 vocabulary |
| French | `app_fr.arb` | International / Francophone Africa, "vous" |
| Portuguese | `app_pt.arb` | Neutral Brazil + Lusophone Africa |
| Swahili | `app_sw.arb` | Standard Kiswahili (Kenya/Tanzania) |

`appTitle` stays "Homiletics" everywhere (brand). "FCF" is kept as an
abbreviation with a local gloss.

## Glossary

| English | Español | 简体 | 繁體 | Français | Português | Kiswahili |
|---|---|---|---|---|---|---|
| Homiletics (the study) | Homilética | 讲道大纲 | 講道大綱 | Homilétique | Homilética | Homiletiki |
| Content | Contenido | 内容摘要 | 內容摘要 | Contenu | Conteúdo | Maudhui |
| Divisions | Divisiones | 段落划分 | 段落劃分 | Divisions | Divisões | Migawanyo |
| Summary sentence | Frase resumen | 总结句 | 摘要句 | Phrase de résumé | Frase-resumo | Sentensi ya muhtasari |
| FCF gloss | Enfoque en la condición caída | 堕落景况焦点 | 墮落景況焦點 | Focus sur la condition déchue | Foco na Condição Caída | Kiini cha Hali ya Kuanguka |
| Aim | Objetivo | 目标 | 目標 | Objectif | Objetivo | Lengo |
| Application | Aplicación | 应用 | 應用 | Application | Aplicação | Matumizi |
| Passage / verse | Pasaje / versículo | 经文 / 经节 | 經文 / 經節 | Passage / verset | Passagem / versículo | Kifungu / mstari |
| Lecture | Conferencia | 讲课 | 講課 | Exposé | Palestra | Hotuba |
| Word study | Estudio de palabra | 字词研究 | 字詞研究 | Étude de mot | Estudo de palavra | Uchunguzi wa neno |

## Watch list

### All languages
- **FCF hint** ("Fallen/Frail/Feeble/Fickle") — translated for meaning; the
  F-alliteration is lost (French keeps it partly).
- **Summary-sentence limit** — Chinese says 20 characters instead of 10 words
  (no word spaces); others keep 10 words.
- **Short labels over their length limit** — es `stepShortContent`,
  `feedbackTypeTranslation`, `homeAllStudies`; fr `stepShortApplication`,
  `homileticApplicationHint`; sw `stepShortSummary`, `lectureTimeMark`.
  Check these don't truncate on small phones.
- **`editorDeleteConfirmMessage` + item names** — gendered languages put the
  article/demonstrative inside each item name (es "esta lección…",
  fr "cette {itemName}" with all-feminine names, sw avoids "this"). If an
  item name is ever reused elsewhere, revisit.

### Español
- "Conferencia" for lecture — confirm against BSF Spanish materials.
- Word-study tile letter "P" (Palabra) rather than "E".
- `startWordStudy` = "Palabra" (short for a three-button row).
- `commonOk` = "Aceptar".

### 中文 (简体 / 繁體)
- **讲道大纲 / 講道大綱** for "Homiletics" (~20 strings) — the biggest
  judgement call; BSF Chinese materials may use another term
  (讲道学, 讲章…).
- FCF gloss 堕落景况焦点 — alternatives 堕落光景焦点 / 堕落状态焦点.
- 讲课 for lecture — groups may say 讲道 or 讲座.
- `homeLivingItOut` = 活出真道 (idiomatic).
- Alliteration in the summary help text became 押韵或对仗.
- 简体 uses 总结句, 繁體 uses 摘要句 for "Summary sentence" — both
  natural; unify if users ask.

### Français
- "Exposé" for lecture — alternatives "Conférence", "Enseignement".
- `feedbackTypeTranslation` = "Traduction fautive" (fits the limit;
  "Problème de traduction" is more natural but long).
- `startCreateNew` / `startEditExisting` are feminine; slightly off for
  lecture notes.
- `homeEarlier` = "Précédemment" (alt. "Semaines passées").

### Português
- Written to work in Brazil and Lusophone Africa: avoids "tu"/"você",
  gerunds, and country-specific words (tela/ecrã, arquivo/ficheiro,
  baixar/descarregar).
- "Compartilhar" (Brazil) vs "Partilhar" (Portugal/Africa).
- "Guardar" for save (Brazilians may expect "Salvar").
- "Configurações" for settings ("Definições" would clash with Definição).
- "Download" loanword for model downloads.
- "Palestra" for lecture.
- "Meus estudos" / "Minhas notas" without article (Brazilian style).

### Kiswahili
- "Hotuba" for lecture; "Ghafi" for the raw transcript (technical).
- Word-study tile letter "N" (Neno); `startWordStudy` = "Chunguza neno".
- `homeEarlier` = "Awali", `homeComingUp` = "Inakuja".
- Relative times ("siku 3 zilizopita") are hand-written in
  `lib/common/relative_time.dart` (timeago has no Swahili).

## Adding or changing a string
1. Add/edit it in `app_en.arb` with an `@key` description.
2. Add the translation to every other `app_*.arb` (keep `app_zh.arb` and
   `app_zh_Hans.arb` identical). The completeness test lists what's missing.
3. `flutter gen-l10n`.

## Weekly passages feed
`data/suggested-passages.json` (served from GitHub `main`) carries
translated display fields alongside the English ones: a top-level
`studies` map of study names, and per-week `lesson_i18n` and
`passage_i18n`. Write new weeks in English only, then run
`python3 tool/localize_suggested_passages.py` to fill these in — it
refuses to guess unknown book names or studies, so add a row to its
`BOOKS` / `STUDIES` tables when it asks. The English `passage` is what's
sent to Bible Gateway and matched against saved studies, so it always
stays an English reference. `test/suggested_passages_test.dart` fails if
a week is missing a translation. Older app versions ignore the new fields.
