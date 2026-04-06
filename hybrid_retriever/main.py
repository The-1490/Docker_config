from fastapi import FastAPI
from pydantic import BaseModel
import os

# 1. Define a global Config object so it's easy to adjust and share across all endpoints
class AppSettings(BaseModel):
    llm_provider: str = os.getenv("LLM_PROVIDER", "ollama")
    llm_model: str = os.getenv("LLM_MODEL", "deepseek-v3.1")
    llm_base_url: str = os.getenv("LLM_BASE_URL", "http://ollama.com")
    llm_api_key: str | None = os.getenv("LLM_API_KEY")
    embedding_model: str = os.getenv("EMBEDDING_MODEL", "embeddinggemma:300m")
    embedding_url: str = os.getenv("EMBEDDING_URL", "http://ollama:11434")

# Initialize it once when the app starts
settings = AppSettings()

app = FastAPI(title="hybrid-retriever")

@app.get("/health")
def health():
    return {
        "status": "ok",
        # 2. Use the settings object here and elsewhere in your code!
        "llm_provider": settings.llm_provider,
        "llm_model": settings.llm_model,
        "llm_base_url": settings.llm_base_url,
        "embedding_model": settings.embedding_model,
        "embedding_url": settings.embedding_url
    }
