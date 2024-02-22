FROM alpine as runbase
ENV LANG=C.UTF-8
RUN apk update && apk add libstdc++ libgcc openssl ncurses-libs

FROM elixir:1.16.1-alpine as build
WORKDIR /var/www/catsbot
ADD mix* ./
RUN mix do local.hex --force, local.rebar --force && mix deps.get --only=prod
ADD config config
ADD lib lib
RUN mkdir /rel && MIX_ENV=prod mix release --path /rel

FROM runbase
WORKDIR /app
COPY --from=build /rel ./
ENTRYPOINT ["./bin/catsbot", "start"]
