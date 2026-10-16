# MindMender

A mental health website where you can:

- **Chat** with a supportive AI listener (our own fine-tuned model), with crisis detection, a safety filter on replies, and a per-user rate limit for signed-in users
- **Take self-checks**: depression (PHQ-9), anxiety (GAD-7), stress (PSS-10), and a 13-question social media check scored by attention, anxiety, self-esteem and low mood
- **Track your mood** with daily check-ins, a trend chart, and the WHO-5 wellbeing check
- **Keep a journal** on lined paper in a handwriting font, with six kinds of prompts (free write, gratitude, brain dump, worry check, letter to myself, feelings and body)
- **Relax** with box breathing, 5-4-3-2-1 grounding, and quick tips
- **Find answers** in the FAQ, Privacy Policy and Terms, or search the whole site (press `/`)

Every page has dark mode, a mobile menu, a "Get help" button with crisis helplines, and print styles for sharing results with a doctor.

Built with plain HTML/CSS/JS (`site/`), FastAPI (`main.py`), and Firebase Auth + Firestore for accounts and history.

> MindMender is not a substitute for professional care. In crisis: India Tele-MANAS **14416**, KIRAN **1800-599-0019**; US **988**; elsewhere [findahelpline.com](https://findahelpline.com).

## Run locally

The chat server needs a trained model in `models/chat/` (see "Train your own chat model" below).

```sh
pip install -r requirements.txt
uvicorn main:app --port 8000
```

Or with Docker: `docker compose up --build`. Either way, open http://localhost:8000 (use `localhost`, not `127.0.0.1`, which isn't an authorized sign-in domain).

Scoring self-check: `node site/scoring.test.js`

## Deploy

The chat server runs on Google Cloud Run (built in the cloud from the `Dockerfile`; `.gcloudignore` decides what is uploaded, including `models/chat/`). The website runs on Firebase Hosting, which forwards `/chat` to Cloud Run.

```sh
gcloud run deploy mindmender-chat --source . --region asia-south1 \
  --cpu 2 --memory 4Gi --min-instances 0 --max-instances 2 \
  --concurrency 4 --timeout 120 --cpu-boost --allow-unauthenticated
firebase deploy --only hosting,firestore:rules
```

## Firebase setup

1. In the Firebase Console, enable the **Email/Password** and **Google** sign-in providers.
2. Add your deployed domain under Authentication → Settings → **Authorized domains**.
3. Deploy the security rules: `firebase deploy --only firestore:rules`.

## Train your own chat model

The chat runs on a small Hugging Face model fine-tuned on counselling Q&As:

```sh
pip install -r requirements-train.txt
python train_chat.py --data separated_conversation.csv --data <hf-dataset-id-or-file> [--data ...]
```

- `--data` takes local `.csv`/`.json`/`.jsonl`/`.parquet` files or Hugging Face dataset ids, and can be repeated. Columns are detected for `separated_conversation.csv` (`human_prompt`/`assistant_output`), Counsel Chat (`questionText`/`answerText`) and `Amod/mental_health_counseling_conversations` (`Context`/`Response`); for other data pass `--prompt-col` and `--response-col`.
- The default base is `Qwen/Qwen2.5-0.5B-Instruct` (runs on an M-series Mac or a free Colab GPU). Use `--base Qwen/Qwen2.5-1.5B-Instruct` on a GPU for better replies.
- The model is saved to `models/chat/`, which `main.py` loads on start.
- If you see a Keras/TensorFlow error, run with `USE_TF=0`.
