# Estágio 1: Build da aplicação Flutter
FROM debian:latest AS build-env

RUN apt-get update && apt-get install -y curl git unzip xz-utils zip libglu1-mesa
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

RUN flutter doctor
RUN flutter config --enable-web

WORKDIR /app
COPY . .

# Captura a variável do .build.env através de um argumento de build
ARG SPRING_PUBLIC_API_URL

RUN flutter pub get

RUN flutter build web --release --dart-define=API_URL=http://${SPRING_PUBLIC_API_URL}

# Estágio 2: Servidor de Produção (Alpine)
FROM nginx:stable-alpine AS production

#__ENVS__#

COPY --from=build-env /app/build/web /usr/share/nginx/html

EXPOSE 80