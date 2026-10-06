# MindMender

A mental health website where you can:

- **Chat** with a supportive AI listener (our fine-tuned model, or Gemini + RAG over `separated_conversation.csv` as a fallback), with crisis detection and a safety filter on replies
- **Take self-checks**: depression (PHQ-9), anxiety (GAD-7), stress (PSS-10), and a 13-question social media check scored by attention, anxiety, self-esteem and low mood
- **Track your mood** with daily check-ins, a trend chart, and the WHO-5 wellbeing check
- **Relax** with box breathing, 5-4-3-2-1 grounding, and quick tips
- **Find answers** in the FAQ, Privacy Policy and Terms, or search the whole site (press `/`)

Every page has dark mode, a mobile menu, a "Get help" button with crisis helplines, and print styles for sharing results with a doctor.

Built with plain HTML/CSS/JS (`site/`), FastAPI (`main.py`), and Firebase Auth + Firestore for accounts and history.

> MindMender is not a substitute for professional care. In crisis: India Tele-MANAS **14416**, KIRAN **1800-599-0019**; US **988**; elsewhere [findahelpline.com](https://findahelpline.com).

## Run locally

```sh
cp .env.example .env   # put your Gemini key in GOOGLE_API_KEY
docker compose up --build
```

Then open http://localhost:8000. The first start takes a minute while it builds the embeddings.

Scoring self-check: `node site/scoring.test.js`

## Firebase setup

1. In the Firebase Console, enable the **Email/Password** and **Google** sign-in providers.
2. Add your deployed domain under Authentication → Settings → **Authorized domains**.
3. Deploy the security rules: `firebase deploy --only firestore:rules`.

## Train your own chat model

By default the chat uses Gemini with the Q&As in `separated_conversation.csv`. To use your own model instead, fine-tune a small Hugging Face model:

```sh
pip install -r requirements-train.txt
python train_chat.py --data separated_conversation.csv --data <hf-dataset-id-or-file> [--data ...]
```

- `--data` takes local `.csv`/`.json`/`.jsonl`/`.parquet` files or Hugging Face dataset ids, and can be repeated. Columns are detected for `separated_conversation.csv` (`human_prompt`/`assistant_output`), Counsel Chat (`questionText`/`answerText`) and `Amod/mental_health_counseling_conversations` (`Context`/`Response`); for other data pass `--prompt-col` and `--response-col`.
- The default base is `Qwen/Qwen2.5-0.5B-Instruct` (runs on an M-series Mac or a free Colab GPU). Use `--base Qwen/Qwen2.5-1.5B-Instruct` on a GPU for better replies.
- The model is saved to `models/chat/`. When that folder exists, `main.py` uses it for chat and no longer needs the Gemini key. Delete it to go back to Gemini.
- If you see a Keras/TensorFlow error, run with `USE_TF=0`.
