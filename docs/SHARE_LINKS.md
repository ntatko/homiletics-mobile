# Share links (format v1)

A share link carries a whole study in the URL fragment, so the website never
receives it (browsers don't send `#…` to servers) and no backend is needed.

    https://homiletics.app/view#h=<payload>   homiletic
    https://homiletics.app/view#w=<payload>   word study
    homiletics://view#h=<payload>             same, custom scheme (fallback "Open in app")

`<payload>` = base64url (RFC 4648 §5, **no padding**) of the **raw DEFLATE**
(RFC 1951, no zlib/gzip header) compression of the UTF-8 JSON envelope:

    {"v":1,"t":"h","d":{…}}      // v: format version, t: "h" | "w"

Homiletic `d` (omit empty fields; arrays keep order):

| key | meaning |
|---|---|
| `p`  | passage reference (string) |
| `c`  | content summaries: `[[verses, summary], …]` |
| `dv` | divisions: `[[verses, sentence], …]` |
| `s`  | summary sentence |
| `f`  | FCF |
| `a`  | aim (text after "Cause the audience to learn that") |
| `ap` | application questions: `[question, …]` |
| `tr` | sharer's Bible translation code (optional hint, e.g. "niv") |
| `u`  | last updated, ISO 8601 UTC (optional) |

Word study `d`: `p` passage, `wd` word, `df` definition, `ou` other usage
(newline-separated), `cm` contextual meaning, `dm` deeper meaning,
`ap` application (string), `tr`, `u` as above.

Rules
- Readers must ignore unknown keys and reject `v` greater than they support
  with a friendly "update the app" message.
- Strings are plain text (no HTML/Markdown); renderers must escape them.
- Decoders must cap the decompressed size (256 KB) and reject anything that
  isn't the expected shape.
- Encoders should keep links under ~8 000 characters; if longer, warn that
  some apps may truncate it.
- Importing always creates a **new copy**; it never overwrites existing data.

Test vectors: `share_link_vectors.json` — each has the input envelope and the
expected link; implementations must decode every link to the given envelope
(encoders may produce different but equivalent compressed bytes, so test
encode→decode round-trips, not byte equality).
