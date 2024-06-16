defmodule Roguelandia.Repo do
  use Ecto.Repo,
    otp_app: :roguelandia,
    adapter: Ecto.Adapters.Postgres
end
