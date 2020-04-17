defmodule Opt.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    # case insensitive text type
    execute "CREATE EXTENSION IF NOT EXISTS citext;"

    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :username, :citext
      add :password_hash, :string

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:users, [:username])
  end
end
