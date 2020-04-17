ExUnit.configure(formatters: [JUnitFormatter, ExUnit.CLIFormatter])
ExUnit.start(exclude: [:skip])
Ecto.Adapters.SQL.Sandbox.mode(Opt.Repo, :manual)
