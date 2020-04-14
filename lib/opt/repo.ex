defmodule Opt.Repo do
  use Ecto.Repo,
    otp_app: :opt,
    adapter: Ecto.Adapters.Postgres
end
