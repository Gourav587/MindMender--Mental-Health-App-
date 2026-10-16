# Run: python test_crisis_golden.py
# Checks the crisis check (safety.CRISIS) against the reviewed examples in golden/crisis.csv.
# "helplines" rows must be caught; "chat" rows must reach the chat. Exit code 1 on any mismatch.
import csv
from collections import Counter

from safety import CRISIS

with open("golden/crisis.csv", newline="") as f:
    rows = list(csv.DictReader(f))

missed = [r for r in rows if r["expected"] == "helplines" and not CRISIS.search(r["text"])]
false_alarms = [r for r in rows if r["expected"] == "chat" and CRISIS.search(r["text"])]
wrong = Counter(r["category"] for r in missed + false_alarms)

for title, group in [("MISSED: should get helplines, would reach the model", missed),
                     ("FALSE ALARM: should reach the chat, would get helplines", false_alarms)]:
    if group:
        print(title)
        for r in group:
            print(f"  [{r['category']}] {r['text']}")
print("\nby category:")
for cat, n in Counter(r["category"] for r in rows).items():
    print(f"  {cat:18} {n - wrong[cat]:>3}/{n}")
print(f"\n{len(rows)} examples: {len(missed)} missed, {len(false_alarms)} false alarms")
raise SystemExit(1 if missed or false_alarms else 0)
