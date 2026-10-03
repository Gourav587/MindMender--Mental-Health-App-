# Run: python test_train_chat.py
from train_chat import clean_response

advice = "It is common to feel this way. Try writing down your worries before bed. A therapist can help you sort through them."
assert clean_response(advice) == advice

promo = advice + " I offer free phone consultations.Feel free to contact me at www.example.com."
assert clean_response(promo) == advice  # also splits "consultations.Feel" with no space

signed = advice + " Jane Doe, LPC, NCC"
assert clean_response(signed) == advice

mostly_ad = "Call me at 555-123-4567. Visit my website. My clients love it. Sleep matters."
assert clean_response(mostly_ad) is None  # too little left
print("clean_response ok")
