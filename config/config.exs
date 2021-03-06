# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :opt,
  ecto_repos: [Opt.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :opt, OptWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "OYdKcQOWnrX4kQm6ke8lw2+E3H7eqyTGval3foxs7CoLAb1/00wT2IzmUi2lYwkI",
  render_errors: [view: OptWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Opt.PubSub,
  live_view: [signing_salt: "8vuLZc7LxW1YKObAk/EzXywXYYCXJmWG"]

# Configure Guardian authentication
config :opt, Opt.Accounts.Guardian,
  issuer: "opt",
  secret_key: "uy2c39n6DjKrbH5AT1FsZzEDvm+8bldjnkCWefNV6v0GfOYQPKM98WWL4po7lKo1"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configures Argon2 Password Hashing
config :argon2_elixir,
  t_cost: 8,
  m_cost: 17,
  parallelism: 4,
  argon2_type: 2

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
