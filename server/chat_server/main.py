import json
import os
import uuid
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional

from fastapi import FastAPI, Header, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from jose import JWTError, jwt
from pydantic import BaseModel

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key-here")
ALGORITHM = "HS256"
DATA_DIR = Path(os.getenv("DATA_DIR", "data"))
MESSAGES_FILE = DATA_DIR / "messages.jsonl"


def _get_current_user_id(authorization: str) -> str:
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="인증 필요")
    token = authorization.removeprefix("Bearer ")
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("sub")
        if not user_id:
            raise HTTPException(status_code=401, detail="토큰 오류")
        return user_id
    except JWTError:
        raise HTTPException(status_code=401, detail="토큰 오류")


def _load_messages() -> list[dict]:
    if not MESSAGES_FILE.exists():
        return []
    messages = []
    for line in MESSAGES_FILE.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if line:
            messages.append(json.loads(line))
    return messages


def _save_message(msg: dict) -> None:
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    with MESSAGES_FILE.open("a", encoding="utf-8") as f:
        f.write(json.dumps(msg, ensure_ascii=False) + "\n")


def _room_id(a: str, b: str) -> str:
    return "__".join(sorted([a, b]))


class SendMessageRequest(BaseModel):
    text: str


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/debug/me")
def debug_me(authorization: Optional[str] = Header(default=None)):
    """JWT에서 추출되는 user_id 확인용 디버그 엔드포인트"""
    if not authorization or not authorization.startswith("Bearer "):
        return {"error": "no token"}
    token = authorization.removeprefix("Bearer ")
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return {"payload": payload, "sub": payload.get("sub")}
    except JWTError as e:
        # 검증 실패 시 decode만 해서 payload 확인 (서명 무시)
        try:
            import base64 as _b64
            parts = token.split(".")
            padded = parts[1] + "=" * (4 - len(parts[1]) % 4)
            raw = json.loads(_b64.urlsafe_b64decode(padded))
            return {"jwt_error": str(e), "raw_payload": raw}
        except Exception as e2:
            return {"jwt_error": str(e), "decode_error": str(e2)}


@app.get("/chats")
def list_chats(authorization: Optional[str] = Header(default=None)):
    me = _get_current_user_id(authorization)
    messages = _load_messages()

    last_by_other: dict[str, dict] = {}
    unread_count: dict[str, int] = {}

    for msg in messages:
        if me not in (msg["sender_id"], msg["receiver_id"]):
            continue
        other = msg["receiver_id"] if msg["sender_id"] == me else msg["sender_id"]
        last_by_other[other] = msg
        if msg["sender_id"] != me:
            unread_count[other] = unread_count.get(other, 0) + 1

    chats = []
    for other_id, last_msg in last_by_other.items():
        chats.append({
            "other_user_id": other_id,
            "other_user_name": other_id,
            "last_message": last_msg["text"],
            "last_message_at": last_msg["created_at"],
            "unread_count": unread_count.get(other_id, 0),
        })

    chats.sort(key=lambda c: c["last_message_at"], reverse=True)
    return {"chats": chats}


@app.get("/chats/{other_user_id}/messages")
def get_messages(
    other_user_id: str,
    after: Optional[str] = Query(default=None),
    authorization: Optional[str] = Header(default=None),
):
    me = _get_current_user_id(authorization)
    room = _room_id(me, other_user_id)
    messages = _load_messages()

    result = [m for m in messages if m.get("room_id") == room]

    if after:
        after_dt = datetime.fromisoformat(after.replace("Z", "+00:00"))
        result = [m for m in result if datetime.fromisoformat(m["created_at"].replace("Z", "+00:00")) > after_dt]

    return {"messages": result}


@app.post("/chats/{other_user_id}/messages", status_code=201)
def send_message(
    other_user_id: str,
    body: SendMessageRequest,
    authorization: Optional[str] = Header(default=None),
):
    me = _get_current_user_id(authorization)
    msg = {
        "id": f"msg_{uuid.uuid4().hex[:12]}",
        "room_id": _room_id(me, other_user_id),
        "sender_id": me,
        "receiver_id": other_user_id,
        "text": body.text,
        "created_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
    }
    _save_message(msg)
    return {"message": msg}
