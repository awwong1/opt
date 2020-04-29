defmodule Opt.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Opt.Repo
  alias Opt.Accounts.User
  alias Opt.Accounts.Email

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user. If the session_email is set, also create an email address.

  ## Examples

      iex> create_user(%{username: "some_user", password: "some password 123!"})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    new_user = User.changeset(%User{}, attrs)

    multi_result =
      Multi.new()
      |> Multi.insert(:user, new_user)
      |> multi_insert_user_email(attrs)
      |> Repo.transaction()

    # Convert %{user: u_data, email // e_data} back to user
    case multi_result do
      {:ok, %{user: user}} ->
        {:ok,
         user
         |> Ecto.Changeset.change(password: nil)
         |> Ecto.Changeset.apply_action!(:insert)}

      {:error, :user, changeset, _changes_so_far} ->
        {:error, check_email_unique(changeset)}

      {:error, :email, %{errors: [email: {msg, keys}]}, _changes_so_far} ->
        # convert the email changeset into a user changeset
        User.changeset(%User{}, attrs)
        |> Ecto.Changeset.add_error(:session_email, msg, keys)
        |> Ecto.Changeset.apply_action(:insert)

      {:error, data} ->
        {:error, data}
    end
  end

  defp check_email_unique(changeset) do
    # check session_email uniqueness, in case transaction failed at user insert
    session_email = Ecto.Changeset.get_change(changeset, :session_email)

    email_changeset =
      %Email{}
      |> change_email(%{email: session_email})
      |> Ecto.Changeset.unsafe_validate_unique([:email], Repo)

    case email_changeset do
      %{errors: [email: {msg = "has already been taken", keys}]} ->
        Ecto.Changeset.add_error(
          changeset,
          :session_email,
          msg,
          Keyword.take(keys, [:validation])
        )

      _ ->
        changeset
    end
  end

  defp multi_insert_user_email(multi, attrs) do
    # Assign multi_insert function to variable
    multi_insert = fn m, session_email ->
      Multi.insert(m, :email, fn %{user: user} ->
        # if no emails exist for this user, set the primary flag to be true
        primary = length(Repo.preload(user, :emails).emails) <= 0

        user
        |> Ecto.build_assoc(:emails)
        |> Email.changeset(%{email: session_email, primary: primary})
      end)
    end

    case attrs do
      %{session_email: session_email} ->
        multi_insert.(multi, session_email)

      _ ->
        multi
    end
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Authenticates a user, given an identifier. Identifier can be either a username or email.
  """
  def authenticate_user(identifier, plain_text_password) do
    is_email =
      identifier
      |> String.trim()
      |> String.match?(~r/^[\w.%+-]+@[\w.-]+\.[\w]{2,}$/)

    query =
      case is_email do
        true ->
          from e in Email,
          join: u in User,
          on: u.id == e.user_id,
          where: e.email == ^(String.trim(identifier)),
          select: u
        _ ->
          from u in User, where: u.username == ^(String.trim(identifier))
      end

    case Repo.one(query) do
      nil ->
        Argon2.no_user_verify()
        {:error, :invalid_credentials}
      user ->
        if Argon2.verify_pass(plain_text_password, user.password_hash) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @doc """
  Returns the list of emails.

  ## Examples

      iex> list_emails()
      [%Email{}, ...]

  """
  def list_emails do
    Repo.all(Email)
  end

  @doc """
  Gets a single email.

  Raises `Ecto.NoResultsError` if the Email does not exist.

  ## Examples

      iex> get_email!(123)
      %Email{}

      iex> get_email!(456)
      ** (Ecto.NoResultsError)

  """
  def get_email!(id), do: Repo.get!(Email, id)

  @doc """
  Creates a email.

  ## Examples

      iex> create_email(%{field: value})
      {:ok, %Email{}}

      iex> create_email(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_email(attrs \\ %{}) do
    %Email{}
    |> Email.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a email.

  ## Examples

      iex> update_email(email, %{field: new_value})
      {:ok, %Email{}}

      iex> update_email(email, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_email(%Email{} = email, attrs) do
    email
    |> Email.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a email.

  ## Examples

      iex> delete_email(email)
      {:ok, %Email{}}

      iex> delete_email(email)
      {:error, %Ecto.Changeset{}}

  """
  def delete_email(%Email{} = email) do
    Repo.delete(email)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking email changes.

  ## Examples

      iex> change_email(email)
      %Ecto.Changeset{source: %Email{}}

  """
  def change_email(%Email{} = email, attrs \\ %{}) do
    Email.changeset(email, attrs)
  end
end
