import os

from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, Field

from safety import CRISIS, CRISIS_REPLY, SYSTEM_PROMPT, safe_reply

load_dotenv()

GOOGLE_API_KEY = os.environ.get("GOOGLE_API_KEY")
CHAT_MODEL_DIR = "models/chat"  # written by train_chat.py

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
    return {"reply": safe_reply(answer(body.message))}  # safety net: strip invented names, links, therapist claims


app.mount("/", StaticFiles(directory="site", html=True), name="site")
