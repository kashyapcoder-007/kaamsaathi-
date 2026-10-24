"""KaamSaathi ML service — pretrained models only, no training needed.

  ASR : faster-whisper (CTranslate2, int8, beam_size=1)  -> fast on CPU
  NLU : paraphrase-multilingual-MiniLM-L12-v2 embeddings -> trade intent
        + job ranking by cosine similarity (Hindi/English/Hinglish)
Models are loaded ONCE at startup, so each request is just inference.
"""
import os, tempfile
from typing import List, Optional
from fastapi import FastAPI, File, Form, UploadFile
from pydantic import BaseModel
from faster_whisper import WhisperModel
from sentence_transformers import SentenceTransformer, util
from extract import extract_facts

app = FastAPI(title="KaamSaathi ML")

asr = WhisperModel(os.getenv("ASR_MODEL", "small"), device="cpu", compute_type="int8")
embedder = SentenceTransformer("sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2")

TRADES = {
    "Mason": ["raj mistri mason brick laying wall plastering", "राज मिस्त्री ईंट दीवार पलस्तर चिनाई"],
    "Painter": ["painter painting walls colour rang", "पेंटर रंग पुताई दीवार पेंट"],
    "Carpenter": ["carpenter badhai wood door furniture", "बढ़ई लकड़ी दरवाज़ा फर्नीचर"],
    "Farm Worker": ["farm worker khet kisan harvest paddy", "खेत किसान कटाई रोपाई खेती"],
    "Helper": ["helper mazdoor labour loading unloading", "हेल्पर मज़दूर लोडिंग सामान उठाना"],
}
_labels, _phrases = [], []
for trade, phrases in TRADES.items():
    for p in phrases:
        _labels.append(trade); _phrases.append(p)
_phrase_emb = embedder.encode(_phrases, convert_to_tensor=True, normalize_embeddings=True)


class TextIn(BaseModel):
    text: str

class Job(BaseModel):
    id: str
    title: str

class RankIn(BaseModel):
    text: str
    jobs: List[Job]


@app.get("/health")
def health():
    return {"ok": True}


@app.post("/asr")
async def transcribe(audio: UploadFile = File(...), lang: Optional[str] = Form("hi")):
    with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as f:
        f.write(await audio.read()); path = f.name
    try:
        segments, _ = asr.transcribe(path, language=lang or None, beam_size=1, vad_filter=True)
        return {"text": " ".join(s.text.strip() for s in segments)}
    finally:
        os.remove(path)


@app.post("/intent")
def intent(body: TextIn):
    q = embedder.encode(body.text, convert_to_tensor=True, normalize_embeddings=True)
    sims = util.cos_sim(q, _phrase_emb)[0]
    best = int(sims.argmax())
    score = float(sims[best])
    return {
        "trade": _labels[best] if score >= 0.30 else None,
        "confidence": round(score, 3),
        **extract_facts(body.text),
    }


@app.post("/rank")
def rank(body: RankIn):
    q = embedder.encode(body.text, convert_to_tensor=True, normalize_embeddings=True)
    j = embedder.encode([x.title for x in body.jobs], convert_to_tensor=True, normalize_embeddings=True)
    sims = util.cos_sim(q, j)[0].tolist()
    ranked = sorted(zip(body.jobs, sims), key=lambda t: -t[1])
    return [{"id": job.id, "title": job.title, "score": round(s, 3)} for job, s in ranked]
