# Run: python test_safety.py
from safety import CRISIS, FALLBACK_REPLY, clean_response, safe_reply

advice = "It is common to feel this way. Try writing down your worries before bed. A therapist can help you sort through them."
assert clean_response(advice) == advice

promo = advice + " I offer free phone consultations.Feel free to contact me at www.example.com."
assert clean_response(promo) == advice  # also splits "consultations.Feel" with no space

signed = advice + " Jane Doe, LPC, NCC"
assert clean_response(signed) == advice

mostly_ad = "Call me at 555-123-4567. Visit my website. My clients love it. Sleep matters."
assert clean_response(mostly_ad) is None  # too little left

# Real replies from the 0.5B model (2026-10-03 test).
doctors = ("I'm sorry to hear of your struggle with depression. I would encourage you to seek out counseling "
           "from one of these therapists:  Dr. John Gottman  Dr. Robin Cai  Dr. Joseph Poggi")
assert safe_reply(doctors) == "I'm sorry to hear of your struggle with depression."
invented = advice + " Also, some online sites such as Betterment offer therapists by location, so you may want to look."
assert safe_reply(invented) == advice
assert safe_reply("I offer free phone consultations and I would love to talk with you.") == FALLBACK_REPLY
assert safe_reply(advice) == advice
# Crisis check: every form of the verbs, and indirect phrasings. These skip the model and get helplines.
crisis = [
    "I want to kill myself", "I keep cutting myself when it gets bad", "I've been hurting myself again",
    "I thought about killing myself", "I want to end my life", "I'm thinking of ending it all",
    "I took my own life in my dreams", "I just want to die", "I don't want to be alive anymore",
    "I don’t want to live", "I do not want to wake up tomorrow", "Everyone would be better off without me",
    "they'd be better off dead", "there's no reason to live", "I have nothing left to live for",
    "I want to overdose", "I've been self harming", "suicidal thoughts again", "I starved myself all week",
]
for m in crisis:
    assert CRISIS.search(m), m
# Everyday sentences must still reach the chat.
everyday = [
    "This exam is killing me", "I'm dying to see that film", "I could kill for a coffee",
    "My back hurts", "I cut my hair short", "I want to live a calmer life", "I don't want to go to work",
    "I'm better off on my own for a while", "That joke killed me",
]
for m in everyday:
    assert not CRISIS.search(m), m
print("safety ok")
