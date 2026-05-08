FROM ghcr.io/cirruslabs/flutter:3.41.9 AS builder

WORKDIR /app

COPY front/pubspec.yaml front/pubspec.lock ./
RUN flutter pub get

COPY front/ .
COPY .env .env

RUN flutter build web --release

# index.html의 플레이스홀더를 실제 Client ID로 치환
ARG GOOGLE_CLIENT_ID
RUN sed -i "s|__GOOGLE_CLIENT_ID__|${GOOGLE_CLIENT_ID}|g" build/web/index.html

FROM nginx:alpine

COPY --from=builder /app/build/web /usr/share/nginx/html
COPY front/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
