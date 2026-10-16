"""Should this message skip the model and get the helplines? Two layers:

1. safety.CRISIS: the phrase list (exact wording; denials like "I'm not suicidal" are left out).
2. Meaning match: a small embedding model (BAAI/bge-small-en-v1.5, MIT) turns the message into a vector and compares
   it with the reviewed examples in golden/crisis.csv. If its closest example says "helplines" and it is similar
   enough, it gets the helplines. This catches rewordings no phrase list predicts ("life isn't worth living").

THRESHOLD was tuned leave-one-out on golden/crisis.csv only. golden/crisis-holdout.csv is never used for tuning;
its score (python test_crisis_golden.py golden/crisis-holdout.csv) is the honest one. Nothing leaves the server.
"""
import csv

import torch
from transformers import AutoModel, AutoTokenizer

from safety import ANY_CRISIS_PHRASE, CRISIS

EMBED_DIR = "models/crisis-embed"
EXAMPLES = "golden/crisis.csv"
THRESHOLD = 0.74  # tuned leave-one-out on golden/crisis.csv: 102/107 caught by meaning alone, 8/49 hard false alarms
MARGIN = 0.02     # the closest helplines example must beat the closest chat example by this much

tokenizer = AutoTokenizer.from_pretrained(EMBED_DIR)
model = AutoModel.from_pretrained(EMBED_DIR).eval()


def embed(texts):
    """Unit-length sentence vectors (bge uses the first token's output), so a dot product is cosine similarity."""
    with torch.no_grad():
        batch = tokenizer(texts, padding=True, truncation=True, max_length=128, return_tensors="pt")
        first = model(**batch).last_hidden_state[:, 0]
    return torch.nn.functional.normalize(first, dim=-1)


with open(EXAMPLES, newline="") as f:
    rows = list(csv.DictReader(f))
example_vectors = embed([r["text"] for r in rows])
needs_help = torch.tensor([r["expected"] == "helplines" for r in rows])


def closest(text):
    """(similarity to the closest helplines example, similarity to the closest chat example)"""
    sims = example_vectors @ embed([text])[0]
    return sims[needs_help].max().item(), sims[~needs_help].max().item()


def is_crisis(text):
    if CRISIS.search(text):
        return True
    # A denied phrase ("I'm not suicidal") is removed before matching meaning, because a denial sits close to what
    # it denies. The rest still counts: "I would never hurt myself, but life isn't worth living" is caught.
    help_sim, chat_sim = closest(ANY_CRISIS_PHRASE.sub(" ", text))
    return help_sim >= THRESHOLD and help_sim >= chat_sim + MARGIN
