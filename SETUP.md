# 개발 환경 설정 메모

## Android 구글 로그인 설정

### 1. SHA-1 지문 확인

```bash
keytool -list -v \
  -keystore ~/.android/debug.keystore \
  -alias androiddebugkey \
  -storepass android \
  -keypass android
```

출력에서 `SHA1:` 항목 복사

### 2. Google Cloud Console 등록

1. https://console.cloud.google.com → API 및 서비스 → 사용자 인증 정보
2. + 사용자 인증 정보 만들기 → OAuth 2.0 클라이언트 ID → **Android**
3. 패키지 이름: `com.khuthon.khuthon`
4. SHA-1: 위에서 복사한 값 붙여넣기
5. 저장

코드 수정 불필요. 등록만 하면 됨.

---

## 웹 배포 (Docker)

```bash
docker compose up --build front api
```

- 서비스 워커 캐시 문제 시: Chrome DevTools → Application → Service Workers → Unregister
- 빌드 후에도 옛날 화면이면 강력 새로고침: Cmd+Shift+R

## 백엔드 AI 에러

`app/app/services/claude_service.py`에서 모델명 수정 필요:
```python
# gemini-2.0-flash-001 → 아래 중 하나로 변경
model = GenerativeModel("gemini-2.0-flash")
model = GenerativeModel("gemini-1.5-flash")
```
