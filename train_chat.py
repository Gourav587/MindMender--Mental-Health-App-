"""Fine-tune a small Hugging Face chat model (LoRA) for the MindMender chatbot.

Install:  pip install -r requirements-train.txt
Run:      python train_chat.py --data separated_conversation.csv --data Amod/mental_health_counseling_conversations
Output:   models/chat/  (merged model + tokenizer; main.py serves it automatically when present)

--data takes local .csv/.json/.jsonl/.parquet files or Hugging Face dataset ids, and can be repeated.
Prompt/response columns are auto-detected for the datasets below; for others pass --prompt-col/--response-col.
"""
import argparse
import os
import re
import sys

# transformers 5's threaded weight loading segfaults on macOS; load sequentially.
os.environ.setdefault("HF_DEACTIVATE_ASYNC_LOAD", "1")

# Keep in sync with SYSTEM_PROMPT in main.py so the model sees the same instructions it was trained with.
SYSTEM_PROMPT = (
    "You are MindMender, a warm and supportive listener for mental health and stress. "
    "You are not a therapist: never diagnose or prescribe. Keep replies short and kind, "
    "and suggest a mental health professional for anything serious."
)

# (prompt, response) column names of the datasets we train on.
COLUMN_PAIRS = [
    ("human_prompt", "assistant_output"),  # separated_conversation.csv
    ("Context", "Response"),               # Amod/mental_health_counseling_conversations
    ("questionText", "answerText"),        # Counsel Chat
]


def detect_columns(columns, prompt_col=None, response_col=None):
    if prompt_col and response_col:
        return prompt_col, response_col
    for p, r in COLUMN_PAIRS:
        if p in columns and r in columns:
            return p, r
    raise ValueError(f"Can't tell which columns are prompt/response in {columns}; pass --prompt-col and --response-col")


# Sentences where a therapist advertises or speaks as a therapist ("contact me", "my clients", websites,
# phone numbers, credentials). The bot must never claim to be a therapist or offer sessions, and crisis
# numbers come from main.py instead. Split also catches "sentence.Next" with no space after the period.
SENTENCE_SPLIT = re.compile(r"(?<=[.!?])\s+|(?<=[a-z][.!?])(?=[A-Z])")
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
MIN_KEPT = 0.6  # drop the whole answer if cleaning removed more than 40% of it


def clean_response(text):
    """Remove self-promotion sentences; None if too little is left to be a good answer."""
    text = text.strip()
    kept = " ".join(s.strip() for s in SENTENCE_SPLIT.split(text) if s.strip() and not PROMO.search(s))
    return kept if kept and len(kept) >= MIN_KEPT * len(text) else None


def to_messages(prompt, response):
    prompt, response = (prompt or "").strip(), clean_response(response or "")
    if not prompt or not response:
        return None
    return [
        {"role": "system", "content": SYSTEM_PROMPT},
        {"role": "user", "content": prompt},
        {"role": "assistant", "content": response},
    ]


def load_one(source, prompt_col, response_col):
    from datasets import load_dataset

    ext = os.path.splitext(source)[1].lstrip(".")
    if os.path.exists(source):
        ds = load_dataset({"jsonl": "json"}.get(ext, ext), data_files=source, split="train")
    else:
        ds = load_dataset(source, split="train")

    p, r = detect_columns(ds.column_names, prompt_col, response_col)
    ds = ds.map(lambda row: {"messages": to_messages(row[p], row[r])}, remove_columns=ds.column_names)
    ds = ds.filter(lambda row: row["messages"] is not None)
    print(f"{source}: {len(ds)} conversations ({p} -> {r})")
    return ds


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--data", action="append", required=True, help="local file or HF dataset id (repeatable)")
    ap.add_argument("--prompt-col")
    ap.add_argument("--response-col")
    ap.add_argument("--base", default="Qwen/Qwen2.5-0.5B-Instruct", help="base model (try Qwen/Qwen2.5-1.5B-Instruct on a GPU)")
    ap.add_argument("--out", default="models/chat")
    ap.add_argument("--epochs", type=float, default=3)
    ap.add_argument("--lr", type=float, default=2e-4)
    ap.add_argument("--batch", type=int, default=2, help="per-step batch; effective batch stays 16 via gradient accumulation")
    ap.add_argument("--resume", nargs="?", const=True, help="resume from the latest checkpoint in <out>-checkpoints, or a given path")
    args = ap.parse_args()
    sys.stdout.reconfigure(line_buffering=True)  # loss logs show up live when redirected to a file

    import torch
    from datasets import concatenate_datasets
    from peft import LoraConfig
    from transformers import AutoTokenizer
    from trl import SFTConfig, SFTTrainer

    mps = torch.backends.mps.is_available()
    bf16 = mps or (torch.cuda.is_available() and torch.cuda.is_bf16_supported())
    print("device:", "mps (Apple GPU)" if mps else "cuda" if torch.cuda.is_available() else "cpu", "| bf16:", bf16)

    ds = concatenate_datasets([load_one(s, args.prompt_col, args.response_col) for s in args.data]).shuffle(seed=42)
    split = ds.train_test_split(test_size=0.05, seed=42)
    print(f"train {len(split['train'])} / eval {len(split['test'])}")

    trainer = SFTTrainer(
        model=args.base,
        train_dataset=split["train"],
        eval_dataset=split["test"],
        peft_config=LoraConfig(r=16, lora_alpha=32, lora_dropout=0.05, target_modules="all-linear", task_type="CAUSAL_LM"),
        args=SFTConfig(
            output_dir=args.out + "-checkpoints",
            num_train_epochs=args.epochs,
            learning_rate=args.lr,
            per_device_train_batch_size=args.batch,
            per_device_eval_batch_size=args.batch,  # default 8 spikes memory during eval
            gradient_accumulation_steps=max(1, 16 // args.batch),
            # Base weights frozen in bf16 halve memory; LoRA adapters stay fp32.
            model_init_kwargs={"dtype": torch.bfloat16} if bf16 else None,
            train_sampling_strategy="group_by_length",  # less padding per batch
            torch_empty_cache_steps=10,  # release cached GPU memory so macOS doesn't swap
            eval_strategy="epoch",
            save_strategy="epoch",
            save_total_limit=1,
            logging_steps=5,
            bf16=bf16,
            report_to="none",
        ),
    )
    trainer.train(resume_from_checkpoint=args.resume)
    print("eval:", trainer.evaluate())

    # Merge LoRA weights into the base so serving needs only transformers.
    trainer.model.merge_and_unload().save_pretrained(args.out)
    AutoTokenizer.from_pretrained(args.base).save_pretrained(args.out)
    print(f"saved to {args.out}")


if __name__ == "__main__":
    main()
