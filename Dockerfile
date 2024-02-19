FROM elixir:1.16.1

WORKDIR /var/www/catsbot
ADD mix* ./
RUN mix do local.hex --force, local.rebar --force && mix deps.get && mix deps.compile
ADD config config
ADD lib lib
RUN mix compile
ENTRYPOINT mix run --no-halt
