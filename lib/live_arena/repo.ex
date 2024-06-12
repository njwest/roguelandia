defmodule LiveArena.Repo do
  use Ecto.Repo,
    otp_app: :live_arena,
    adapter: Ecto.Adapters.Postgres
end
