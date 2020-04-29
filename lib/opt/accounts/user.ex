defmodule Opt.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :username, :string
    field :password_hash, :string

    field :password, :string, virtual: true
    field :session_email, :string, virtual: true

    has_many :emails, Opt.Accounts.Email

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(user, attrs, pw_required \\ false) do
    user
    |> cast(attrs, [:username, :password, :session_email])
    |> validate_required([:username, :password])
    |> validate_format(:username, ~r/^[\w-]+$/,
      message: "must be alphanumeric with underscores or hyphens"
    )
    |> validate_length(:username, min: 2, max: 32)
    |> validate_confirmation(:password, message: "does not match password", required: pw_required)
    |> validate_length(:password, min: 6, max: 255)
    |> validate_format(:session_email, ~r/^[\w.%+-]+@[\w.-]+\.[\w]{2,}$/,
      message: "must be a valid email address"
    )
    |> unique_constraint([:username])
    |> put_pw_hash
  end

  defp put_pw_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    Ecto.Changeset.change(changeset, password_hash: Argon2.hash_pwd_salt(password))
  end

  defp put_pw_hash(changeset), do: changeset
end
