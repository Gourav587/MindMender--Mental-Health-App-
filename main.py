from llama_index.llms.gemini import Gemini
from llama_index.embeddings.huggingface import HuggingFaceEmbedding
import os
from dotenv import load_dotenv
import chromadb
from llama_index.core import VectorStoreIndex
from llama_index.vector_stores.chroma import ChromaVectorStore
from llama_index.core import StorageContext
from llama_index.core import SimpleDirectoryReader
import chromadb
from llama_index.embeddings.huggingface import HuggingFaceEmbedding
import uvicorn
from fastapi import FastAPI
from llama_index.core import PromptTemplate

load_dotenv()

GOOGLE_API_KEY = os.environ.get("GOOGLE_API_KEY")

app = FastAPI()
llm = Gemini(api_key=GOOGLE_API_KEY)
embed_model = HuggingFaceEmbedding(model_name="BAAI/bge-small-en")
loader = SimpleDirectoryReader(input_dir="./", required_exts=[".csv"])
documents = loader.load_data()
chroma_client = chromadb.EphemeralClient()
chroma_collection = chroma_client.get_or_create_collection('quickstart')
vector_store = ChromaVectorStore(chroma_collection=chroma_collection)
storage_context = StorageContext.from_defaults(vector_store=vector_store)
qa_prompt_tmpl_str = (
    "Welcome. Here, I provide a space for understanding.\n"
    "---------------------\n"
    "{context_str}\n"
    "---------------------\n"
    "With your story laid bare, let us embark without presumption. "
    "In the manner of a trusted confidant, please tender your response to the query.\n"
    "Query: {query_str}\n"
    "Response: "
)


qa_prompt_tmpl = PromptTemplate(qa_prompt_tmpl_str)
index = VectorStoreIndex.from_documents(
    documents, storage_context=storage_context, embed_model=embed_model
)
index_query_engine = index.as_query_engine(similarity_top_k=4,llm=llm,text_qa_template=qa_prompt_tmpl)

@app.post("/chat")
def chat(query: str):
    return index_query_engine.query(query)

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)