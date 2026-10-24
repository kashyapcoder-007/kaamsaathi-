"""Cheap rule-based extraction (numbers, tools) — runs in microseconds.
The pretrained model handles the fuzzy part (which trade?); rules handle
the exact part (how many years, how many jobs)."""
import re

TOOLS = [
    (r"karni|trowel|करनी", "Trowel"),
    (r"level|लेवल", "Spirit level"),
    (r"brush|roller|ब्रश", "Brush & roller"),
    (r"drill|ड्रिल", "Drill"),
    (r"aari|saw|आरी", "Saw"),
    (r"phawda|phaowda|spade|फावड़ा", "Spade"),
]

def _num(pattern, text):
    m = re.search(pattern, text, re.I)
    return int(m.group(1)) if m else None

def extract_facts(text: str) -> dict:
    return {
        "years": _num(r"(\d+)\s*(?:saal|sal|year|years|साल)", text),
        "jobs": _num(r"(\d+)\s*(?:ghar|house|houses|jobs|kaam|काम|घर)", text),
        "tools": [name for pat, name in TOOLS if re.search(pat, text, re.I)],
    }
