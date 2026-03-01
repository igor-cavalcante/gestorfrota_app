# -------- STAGE 1: BUILD --------
FROM ghcr.io/cirruslabs/flutter:stable AS build-env

WORKDIR /app

COPY pubspec.* ./
RUN flutter pub get

COPY . .

ARG SPRING_PUBLIC_API_URL
RUN flutter build web --release \
    --dart-define=API_URL=http://${SPRING_PUBLIC_API_URL}

# -------- STAGE 2: NGINX --------
FROM nginx:stable-alpine

COPY --from=build-env /app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]