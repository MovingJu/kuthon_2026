# KHUTHON FastAPI API Spec

Last updated: 2026-05-08

이 문서는 현재 구현된 백엔드 API 명세의 단일 기준 파일이다. 이후 엔드포인트, 요청/응답 필드, 인증 요구사항이 수정되거나 추가되면 이 파일을 함께 갱신한다.

## Base URL

- Local/API prefix: `/api/v1`
- Health check: `/health`

## Auth

인증이 필요한 API는 `Authorization: Bearer {access_token}` 헤더를 사용한다.

### POST `/api/v1/auth/register`

회원가입.

Request:

```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "홍길동",
  "role": "creator"
}
```

- `name`: 선택값. 없으면 이메일 `@` 앞부분 사용.
- `role`: 선택값. `"creator"` | `"provider"`. Google 회원가입 플로우에서는 필수로 전달.

Response `201`:

빈 바디.

Errors:

- `409`: 이미 등록된 이메일

### POST `/api/v1/auth/login`

로그인.

Request:

```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

Response `200`:

```json
{
  "access_token": "jwt_token"
}
```

Errors:

- `401`: 이메일 또는 비밀번호 오류

### POST `/api/v1/auth/google`

구글 로그인. Google OAuth로 받은 ID Token을 백엔드에 전달하여 앱 자체 JWT를 발급받는다. 신규 유저는 자동 가입하지 않고 `404`를 반환한다. 프론트엔드는 회원가입 화면으로 유도한 뒤 `/auth/register`로 별도 가입시킨다.

Request:

```json
{
  "id_token": "google_id_token"
}
```

Response `200`:

```json
{
  "access_token": "jwt_token"
}
```

Errors:

- `500`: `GOOGLE_CLIENT_ID` 미설정 또는 `google-auth` 미설치
- `401`: 구글 토큰 오류
- `404`: 가입되지 않은 사용자

처리 흐름:

1. `id_token`을 Google 공개키로 검증
2. 토큰에서 `email` 추출
3. DB에 해당 `email`을 가진 유저가 없으면 `404` 반환
4. 유저가 있으면 앱 자체 JWT(`access_token`) 발급 후 `200` 반환

### POST `/api/v1/auth/google-login`

`POST /api/v1/auth/google`과 동일한 별칭 엔드포인트.

### GET `/api/v1/auth/me`

내 정보 조회. 인증 필요.

Response `200`:

```json
{
  "id": "user_id",
  "email": "user@example.com",
  "name": "홍길동",
  "created_at": "2026-05-08T00:00:00Z",
  "gender": null,
  "contact": null,
  "birth_date": null,
  "preferred_content_types": [],
  "role": "creator",
  "region": "서울",
  "category_tags": [],
  "personality_tags": [],
  "content_style_tags": [],
  "target_audience_ages": ["20대", "30대"],
  "target_audience_gender": "여성 위주",
  "platform": "youtube_shorts"
}
```

### PATCH `/api/v1/auth/profile`

프로필 수정. 인증 필요.

Request:

```json
{
  "name": "홍길동",
  "gender": null,
  "contact": "010-0000-0000",
  "birth_date": "2000-01-01",
  "preferred_content_types": ["브이로그"],
  "region": "서울",
  "category_tags": ["여행"],
  "personality_tags": ["친근한"],
  "content_style_tags": ["깔끔한"],
  "target_audience_ages": ["20대", "30대"],
  "target_audience_gender": "여성 위주",
  "follower_count": 10000,
  "avg_views": 5000,
  "past_culture_content_count": 3,
  "completion_rate": 0.95,
  "platform": "youtube_shorts",
  "role": "creator"
}
```

Response `200`:

`GET /api/v1/auth/me`와 동일한 UserPublic 객체.

## Tags

### GET `/api/v1/tags`

프론트에서 선택지로 사용할 고정 태그 목록 조회.

Response `200`:

```json
{
  "category_tags": ["게임", "메이크업", "필링", "브이로그", "소통", "요리", "먹방", "베이킹", "뉴스", "음악", "여행", "키즈", "리뷰", "교육", "DIY", "운동", "자기계발"],
  "personality_tags": ["친근한", "진정성 있는", "스토리텔링", "공감능력", "부드러운", "실력이 있는", "추진력", "핏찰을 잘하는", "지렬한", "트렌디한", "전문성 있는", "팬층이 탄탄한", "비주얼적인", "독특한 아이디어"],
  "content_style_tags": ["자작 중심", "TTS", "더빙", "다이나믹", "깔끔한", "차분한", "하이 텐션", "평온", "직설적인", "심층적인", "튜토리얼성", "정보전달", "관찰형", "미스터리", "고퀄리티", "유머스러운", "MBTI T", "MBTI F", "소통이 활발한"]
}
```

## Cultural Items

### POST `/api/v1/items`

문화 아이템 생성. 인증 필요. 생성 시 브리핑 생성을 시도하지만, 브리핑 실패는 아이템 생성을 막지 않는다.

Request:

```json
{
  "title": "전시 제목",
  "category": "전시",
  "region": "서울",
  "description": "설명",
  "tags": ["여행", "리뷰"],
  "budget": "100만원",
  "min_subscribers": 10000,
  "reference_facts": ["검증된 사실"],
  "nearby_spots": ["주변 장소"],
  "start_date": "2026-05-08",
  "end_date": "2026-06-08"
}
```

Response `201`:

```json
{
  "item": {
    "id": "item_id",
    "created_at": "2026-05-08T00:00:00Z",
    "provider_id": "user_id",
    "content_count": 0,
    "status": "active"
  }
}
```

### GET `/api/v1/items`

문화 아이템 목록 조회.

Query:

- `region`: 지역 필터
- `category`: 카테고리 필터
- `sort`: `coverage_asc` | `coverage_desc` | `created_desc`
- `search`: 제목, 설명, 태그 검색

Response `200`:

```json
{
  "items": []
}
```

### GET `/api/v1/items/recommended`

AI 기반 추천 아이템 조회. 인증 필요.

처리 흐름:

1. 활성 상태의 문화 소재를 조회한다.
2. 내 카테고리 태그, 선호 콘텐츠 유형, 지역으로 룰 기반 후보 20개를 먼저 고른다.
3. 내 유튜브 분석 프로필이 있으면 콘텐츠 스타일, 타겟 시청자, 채널 강점, AI 요약을 함께 Gemini에 전달한다.
4. Gemini가 최대 5개 추천을 `match_score` 내림차순으로 반환한다.
5. AI 추천 실패 시 룰 기반 후보 상위 5개를 반환한다.

Response `200`:

```json
{
  "items": [
    {
      "id": "item_id",
      "title": "문화 소재명",
      "category": "전시",
      "region": "서울",
      "tags": ["여행"],
      "ai_match_score": 92,
      "ai_reason": "추천 이유",
      "ai_content_hook": "숏폼 아이디어 한 줄"
    }
  ]
}
```

### GET `/api/v1/items/feed`

크리에이터 맞춤 피드 조회. 인증 필요.

그룹 생성 기준:

- `subscriber_range`: 내 팔로워 규모와 비슷한 최소 구독자 조건의 아이템
- `category_match`: 내 카테고리/선호 콘텐츠와 매칭되는 아이템
- `region`: 내 지역과 같은 아이템
- `trending`: 지원 수가 많은 아이템, 항상 포함

Response `200`:

```json
{
  "feed": [
    {
      "group_id": "subscriber_range",
      "title": "구독자 천명대 유튜버가 많이 찾아요!",
      "items": []
    }
  ]
}
```

### GET `/api/v1/items/{item_id}`

문화 아이템 상세 조회. 최신 브리핑을 함께 반환한다.

Response `200`:

```json
{
  "item": {
    "id": "item_id",
    "briefing": null
  }
}
```

Errors:

- `404`: 아이템 없음

### PUT `/api/v1/items/{item_id}`

문화 아이템 수정. 인증 필요. 생성자(provider)만 수정 가능.

Request:

```json
{
  "title": "수정 제목",
  "category": "전시",
  "region": "서울",
  "description": "수정 설명",
  "tags": ["여행"],
  "budget": "200만원",
  "min_subscribers": 50000,
  "reference_facts": [],
  "nearby_spots": [],
  "start_date": "2026-05-08",
  "end_date": "2026-06-08",
  "status": "active"
}
```

Response `200`:

```json
{
  "item": {}
}
```

Errors:

- `404`: 아이템 없음
- `403`: 생성자 아님

### DELETE `/api/v1/items/{item_id}`

문화 아이템 삭제. 인증 필요. 생성자(provider)만 삭제 가능.

Response `204`:

빈 바디.

Errors:

- `404`: 아이템 없음
- `403`: 생성자 아님

## Briefings

### GET `/api/v1/items/{item_id}/briefing`

아이템 최신 브리핑 조회.

Response `200`:

```json
{
  "briefing": {}
}
```

Errors:

- `404`: 아이템 없음 또는 브리핑 미생성

### POST `/api/v1/items/{item_id}/briefing/regenerate`

브리핑 재생성. 인증 필요. 생성자(provider)만 가능.

Response `201`:

```json
{
  "briefing": {}
}
```

Errors:

- `404`: 아이템 없음
- `403`: 생성자 아님

## Applications

### POST `/api/v1/items/{item_id}/apply`

아이템 지원. 인증 필요.

Request:

```json
{
  "message": "지원 메시지"
}
```

Response `201`:

```json
{
  "application": {
    "id": "application_id",
    "item_id": "item_id",
    "creator_id": "user_id",
    "status": "pending",
    "score": 0,
    "score_breakdown": {},
    "message": "지원 메시지",
    "reviewed_at": null
  }
}
```

Errors:

- `404`: 아이템 없음
- `409`: 이미 지원함

### GET `/api/v1/items/{item_id}/applicants`

지원자 목록 조회. 인증 필요. 생성자(provider)만 조회 가능.

Query:

- `sort`: `score` | `created`, 기본값 `score`

Response `200`:

```json
{
  "applicants": []
}
```

Errors:

- `404`: 아이템 없음
- `403`: 생성자 아님

### PATCH `/api/v1/applications/{app_id}`

지원 승인/거절. 인증 필요. 아이템 생성자(provider)만 가능.

Request:

```json
{
  "status": "approved"
}
```

Allowed status:

- `approved`
- `rejected`

Response `200`:

```json
{
  "application": {}
}
```

Errors:

- `404`: 지원 내역 없음
- `403`: 권한 없음

### GET `/api/v1/my/applications`

내 지원 내역 조회. 인증 필요.

Response `200`:

```json
{
  "applications": []
}
```

### GET `/api/v1/my/stats`

마이페이지 참여 콘텐츠 통계 조회. 인증 필요.

Response `200`:

```json
{
  "applied": 12,
  "approved": 3,
  "completed": 1
}
```

## Fact Check

### POST `/api/v1/factcheck`

콘텐츠 원고 팩트체크 실행. 인증 필요.

Request:

```json
{
  "item_id": "item_id",
  "text": "검증할 원고"
}
```

Response `200`:

```json
{
  "fact_check": {
    "id": "fact_check_id",
    "item_id": "item_id",
    "creator_id": "user_id",
    "input_text": "검증할 원고",
    "result": {}
  }
}
```

Errors:

- `404`: 아이템 없음

### GET `/api/v1/factcheck/history`

내 팩트체크 기록 조회. 인증 필요.

Response `200`:

```json
{
  "history": []
}
```

## AI Chat

### POST `/api/v1/chat`

AI에게 메시지를 전송하고 답변을 받는다. 인증 필요. 백엔드가 Gemini 호출을 대리하며, 프론트가 Gemini를 직접 호출하지 않는다.

개인정보 보호 규칙:

- AI 프롬프트에 사용자 이름, 이메일, 역할, 태그 등 개인정보를 직접 넣지 않는다.
- AI는 "당신의 프로필에는..." 같은 방식으로 프로필 정보를 언급하지 않는다.
- 전통문화 콘텐츠 기획, 소재 추천, 촬영 팁, 공고 관련 질문에 집중한다.

Request:

```json
{
  "message": "추천받고 싶은 내용을 입력합니다"
}
```

Response `200`:

```json
{
  "reply": "AI 응답"
}
```

Errors:

- `401`: 인증 실패 또는 토큰 만료

### POST `/api/v1/ai/chat`

기존 클라이언트 호환용 별칭. 내부적으로 `POST /api/v1/chat`과 동일한 안전 채팅 서비스를 사용한다.

## Dashboard

### GET `/api/v1/dashboard/coverage`

아이템별 콘텐츠 수 현황.

Response `200`:

```json
{
  "coverage": [
    {
      "item_id": "item_id",
      "title": "제목",
      "content_count": 0
    }
  ]
}
```

### GET `/api/v1/dashboard/regions`

지역별 아이템/콘텐츠 현황.

Response `200`:

```json
{
  "regions": [
    {
      "region": "서울",
      "item_count": 1,
      "total_content": 0
    }
  ]
}
```

### GET `/api/v1/dashboard/categories`

카테고리별 아이템/콘텐츠 현황.

Response `200`:

```json
{
  "categories": [
    {
      "category": "전시",
      "item_count": 1,
      "total_content": 0
    }
  ]
}
```

## Creators

### GET `/api/v1/creators`

크리에이터 목록 조회. 인증 필요.

정렬 원칙:

- 포트폴리오 등급, 과거 광고 성과, VIS/CPS로 정렬하지 않는다.
- 기본 반환 순서는 등록 순이다.
- `portfolio_rank`, `portfolio_summary`, `tier_distribution`은 카드 표시용 참고 정보이며, 상세 포트폴리오는 `GET /creators/{creator_id}/portfolio`에서 확인한다.

Query:

- `category`: 카테고리 태그 필터
- `min_subscribers`: 최소 구독자 수 필터

Response `200`:

```json
{
  "creators": [
    {
      "id": "creator_id",
      "name": "크리에이터명",
      "category_tags": ["먹방"],
      "subscriber_count": 22000,
      "avg_engagement_rate": 0.048,
      "content_style": "먹방/여행",
      "ai_summary": "...",
      "shorts_ratio": 0.7,
      "channel_url": "",
      "thumbnail_url": "",
      "portfolio_rank": "우수",
      "portfolio_summary": "S급 1편 · A급 2편 광고 성과",
      "tier_distribution": {"S": 1, "A": 2, "B": 0, "C": 0, "D": 0}
    }
  ]
}
```

### POST `/api/v1/creators/match-for-item/{item_id}`

광고주가 등록한 소재에 가장 잘 맞는 크리에이터 AI 추천. 인증 필요. 소재 등록자(provider)만 가능.

매칭 기준 (Gemini): 시청자 나이대/성별 + 콘텐츠 유형 + 채널 강점/스타일. 과거 광고 성과, 포트폴리오 등급, 구독자 수, 지역은 매칭 점수와 정렬에 미반영.

Response `200`:

```json
{
  "matches": [
    {
      "creator_id": "user_xyz",
      "name": "혜원",
      "channel_name": "혜원의 전통 부엌",
      "channel_url": "",
      "thumbnail_url": "",
      "subscriber_count": 22000,
      "target_audience_ages": ["20대", "30대"],
      "target_audience_gender": "여성 위주",
      "category_tags": ["먹방"],
      "portfolio": {
        "rank": "우수",
        "summary": "S급 1편 · A급 2편 광고 성과",
        "tier_distribution": {"S": 1, "A": 2, "B": 0, "C": 0, "D": 0}
      },
      "ai_match_score": 92,
      "ai_reason": "20-30대 여성 타겟과 채널 시청자층이 일치합니다. 먹방 스타일이 지역 음식 소재와 자연스럽게 연결됩니다.",
      "expected_outcome": "안동 구시장 탐방 + 찜닭 먹방으로 지역 관광 유도 가능"
    }
  ],
  "item": {"id": "cult_abc", "title": "안동 하회탈"}
}
```

Errors:

- `404`: 소재 없음
- `403`: 본인 소재 아님

### GET `/api/v1/creators/{creator_id}/portfolio`

크리에이터 포트폴리오 조회. 광고주가 개별 프로필에서 확인하는 화면.

VIS (Video Impact Score) 산식:

- 조회수 가드레일: 조회수 < 1,000이면 `(views/1000) × 30` 점 캡
- 도달 점수 (30점): `log10(views/1000) / log10(50000/1000) × 30`
- 참여 품질 (40점): `min((likes+comments)/views / 0.06, 1) × 40`
- 댓글 활성도 (20점): `min(comments/views / 0.005, 1) × 20`
- 형식 적합도 (10점): Shorts 30~60초 10점
- 등급: `S(90+)`, `A(80+)`, `B(65+)`, `C(50+)`, `D`

Response `200`:

```json
{
  "creator": {
    "id": "creator_id",
    "name": "크리에이터명",
    "category_tags": ["먹방"]
  },
  "youtube_profile": {},
  "portfolio": {
    "total_ads": 3,
    "tier_distribution": {"S": 1, "A": 2, "B": 0, "C": 0, "D": 0},
    "best_score": 96.5,
    "average_score": 84.2,
    "rank": "우수",
    "summary": "S급 1편 · A급 2편 광고 성과",
    "scores": [96.5, 84.2, 72.1]
  },
  "ad_history": [
    {
      "id": "performance_id",
      "video_url": "https://youtube.com/shorts/...",
      "view_count": 35000,
      "like_count": 2100,
      "comment_count": 350,
      "duration_seconds": 45,
      "is_shorts": true,
      "engagement_rate": 0.07,
      "thumbnail_url": "",
      "vis": 96.5,
      "vis_grade": "S"
    }
  ]
}
```

Errors:

- `404`: 크리에이터 없음

## YouTube

### POST `/api/v1/youtube/connect`

유튜브 채널 연결 및 AI 분석. 인증 필요.

Request:

```json
{
  "channel_url": "https://www.youtube.com/@channel",
  "access_token": "ya29...."
}
```

`access_token`: Google OAuth 토큰 (선택). `yt-analytics.readonly` scope로 발급받은 토큰을 전달하면 YouTube Analytics API를 통해 실제 시청자 나이대/성별을 자동 수집. 미전달 시 공개 채널 정보만 수집.

Response `200`:

```json
{
  "profile": {
    "creator_id": "user_id",
    "channel_id": "channel_id",
    "channel_url": "https://www.youtube.com/@channel",
    "channel_name": "채널명",
    "thumbnail_url": "",
    "subscriber_count": 0,
    "video_count": 0,
    "audience_age_groups": ["20대", "30대"],
    "audience_gender": "여성 위주",
    "audience_demographics_raw": {"20대": 64.0, "30대": 21.0},
    "total_watch_hours": 8.4
  }
}
```

Errors:

- `404`: 채널 없음

### GET `/api/v1/youtube/profile/me`

내 유튜브 프로필 조회. 인증 필요.

Response `200`:

```json
{
  "profile": {}
}
```

Errors:

- `404`: 유튜브 프로필 없음

### GET `/api/v1/youtube/profile/{creator_id}`

특정 크리에이터 유튜브 프로필 조회.

Response `200`:

```json
{
  "profile": {}
}
```

Errors:

- `404`: 유튜브 프로필 없음

## Ad Performance

### POST `/api/v1/ad-performance`

광고/협업 성과 영상 등록. 인증 필요.

Request:

```json
{
  "application_id": "application_id",
  "video_url": "https://www.youtube.com/watch?v=..."
}
```

Response `200`:

```json
{
  "performance": {
    "application_id": "application_id",
    "item_id": "item_id",
    "creator_id": "user_id",
    "provider_id": "provider_id",
    "video_url": "https://www.youtube.com/watch?v=...",
    "engagement_rate": 0,
    "is_shorts": false
  }
}
```

Errors:

- `404`: 지원 내역 없음 또는 영상 없음
- `403`: 본인 지원 내역 아님

### GET `/api/v1/ad-performance/my`

내 성과 포트폴리오 조회. 인증 필요.

Response `200`:

```json
{
  "portfolio": []
}
```

### GET `/api/v1/ad-performance/provider`

제공자 성과 대시보드 조회. 인증 필요.

Response `200`:

```json
{
  "total_ads": 0,
  "avg_engagement_rate": 0,
  "performances": []
}
```

## Health

### GET `/health`

서버 헬스체크.

Response `200`:

```json
{
  "status": "ok"
}
```

### GET `/`

루트 확인용 엔드포인트.

Response `200`:

```json
{
  "message": "Hello, FastAPI!"
}
```
