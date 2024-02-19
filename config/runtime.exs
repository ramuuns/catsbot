import Config

config :catsbot,
  mastodon_host: System.get_env("MASTODON_HOST"),
  mastodon_access_token: System.get_env("MASTODON_ACCESS_TOKEN"),
  cats_folder: System.get_env("CATS_FOLDER"),
  admin_user: System.get_env("ADMIN_USER"),
  pics_per_day: System.get_env("CATS_PER_DAY") |> String.to_integer(),
  hour_offset: System.get_env("CATS_HOUR_OFFSET") |> String.to_integer()
