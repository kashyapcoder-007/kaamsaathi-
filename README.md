# KaamSaathi ML service (pretrained models)

No training. Models download once on first run (~600 MB total), then run on CPU.

```bash
python -m venv .venv && source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```

Test: open http://localhost:8000/docs

| Endpoint | In | Out |
|---|---|---|
| POST /asr | wav file + `lang` (hi/en) | transcript |
| POST /intent | `{"text": "..."}` | trade, confidence, years, jobs, tools |
| POST /rank | `{"text", "jobs":[{id,title}]}` | jobs sorted by relevance |

## Speed tips
- `ASR_MODEL=base` (or `tiny`) for faster ASR, `small` for better Hindi accuracy.
- Models load once at startup — keep the server running, don't restart per request.
- On a phone, use the Flutter app's on-device `speech_to_text` for the transcript
  and call only `/intent` (milliseconds). Use `/asr` as fallback.
- Optional: swap in Bhashini / AI4Bharat IndicConformer (hosted, needs free API key)
  inside `/asr` for best Indian-language accuracy.
