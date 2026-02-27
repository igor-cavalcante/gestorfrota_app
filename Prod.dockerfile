FROM ghcr.io/cirruslabs/flutter:stable AS build-env

ARG SPRING_PUBLIC_API_URL

#__ENVS__#

WORKDIR /app

COPY pubspec.* ./

RUN flutter pub get

COPY . .

RUN flutter build web --release \
    --dart-define=API_URL=http://${SPRING_PUBLIC_API_URL}

FROM nginx:stable-alpine

COPY --from=build-env /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
