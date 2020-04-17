defmodule Opt.Accounts.Email do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "emails" do
    field :email, :string
    field :primary, :boolean, default: false
    field :verified, :boolean, default: false
    belongs_to :user, Opt.Accounts.User

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(email, attrs) do
    email
    |> cast(attrs, [:email, :verified, :primary])
    |> validate_required([:email, :verified, :primary])
    |> unique_constraint([:email])
  end
end
