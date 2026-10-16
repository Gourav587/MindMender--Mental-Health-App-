"""Safety rules shared by the chat server (main.py) and training (train_chat.py)."""
import re

# The trained model saw this exact prompt during training, so main.py must send the same one.
SYSTEM_PROMPT = (
    "You are MindMender, a warm and supportive listener for mental health and stress. "
    "You are not a therapist: never diagnose or prescribe. Keep replies short and kind, "
    "and suggest a mental health professional for anything serious."
)

# Messages that skip the model and get helplines. Verbs match every form (cut, cuts, cutting); indirect phrasings
# with no crisis verb are listed as they are. ' or ’ because phones type curly apostrophes.
# ponytail: still a phrase list, so new phrasings slip through; a classifier or a bigger model is the real fix
CRISIS = re.compile("|".join([
    r"suicid", r"self[- ]?harm", r"overdos",
    r"\b(kill(s|ed|ing)?|hurt(s|ing)?|cut(s|ting)?|harm(s|ed|ing)?|hang(s|ed|ing)?|starv(e|es|ed|ing))\s+my\s?self\b",
    r"\b(end(s|ed|ing)?|tak(e|es|ing)|took)\s+my\s+(own\s+)?life\b", r"\bend(ing)?\s+it\s+all\b",
    r"\bwant(s|ed|ing)?\s+to\s+die\b", r"\bbetter\s+off\s+(dead|without\s+me)\b",
    r"\b(don['’]?t|do\s+not|no\s+longer)\s+want\s+to\s+(live|be\s+alive|exist|wake\s+up)\b",
    r"\bno\s+reason\s+to\s+live\b", r"\bnothing\s+(left\s+)?to\s+live\s+for\b",
]), re.I)
CRISIS_REPLY = (
    "I'm really sorry you're feeling this way. You deserve support right now, and talking to a person can help. "
    "Please reach out to a helpline: India: Tele-MANAS 14416 or KIRAN 1800-599-0019. US: call or text 988. "
    "Elsewhere: findahelpline.com. If you're in immediate danger, call your local emergency number."
)
FALLBACK_REPLY = (
    "I hear you, and I'm glad you shared this. Could you tell me a bit more about what's been going on? "
    "If it keeps weighing on you, a counsellor or doctor can help too."
)

# Sentences where a therapist advertises or speaks as a therapist ("contact me", "my clients", websites,
# phone numbers, credentials). The bot must never claim to be a therapist or offer sessions, and crisis
# numbers come from CRISIS_REPLY instead. Split also catches "sentence.Next" with no space after the period.
SENTENCE_SPLIT = re.compile(r"(?<!\bDr\.)(?<!\bMr\.)(?<!\bMs\.)(?<!\bMrs\.)(?<=[.!?])\s+|(?<=[a-z][.!?])(?=[A-Z])")
PROMO = re.compile("|".join([
    r"\b(contact|call|email|e-mail|text|reach|message|visit|find) me\b", r"\bfeel free to (contact|call|email|reach)",
    r"\b(see|work(ing)? with|session with|connect with|link to|follow up with) me\b", r"\bmany of us (offer|provide)\b",
    r"\bI (always |often )?(encourage|tell|ask|remind|teach) (my )?clients\b",
    r"\b(free|complimentary)\b.{0,20}\b(consultation|session)", r"\bconsultation with (me|our)\b",
    r"\bmy (office|practice|website|site|clinic|book|blog|services|number|phone|email|clients?|caseload|profile)\b",
    r"\bin my (practice|work|office|experience as)\b", r"\bclients? of mine\b", r"\bpeople we see\b",
    r"\bI (offer|provide|specialize|am a licensed|am licensed|work with|have worked with|have helped|treat)\b",
    r"\bas a (therapist|counselor|counsellor|clinician|psychologist|social worker|coach)\b",
    r"\b(our|my) (team|center|centre|group|agency|in-house|practice|office|clinic)\b",
    r"https?://|www\.|\b\w+\.(com|org|net|ca|co)\b", r"\(?\d{3}\)?[-. ]\d{3}[-. ]\d{4}", r"\b1-?800\b|\b800-", r"@\w+\.",
    r"\b(LMSW|LCSW|LPC|LPCC|LMFT|LMHC|LCPC|LICSW|LMAC|NCC|CADC|MFT|Ph\.?D|Psy\.?D|M\.?Ed|MSW)\b",
]), re.I)
# Named people and named services: a small model invents these ("see Dr. Robin Cai", "sites such as Betterment").
# Case-sensitive so only capitalised names match.
NAMED = re.compile(r"\bDr\.?\s+[A-Z][a-z]+|\b(sites?|websites?|apps?|platforms?|services?|programs?) (such as|like) [A-Z]")
MIN_KEPT = 0.6  # training: drop the whole answer if cleaning removed more than 40% of it


def _kept_sentences(text):
    return " ".join(s.strip() for s in SENTENCE_SPLIT.split(text) if s.strip() and not PROMO.search(s) and not NAMED.search(s))


def clean_response(text):
    """Training data: remove unsafe sentences; None if too little is left to be a good answer."""
    text = text.strip()
    kept = _kept_sentences(text)
    return kept if kept and len(kept) >= MIN_KEPT * len(text) else None


def safe_reply(text):
    """Chat replies: remove unsafe sentences; fall back to a gentle prompt if nothing useful is left."""
    kept = _kept_sentences(text.strip())
    return kept if len(kept) >= 40 else FALLBACK_REPLY
