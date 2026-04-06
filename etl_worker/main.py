import os, time
while True:
    print("etl-worker placeholder running with embedding model:", os.getenv("OLLAMA_EMBED_MODEL", "embeddinggemma:300m"), flush=True)
    time.sleep(60)
