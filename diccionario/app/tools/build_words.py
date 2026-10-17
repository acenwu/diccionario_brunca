#!/usr/bin/env python3
"""Compile the hand-transcribed dictionary into the app's seed files.

    python3 tools/build_words.py            # validate + write assets/data/*
    python3 tools/build_words.py --check    # validate only, write nothing
    python3 tools/build_words.py --strict   # also fail while any entry is
                                            # still flagged "needs_review"

Input : tools/words_src.json   (edit this one, by hand)
Output: assets/data/words.json     (what the app loads; never edit by hand)
        assets/data/words.version  (content hash; the app re-syncs its
                                    database when this changes)

TYPING SHORTCUTS (Boruca fields only: brunca, variants, example and phrase
Boruca text). Nobody has the glottal-stop letter on their keyboard, so:

    v    ->  ᵛ   (U+1D5B, glottal stop). Plain v is not a Boruca letter, so
                 every v in a Boruca field is the glottal stop.
    n:   ->  n̈   (n + U+0308 combining diaeresis, the velar nasal)
    ñ        type it directly (palatal nasal, a different phoneme from n̈)
    á é í ó ú  type them directly (high tone; low tone is unmarked)

Spanish fields (senses, translations, notes) are plain text: no shortcuts.

Everything is normalized to NFC (NOT NFKC: NFKC would turn ᵛ back into v).
Any character outside the orthography whitelist below is reported with its
Unicode code point instead of being silently accepted. That catches wrong
glyphs from copy-paste (Cyrillic look-alikes, stray combining marks, curly
quotes where a letter should be) before they reach the app.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_SRC = ROOT / "tools" / "words_src.json"
DEFAULT_OUT = ROOT / "assets" / "data"

GLOTTAL = "\u1d5b"    # ᵛ MODIFIER LETTER SMALL V
DIAERESIS = "\u0308"  # combining diaeresis; n + this = n̈

# Abbreviation legend from the dictionary's front matter, plus "art.", which
# the entries use but the legend page we have does not list (assumed).
POS_LABELS = {
    "adj.": "adjetivo",
    "adj. pos.": "adjetivo posesivo",
    "adv.": "adverbio",
    "art.": "artículo",
    "hidr.": "hidrónimo (nombre de río)",
    "id.": "ideófono",
    "loc.": "locución",
    "loc. adv.": "locución adverbial",
    "loc. posp.": "locución posposicional",
    "n. pr.": "nombre propio",
    "posp.": "posposición",
    "pron.": "pronombre",
    "pron. pers.": "pronombre personal",
    "sust.": "sustantivo",
    "topo.": "topónimo (nombre de lugar)",
    "v.": "verbo",
}

# Letters that appear in the Boruca orthography (phonology table, p. 14, plus
# n, which the table pages we have don't show but entries clearly use).
# p only exists as the written form of /b/ before voiceless consonants, and
# q only occurs in "qu"; neither is checked positionally.
# Deliberately absent: k, f, l, w, z. If one turns out to be real, add it to
# EXTRA_ALLOWED below.
BASE_LETTERS = set("abcdeghijmnoprstuxy")
TONED_VOWELS = set("áéíóú")
# If a letter turns out to be genuine Boruca orthography, add it here rather
# than loosening the checks elsewhere.
EXTRA_ALLOWED: set[str] = set()

_letters = BASE_LETTERS | {"ñ"} | TONED_VOWELS | EXTRA_ALLOWED
BRUNCA_LETTERS = _letters | {c.upper() for c in _letters}
HEADWORD_PUNCT = set(" -'’")
SENTENCE_PUNCT = HEADWORD_PUNCT | set(".,;?!¿¡«»\"()")

SPANISH_EXTRA = set("áéíóúüñÁÉÍÓÚÜÑ¿¡«»–—…’“”°")

ALLOWED_KEYS = {
    "id", "brunca", "variants", "homograph", "pos", "senses", "literal",
    "examples", "phrases", "note", "category", "audioFile",
    # source-only bookkeeping, never written to the app's data:
    "source_page", "needs_review", "review_note",
}
SOURCE_ONLY_KEYS = {"source_page", "needs_review", "review_note"}

ID_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")


# ---------------------------------------------------------------------------
# Text handling
# ---------------------------------------------------------------------------

def to_boruca(text: str) -> str:
    """Apply the typing shortcuts and normalize to NFC."""
    text = unicodedata.normalize("NFC", text)
    text = re.sub(r"([nN]):", lambda m: m.group(1) + DIAERESIS, text)
    text = text.replace("v", GLOTTAL)
    return unicodedata.normalize("NFC", text)


def clean_spanish(text: str) -> str:
    text = unicodedata.normalize("NFC", text)
    return re.sub(r"\s+", " ", text).strip()


def clean_boruca(text: str) -> str:
    return re.sub(r"\s+", " ", to_boruca(text)).strip()


def describe(ch: str) -> str:
    name = unicodedata.name(ch, "UNNAMED CHARACTER")
    shown = "" if unicodedata.category(ch).startswith("M") else f" '{ch}'"
    return f"U+{ord(ch):04X} {name}{shown}"


def boruca_problems(text: str, sentence: bool) -> list[str]:
    allowed = BRUNCA_LETTERS | {GLOTTAL} | (
        SENTENCE_PUNCT if sentence else HEADWORD_PUNCT
    )
    problems = []
    prev = ""
    for ch in text:
        if ch == DIAERESIS:
            if prev not in ("n", "N"):
                problems.append(
                    "combining diaeresis (U+0308) after "
                    f"{describe(prev) if prev else 'nothing'}; it is only valid "
                    "on n (type n: for n̈)"
                )
        elif ch in allowed:
            pass
        elif ch == "V":
            problems.append(
                "uppercase V: the glottal stop has no capital form; type a "
                "lowercase v"
            )
        elif ch == ":":
            problems.append("':' is only valid as the n: shortcut for n̈")
        elif ch.lower() in "kfwzl":
            problems.append(
                f"{describe(ch)} is not in the phonology table; if it is real "
                "Boruca orthography, add it to EXTRA_ALLOWED"
            )
        else:
            problems.append(f"unexpected character {describe(ch)}")
        prev = ch
    if text and not any(c.isalpha() or c == GLOTTAL for c in text):
        problems.append("contains no letters")
    return problems


def spanish_problems(text: str) -> list[str]:
    problems = []
    for ch in text:
        if not (0x20 <= ord(ch) <= 0x7E or ch in SPANISH_EXTRA):
            problems.append(f"unexpected character {describe(ch)}")
    return problems


def suggest_id(brunca: str) -> str:
    s = unicodedata.normalize("NFD", to_boruca(brunca).lower())
    s = s.replace(GLOTTAL, "v")
    s = "".join(c for c in s if not unicodedata.category(c).startswith("M"))
    s = re.sub(r"[^a-z0-9]+", "-", s).strip("-")
    return s or "entry"


# ---------------------------------------------------------------------------
# Validation / compilation
# ---------------------------------------------------------------------------

class Report:
    def __init__(self) -> None:
        self.errors: list[str] = []
        self.review: list[tuple[str, str]] = []

    def error(self, ctx: str, field: str, msg: str) -> None:
        self.errors.append(f"{ctx}: {field}: {msg}")


def _text_field(rep, ctx, field, value, *, boruca, sentence=False,
                required=False):
    """Validate + clean one string. Returns the cleaned string or None."""
    if value is None:
        if required:
            rep.error(ctx, field, "required")
        return None
    if not isinstance(value, str):
        rep.error(ctx, field, f"expected text, got {type(value).__name__}")
        return None
    cleaned = clean_boruca(value) if boruca else clean_spanish(value)
    if not cleaned:
        if required:
            rep.error(ctx, field, "must not be empty")
        return None
    problems = (boruca_problems(cleaned, sentence) if boruca
                else spanish_problems(cleaned))
    for p in problems:
        rep.error(ctx, field, f"{p}  [in {cleaned!r}]")
    return cleaned


def _str_list(rep, ctx, field, value, *, boruca, required=False):
    if value is None:
        if required:
            rep.error(ctx, field, "required")
        return []
    if not isinstance(value, list):
        rep.error(ctx, field, "expected a list")
        return []
    out = []
    for i, item in enumerate(value):
        cleaned = _text_field(rep, ctx, f"{field}[{i}]", item, boruca=boruca,
                              required=True)
        if cleaned:
            out.append(cleaned)
    if required and not out:
        rep.error(ctx, field, "needs at least one item")
    return out


def _pair_list(rep, ctx, field, value, *, with_literal):
    if value is None:
        return []
    if not isinstance(value, list):
        rep.error(ctx, field, "expected a list")
        return []
    out = []
    keys = {"brunca", "spanish"} | ({"literal"} if with_literal else set())
    for i, item in enumerate(value):
        where = f"{field}[{i}]"
        if not isinstance(item, dict):
            rep.error(ctx, where, "expected an object")
            continue
        for k in item:
            if k not in keys:
                rep.error(ctx, where, f"unknown key {k!r}")
        entry = {
            "brunca": _text_field(rep, ctx, f"{where}.brunca", item.get("brunca"),
                                  boruca=True, sentence=not with_literal,
                                  required=True),
            "spanish": _text_field(rep, ctx, f"{where}.spanish",
                                   item.get("spanish"), boruca=False,
                                   required=True),
        }
        if with_literal:
            lit = _text_field(rep, ctx, f"{where}.literal", item.get("literal"),
                              boruca=False)
            if lit:
                entry["literal"] = lit
        if entry["brunca"] and entry["spanish"]:
            out.append(entry)
    return out


def compile_entry(index: int, raw, rep: Report):
    if not isinstance(raw, dict):
        rep.errors.append(f"entry #{index}: expected an object")
        return None
    rid = raw.get("id") if isinstance(raw.get("id"), str) else None
    ctx = f"entry #{index}" + (f" (id={rid})" if rid else "")

    for k in raw:
        if k not in ALLOWED_KEYS:
            rep.error(ctx, k, "unknown key (typo?)")

    brunca = _text_field(rep, ctx, "brunca", raw.get("brunca"), boruca=True,
                         required=True)

    if not rid:
        hint = f' (suggestion: "{suggest_id(raw["brunca"])}")' if isinstance(
            raw.get("brunca"), str) else ""
        rep.error(ctx, "id", f"required{hint}")
    elif not ID_RE.match(rid):
        rep.error(ctx, "id", "use lowercase a-z, 0-9 and single hyphens only")

    variants = _str_list(rep, ctx, "variants", raw.get("variants"), boruca=True)
    senses = _str_list(rep, ctx, "senses", raw.get("senses"), boruca=False,
                       required=True)

    homograph = raw.get("homograph")
    if homograph is not None and not (
            isinstance(homograph, int) and not isinstance(homograph, bool)
            and homograph >= 1):
        rep.error(ctx, "homograph", "must be a whole number >= 1")
        homograph = None

    pos = raw.get("pos")
    if pos is not None and pos not in POS_LABELS:
        rep.error(ctx, "pos",
                  f"unknown abbreviation {pos!r}; known: "
                  + ", ".join(sorted(POS_LABELS)))
        pos = None

    out = {"id": rid, "brunca": brunca}
    if variants:
        out["variants"] = variants
    if homograph is not None:
        out["homograph"] = homograph
    if pos:
        out["pos"] = pos
        out["posLabel"] = POS_LABELS[pos]
    out["senses"] = senses
    for key, boruca in (("literal", False), ("note", False),
                        ("category", False), ("audioFile", False)):
        val = _text_field(rep, ctx, key, raw.get(key), boruca=boruca)
        if val:
            out[key] = val
    examples = _pair_list(rep, ctx, "examples", raw.get("examples"),
                          with_literal=False)
    phrases = _pair_list(rep, ctx, "phrases", raw.get("phrases"),
                         with_literal=True)
    if examples:
        out["examples"] = examples
    if phrases:
        out["phrases"] = phrases

    if raw.get("needs_review") is True:
        rep.review.append((rid or f"#{index}", raw.get("review_note") or ""))
    elif raw.get("needs_review") not in (None, False):
        rep.error(ctx, "needs_review", "must be true or false")

    return out


def compile_all(raw_entries, rep: Report):
    if not isinstance(raw_entries, list):
        rep.errors.append("source file must be a JSON list of entries")
        return []
    out = []
    for i, raw in enumerate(raw_entries):
        entry = compile_entry(i, raw, rep)
        if entry is not None:
            out.append(entry)

    seen_ids: dict[str, int] = {}
    seen_heads: dict[tuple, str] = {}
    for e in out:
        if e["id"] is None or e["brunca"] is None:
            continue  # already reported as a missing/invalid field
        if e["id"] in seen_ids:
            rep.errors.append(f"duplicate id {e['id']!r}")
        seen_ids[e["id"]] = 1
        key = (e["brunca"], e.get("homograph"))
        if key in seen_heads:
            rep.errors.append(
                f"entries {seen_heads[key]!r} and {e['id']!r} share the "
                f"headword {e['brunca']!r}"
                + ("" if key[1] is None else f" with homograph {key[1]}")
                + "; give them different homograph numbers"
            )
        else:
            seen_heads[key] = e["id"]
    return out


def serialize(entries) -> str:
    # One compact entry per line: small file, readable diffs.
    lines = [json.dumps(e, ensure_ascii=False, separators=(",", ":"))
             for e in entries]
    return "[\n" + ",\n".join(lines) + "\n]\n"


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--out", type=Path, default=DEFAULT_OUT,
                    help="directory for words.json and words.version")
    ap.add_argument("--check", action="store_true",
                    help="validate only; write nothing")
    ap.add_argument("--strict", action="store_true",
                    help="fail if any entry is still flagged needs_review")
    args = ap.parse_args(argv)

    try:
        # utf-8-sig tolerates a BOM added by Windows editors / Excel.
        raw = json.loads(args.src.read_text(encoding="utf-8-sig"))
    except FileNotFoundError:
        print(f"error: source file not found: {args.src}", file=sys.stderr)
        return 2
    except json.JSONDecodeError as exc:
        print(f"error: {args.src} is not valid JSON: {exc}", file=sys.stderr)
        return 2

    rep = Report()
    entries = compile_all(raw, rep)

    if rep.errors:
        print(f"{len(rep.errors)} problem(s) in {args.src}:\n", file=sys.stderr)
        for line in rep.errors:
            print(f"  - {line}", file=sys.stderr)
        print("\nNothing was written.", file=sys.stderr)
        return 1

    if rep.review:
        print(f"{len(rep.review)} entr{'y' if len(rep.review) == 1 else 'ies'} "
              "still flagged needs_review:")
        for rid, note in rep.review:
            print(f"  - {rid}" + (f": {note}" if note else ""))
        if args.strict:
            print("\n--strict: refusing to build with unreviewed entries.",
                  file=sys.stderr)
            return 1

    body = serialize(entries)
    version = hashlib.sha1(body.encode("utf-8")).hexdigest()[:12]

    if args.check:
        print(f"OK (check only): {len(entries)} entries, version {version}")
        return 0

    args.out.mkdir(parents=True, exist_ok=True)
    # newline="" so Windows doesn't rewrite \n as \r\n and change the hash.
    with open(args.out / "words.json", "w", encoding="utf-8", newline="") as f:
        f.write(body)
    with open(args.out / "words.version", "w", encoding="utf-8",
              newline="") as f:
        f.write(version + "\n")
    print(f"OK: {len(entries)} entries -> {args.out / 'words.json'} "
          f"(version {version})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
