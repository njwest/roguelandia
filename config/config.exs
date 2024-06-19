# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :roguelandia,
  ecto_repos: [Roguelandia.Repo],
  generators: [timestamp_type: :utc_datetime]

host = System.get_env("PHX_HOST") || "localhost"

# Configures the endpoint
config :roguelandia, RoguelandiaWeb.Endpoint,
  url: [host: host],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: RoguelandiaWeb.ErrorHTML, json: RoguelandiaWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Roguelandia.PubSub,
  live_view: [signing_salt: "JWU8QrzZ"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :roguelandia, Roguelandia.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  roguelandia: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  roguelandia: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Hammer config for rate limiting
config :hammer,
  backend: {Hammer.Backend.ETS, [
    expiry_ms: 60_000 * 60 * 4,
    cleanup_interval_ms: 60_000 * 10
  ]}

# Use the following Hammer config for local Redis backend
  # backend: {Hammer.Backend.Redis, [
  #   delete_buckets_timeout: 10_0000,
  #   key_prefix: "roguelandia:rate_limiter",
  #   expiry_ms: 60_000 * 60 * 2,
  #   redix_config: [host: "localhost", port: 6379]
  # ]}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
