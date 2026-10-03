import os
import re

import uvicorn
from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, Field

load_dotenv()

GOOGLE_API_KEY = os.environ.get("GOOGLE_API_KEY")
CHAT_MODEL_DIR = "models/chat"  # written by train_chat.py

# Keep in sync with SYSTEM_PROMPT in train_chat.py.
SYSTEM_PROMPT = (
    "You are MindMender, a warm and supportive listener for mental health and stress. "
    "You are not a therapist: never diagnose or prescribe. Keep replies short and kind, "
    "and suggest a mental health professional for anything serious."
)

# ponytail: keyword match only, misses indirect phrasing; swap in an LLM classifier if that matters
CRISIS = re.compile(r"suicid|kill myself|end my life|self[- ]?harm|hurt myself|want to die|cut myself", re.I)
CRISIS_REPLY = (
    "I'm really sorry you're feeling this way. You deserve support right now, and talking to a person can help. "
    "Please reach out to a helpline: India: Tele-MANAS 14416 or KIRAN 1800-599-0019. US: call or text 988. "
    "Elsewhere: findahelpline.com. If you're in immediate danger, call your local emergency number."
)

app = FastAPI()

if os.path.isdir(CHAT_MODEL_DIR):
    # Our own fine-tuned model.
    from transformers import pipeline

    generator = pipeline("text-generation", model=CHAT_MODEL_DIR)

    def answer(message):
        messages = [{"role": "system", "content": SYSTEM_PROMPT}, {"role": "user", "content": message}]
        out = generator(messages, max_new_tokens=300, do_sample=True, temperature=0.7, top_p=0.9, repetition_penalty=1.1)
        return out[0]["generated_text"][-1]["content"].strip()
else:
    # No trained model yet: Gemini answering with the closest Q&As from separated_conversation.csv.
    import chromadb
    from llama_index.core import PromptTemplate, SimpleDirectoryReader, StorageContext, VectorStoreIndex
    from llama_index.embeddings.huggingface import HuggingFaceEmbedding
    from llama_index.llms.gemini import Gemini
    from llama_index.vector_stores.chroma import ChromaVectorStore

    llm = Gemini(model="models/gemini-2.5-flash", api_key=GOOGLE_API_KEY)
    embed_model = HuggingFaceEmbedding(model_name="BAAI/bge-small-en")
    documents = SimpleDirectoryReader(input_files=["separated_conversation.csv"]).load_data()
    vector_store = ChromaVectorStore(chroma_collection=chromadb.EphemeralClient().get_or_create_collection("quickstart"))
    index = VectorStoreIndex.from_documents(
        documents, storage_context=StorageContext.from_defaults(vector_store=vector_store), embed_model=embed_model
    )
    qa_prompt_tmpl = PromptTemplate(
        SYSTEM_PROMPT + "\n"
        "Helpful background:\n"
        "---------------------\n"
        "{context_str}\n"
        "---------------------\n"
        "User: {query_str}\n"
        "MindMender: "
    )
    query_engine = index.as_query_engine(similarity_top_k=4, llm=llm, text_qa_template=qa_prompt_tmpl)

    def answer(message):
        return str(query_engine.query(message))


class ChatIn(BaseModel):
    message: str = Field(min_length=1, max_length=2000)


@app.post("/chat")
def chat(body: ChatIn):
    if CRISIS.search(body.message):
        return {"reply": CRISIS_REPLY}
    return {"reply": answer(body.message)}


app.mount("/", StaticFiles(directory="site", html=True), name="site")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
