import os
import logging
import random
import requests
import redis
from fastapi import FastAPI

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()

CAT_API = "https://catfact.ninja/fact"

REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
REDIS_PORT = int(os.getenv("REDIS_PORT", "6379"))

CAT_EMOJIS = ["🐱", "🐈", "🐈‍⬛", "😸", "😹", "😺", "😻", "😼", "😽", "🙀", "😿", "😾", "🐾", "🥛", "🐟", "🍣", "🦴", "🧶"]

logger.info(f"Redis configuration: host={REDIS_HOST}, port={REDIS_PORT}")

rdb = redis.Redis(
    host=REDIS_HOST,
    port=REDIS_PORT,
    decode_responses=True
)

# 🐱 Root endpoint
@app.get("/")
def hello():
    return {
        "message": "Hello cat lover 😸",
        "endpoints": ["/quote", "/quotes", "/docs"]
    }

# 🐾 Get a new cat fact and store it
@app.get("/quote")
def get_quote():
    r = requests.get(CAT_API, timeout=5)
    quote = r.json()["fact"]

    emoji = random.choice(CAT_EMOJIS)
    rdb.rpush("quotes", f"{emoji} {quote}")

    return {"quote": quote}

# 📜 List all stored cat facts
@app.get("/quotes")
def list_quotes():
    return {"quotes": rdb.lrange("quotes", 0, -1)}
