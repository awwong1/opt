defmodule Opt.Repo.Migrations.CreateEmails do
  use Ecto.Migration

  def change do
    create table(:emails, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :citext
      add :primary, :boolean, default: false, null: false
      add :verified, :boolean, default: false, null: false
      add :user_id, references(:users, type: :binary_id)

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:emails, [:email])
  end
end
