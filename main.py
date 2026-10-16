import time
from collections import defaultdict, deque

import google.auth.transport.requests
from fastapi import FastAPI, Header, HTTPException
from fastapi.staticfiles import StaticFiles
from google.oauth2 import id_token
from pydantic import BaseModel, Field
from transformers import pipeline

from crisis import is_crisis
from safety import CRISIS_REPLY, SYSTEM_PROMPT, safe_reply

FIREBASE_PROJECT = "mindmender-dea8d"
RATE_LIMIT = 20  # messages per user per minute
# ponytail: counts live in each instance's memory, so the real cap is RATE_LIMIT x instances; move to Firestore if that matters

generator = pipeline("text-generation", model="models/chat")  # written by train_chat.py
google_request = google.auth.transport.requests.Request()
recent = defaultdict(deque)  # uid -> times of their recent messages

app = FastAPI()


def user_id(authorization):
    """The Firebase login token the chat page sends -> that user's uid, or 401."""
    try:
        claims = id_token.verify_firebase_token(authorization.removeprefix("Bearer "), google_request, audience=FIREBASE_PROJECT)
        if claims["iss"] != f"https://securetoken.google.com/{FIREBASE_PROJECT}":
            raise ValueError("token from another project")
        return claims["sub"]
    except Exception:
        raise HTTPException(401, "Please log in again.")


def check_rate(uid):
    now = time.monotonic()
    times = recent[uid]
    while times and now - times[0] > 60:
        times.popleft()
    if len(times) >= RATE_LIMIT:
        raise HTTPException(429, "Too many messages. Try again in a minute.")
    times.append(now)


def answer(message):
    messages = [{"role": "system", "content": SYSTEM_PROMPT}, {"role": "user", "content": message}]
    # 180 tokens is about 700-800 characters: short, calm replies that stay fast on Cloud Run's CPU
    # use_cache: training saved the model with the KV cache off; without it each new word recomputes the whole chat (2.6x slower on CPU)
    out = generator(messages, max_new_tokens=180, do_sample=True, temperature=0.7, top_p=0.9, repetition_penalty=1.1, use_cache=True)
    return out[0]["generated_text"][-1]["content"].strip()


class ChatIn(BaseModel):
    message: str = Field(min_length=1, max_length=2000)


@app.get("/chat")
def wake():
    # The chat page calls this on load, so a sleeping server starts up while the person is still typing.
    return {"ready": True}


@app.post("/chat")
def chat(body: ChatIn, authorization: str = Header("")):
    # Crisis help comes first and never needs a login. It's cheap (phrase list + a small embedding, about 5 ms on CPU),
    # and --max-instances caps what a flood of logged-out requests could cost.
    if is_crisis(body.message):
        return {"reply": CRISIS_REPLY}
    check_rate(user_id(authorization))
    return {"reply": safe_reply(answer(body.message))}  # safety net: strip invented names, links, therapist claims


app.mount("/", StaticFiles(directory="site", html=True), name="site")  # local dev; online, Firebase Hosting serves site/
