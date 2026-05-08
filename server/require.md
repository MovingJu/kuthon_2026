# API 명세서

## Base URL

```
/api/v1
```

---

## Auth

### 1. Google 로그인

Google OAuth로 받은 ID Token을 백엔드에 전달하여 앱 자체 JWT를 발급받는다.  
**신규 유저는 자동 가입하지 않고 404를 반환한다.** 프런트엔드에서 회원가입 화면으로 유도한 뒤 `/auth/register`로 별도 가입시킨다.

#### `POST /auth/google-login`

**Request Body**

```json
{
  "id_token": "string"
}
```

**Response 200** — 기존 유저 로그인 성공

```json
{
  "access_token": "string"
}
```

**Response 404** — DB에 해당 이메일 유저 없음 (신규 유저 → 프런트가 회원가입으로 이동)

```json
{
  "detail": "가입되지 않은 사용자입니다"
}
```

**Response 401**

```json
{
  "detail": "string"
}
```

**처리 흐름**

1. `id_token`을 Google 공개키로 검증
2. 토큰에서 `email` 추출
3. DB에 해당 `email`을 가진 유저가 **없으면 404 반환** (자동 가입 금지)
4. 유저가 있으면 앱 자체 JWT(`access_token`) 발급 후 200 반환

---

### 2. 이메일 로그인

#### `POST /auth/login`

**Request Body**

```json
{
  "email": "string",
  "password": "string"
}
```

**Response 200**

```json
{
  "access_token": "string"
}
```

**Response 401**

```json
{
  "detail": "string"
}
```

---

### 3. 이메일 회원가입

#### `POST /auth/register`

**Request Body**

```json
{
  "email": "string",
  "password": "string",
  "name": "string"
}
```

**Response 201** — 빈 바디

**Response 400 / 409**

```json
{
  "detail": "string"
}
```

---

---

## Profile

### 4. 프로필 저장 (계정 정보 입력 완료)

계정 정보 입력 화면("멋진 계정이네요!")에서 다음 버튼 클릭 시 호출.

#### `PATCH /auth/profile`

**Headers**

```
Authorization: Bearer <access_token>
```

**Request Body**

```json
{
  "name": "string",
  "gender": "남성 | 여성 | 비공개",
  "contact": "string",
  "birth_date": "string",
  "preferred_content_types": ["숏폼"],
  "category_tags": ["친근한", "꾸준한"],
  "role": "creator"
}
```

**Response 200** — 빈 바디 또는 업데이트된 유저 정보

**Response 401**

```json
{
  "detail": "string"
}
```

---

---

## AI 채팅

### 5. AI에게 메시지 전송

#### `POST /ai/chat`

**Headers**

```
Authorization: Bearer <access_token>
```

**Request Body**

```json
{
  "message": "string"
}
```

**Response 200**

```json
{
  "reply": "string"
}
```

**Response 401**

```json
{
  "detail": "string"
}
```

**처리 흐름**

1. 유저의 `message`를 받아 AI(LLM)에 전달
2. 유저 프로필(카테고리 태그, 선호 콘텐츠 유형 등)을 컨텍스트로 활용해 공고 추천 가능
3. AI 응답(`reply`)을 반환

---

---

## 공고 지원 (Applications)

### 6. 공고 지원 신청

공고 상세페이지에서 "지원하기" 버튼 클릭 시 호출. 중복 신청은 409로 처리.

#### `POST /applications`

**Headers**

```
Authorization: Bearer <access_token>
```

**Request Body**

```json
{
  "post_id": "string"
}
```

**Response 201** — 신청 성공

```json
{
  "application_id": "string",
  "post_id": "string",
  "status": "applied",
  "created_at": "string"
}
```

**Response 409** — 이미 신청한 공고

```json
{
  "detail": "이미 신청한 공고입니다"
}
```

**Response 401**

```json
{
  "detail": "string"
}
```

---

### 7. 내 참여 콘텐츠 목록 조회

참여 콘텐츠 화면에서 탭별(신청/참여/종료)로 목록 조회.

#### `GET /applications/me`

**Headers**

```
Authorization: Bearer <access_token>
```

**Query Parameters**

| 파라미터 | 타입 | 설명 |
|--------|------|------|
| `status` | string | `applied` \| `in_progress` \| `completed` (탭 구분) |

**Response 200**

```json
{
  "applications": [
    {
      "application_id": "string",
      "post_id": "string",
      "status": "applied",
      "post": {
        "title": "string",
        "subtitle": "string",
        "reward": "string",
        "deadline": "string",
        "thumbnail_url": "string"
      },
      "created_at": "string"
    }
  ]
}
```

**Response 401**

```json
{
  "detail": "string"
}
```

**Status 값 설명**

| 값 | 탭 | 설명 |
|----|-----|------|
| `applied` | 신청 | 유저가 신청, 아직 에디터 수락 전 |
| `in_progress` | 참여 | 에디터가 수락하여 콘텐츠 진행 중 |
| `completed` | 종료 | 콘텐츠 제작 완료 또는 기한 종료 |

---

---

## 공고 목록 (Posts)

### 8. 공고 목록 조회 (필터링 포함)

메인 화면에서 지역/시청층/콘텐츠 유형 필터 적용 시 호출. 필터 없으면 추천 섹션별 목록 반환.

#### `GET /posts`

**Headers**

```
Authorization: Bearer <access_token>
```

**Query Parameters**

| 파라미터 | 타입 | 설명 |
|--------|------|------|
| `region` | string | 지역 필터 (예: `강원`, `경북`, `전남`, `충남`, `제주`, `서울/수도권`) |
| `age_group` | string | 시청 층 필터 (예: `10대`, `20대`, `30대`, `40대+`, `만명대`) |
| `content_type` | string | 콘텐츠 유형 필터 (예: `숏폼`, `롱폼`, `먹방`, `ASMR`, `문화/역사`, `힐링`) |
| `section` | string | 추천 섹션 (예: `popular`, `age_20`, `food`) — 필터 없을 때 사용 |

**Response 200**

```json
{
  "posts": [
    {
      "id": "string",
      "title": "string",
      "subtitle": "string",
      "reward": "string",
      "deadline": "string",
      "thumbnail_url": "string",
      "region": "string",
      "age_group": "string",
      "content_type": "string"
    }
  ]
}
```

**Response 401**

```json
{
  "detail": "string"
}
```

**처리 흐름**

1. 쿼리 파라미터가 없으면 추천 알고리즘 기반 전체 목록 반환
2. `region` / `age_group` / `content_type` 파라미터가 있으면 AND 조건으로 필터링
3. `section` 파라미터가 있으면 해당 섹션의 추천 목록만 반환

---

### 9. 공고 상세 조회

#### `GET /posts/{post_id}`

**Headers**

```
Authorization: Bearer <access_token>
```

**Response 200**

```json
{
  "id": "string",
  "title": "string",
  "subtitle": "string",
  "reward": "string",
  "deadline": "string",
  "thumbnail_url": "string",
  "region": "string",
  "age_group": "string",
  "content_type": "string",
  "description": "string",
  "organization": "string"
}
```

**Response 404**

```json
{
  "detail": "공고를 찾을 수 없습니다"
}
```

---

---

## 1:1 DM 채팅

에디터(provider)와 크리에이터(creator) 간 1:1 채팅. 인증 필요.

### 10. 채팅방 메시지 목록 조회

두 유저 간 채팅 메시지를 시간순으로 조회.

#### `GET /chats/{other_user_id}/messages`

**Headers**

```
Authorization: Bearer <access_token>
```

**Query Parameters**

| 파라미터 | 타입 | 설명 |
|--------|------|------|
| `after` | string (ISO 8601) | 이 시각 이후 메시지만 반환 (polling 용). 생략 시 전체 반환. |

**Response 200**

```json
{
  "messages": [
    {
      "id": "msg_abc123",
      "sender_id": "user_bebeeb8b",
      "text": "안녕하세요!",
      "created_at": "2026-05-09T10:32:00Z"
    }
  ]
}
```

**처리 흐름**

1. 내 `user_id`와 `other_user_id` 두 사람 간 메시지를 조회
2. `after` 파라미터가 있으면 해당 시각 이후 메시지만 반환 (프론트 polling용)
3. `created_at` 오름차순 정렬

---

### 11. 채팅 메시지 전송

#### `POST /chats/{other_user_id}/messages`

**Headers**

```
Authorization: Bearer <access_token>
```

**Request Body**

```json
{
  "text": "안녕하세요!"
}
```

**Response 201**

```json
{
  "message": {
    "id": "msg_abc123",
    "sender_id": "user_bebeeb8b",
    "text": "안녕하세요!",
    "created_at": "2026-05-09T10:32:00Z"
  }
}
```

**Response 401**

```json
{
  "detail": "string"
}
```

---

### 12. 채팅 상대 목록 조회

나와 채팅한 상대 목록 + 각 상대와의 마지막 메시지.

#### `GET /chats`

**Headers**

```
Authorization: Bearer <access_token>
```

**Response 200**

```json
{
  "chats": [
    {
      "other_user_id": "user_bebeeb8b",
      "other_user_name": "DongJuLee",
      "other_user_role": "creator",
      "last_message": "안녕하세요!",
      "last_message_at": "2026-05-09T10:32:00Z",
      "unread_count": 1
    }
  ]
}
```

---

## 공통 사항

- `access_token`은 Bearer JWT
- 인증이 필요한 요청은 `Authorization: Bearer <access_token>` 헤더 사용
- 토큰 만료 시 401 반환
