use Mix.Config

# Configure your database
config :opt, Opt.Repo,
  username: "postgres",
  password: "postgres",
  database: "pg_opt_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :opt, OptWeb.Endpoint,
  http: [port: 4002],
  server: false

# Faster, unsafe Argon2 Password Hashing
config :argon2_elixir,
  t_cost: 1,
  m_cost: 8,
  parallelism: 4,
  argon2_type: 2

# Print only warnings and errors during test
config :logger, level: :warn
