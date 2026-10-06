# Run: python test_safety.py
from safety import FALLBACK_REPLY, clean_response, safe_reply

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
print("safety ok")
