defmodule Opt.AccountsTest do
  use Opt.DataCase

  alias Opt.Accounts

  describe "users" do
    alias Opt.Accounts.User

    @valid_attrs %{
      password: "some password 123!",
      username: "some_username"
    }
    @update_attrs %{
      password: "~456 some updated password",
      username: "updated_username"
    }
    @invalid_attrs %{password: nil, username: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      rm_emails = fn x -> Map.drop(x, [:emails]) end
      assert Enum.map(Accounts.list_users(), rm_emails) == [rm_emails.(user)]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      rm_emails = fn x -> Map.drop(x, [:emails]) end
      assert rm_emails.(Accounts.get_user!(user.id)) == rm_emails.(user)
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.username == "some_username"

      # check duplicate constraint error for username collision
      assert {:error, %Ecto.Changeset{} = changeset} = Accounts.create_user(@valid_attrs)

      assert changeset.errors == [
               {:username,
                {"has already been taken",
                 [constraint: :unique, constraint_name: "users_username_index"]}}
             ]
    end

    test "create_user/1 with session_email valid data creates a user" do
      valid_email_attrs = Map.put(@valid_attrs, :session_email, "test.email@udia.ca")
      assert {:ok, %User{} = user} = Accounts.create_user(valid_email_attrs)

      user_email = hd(Repo.preload(user, :emails).emails)
      assert user_email.email == "test.email@udia.ca"
      assert user_email.user_id == user.id
      assert user_email.verified == false
      assert user_email.primary == true

      # check duplicate constraint error for email collision
      duplicate_email_attrs = Map.put(valid_email_attrs, :username, "updated_username")
      assert {:error, %Ecto.Changeset{} = changeset} = Accounts.create_user(duplicate_email_attrs)

      assert changeset.errors == [
               {:session_email,
                {"has already been taken",
                 [constraint: :unique, constraint_name: "emails_email_index"]}}
             ]

      # check duplicate constraint error for username and email collision
      assert {:error, %Ecto.Changeset{} = changeset} = Accounts.create_user(valid_email_attrs)

      assert changeset.errors == [
               {:session_email, {"has already been taken", [validation: :unsafe_unique]}},
               {:username,
                {"has already been taken",
                 [constraint: :unique, constraint_name: "users_username_index"]}}
             ]
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.username == "updated_username"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      rm_emails = fn x -> Map.drop(x, [:emails]) end
      assert rm_emails.(user) == rm_emails.(Accounts.get_user!(user.id))
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "authenticate_user/2 with valid username returns a user" do
      _user = user_fixture()
      assert {:ok, %User{}} = Accounts.authenticate_user("some_username", "some password 123!")
      assert {:error, :invalid_credentials} = Accounts.authenticate_user("some_username", "bad password 789~")
      assert {:error, :invalid_credentials} = Accounts.authenticate_user("bad_username", "some password 123!")
    end

    test "authenticate_user/2 with valid email returns a user" do
      _user = user_fixture(session_email: "test.email@udia.ca")
      assert {:ok, %User{}} = Accounts.authenticate_user("test.email@udia.ca", "some password 123!")
      assert {:error, :invalid_credentials} = Accounts.authenticate_user("test.email@udia.ca", "bad password 789~")
      assert {:error, :invalid_credentials} = Accounts.authenticate_user("bad.email@udia.ca", "some password 123!")
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "emails" do
    alias Opt.Accounts.Email

    @valid_attrs %{email: "some email", primary: true, verified: true}
    @update_attrs %{email: "some updated email", primary: false, verified: false}
    @invalid_attrs %{email: nil, primary: nil, verified: nil}

    def email_fixture(attrs \\ %{}) do
      {:ok, email} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_email()

      email
    end

    test "list_emails/0 returns all emails" do
      email = email_fixture()
      assert Accounts.list_emails() == [email]
    end

    test "get_email!/1 returns the email with given id" do
      email = email_fixture()
      assert Accounts.get_email!(email.id) == email
    end

    test "create_email/1 with valid data creates a email" do
      assert {:ok, %Email{} = email} = Accounts.create_email(@valid_attrs)
      assert email.email == "some email"
      assert email.primary == true
      assert email.verified == true
    end

    test "create_email/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_email(@invalid_attrs)
    end

    test "update_email/2 with valid data updates the email" do
      email = email_fixture()
      assert {:ok, %Email{} = email} = Accounts.update_email(email, @update_attrs)
      assert email.email == "some updated email"
      assert email.primary == false
      assert email.verified == false
    end

    test "update_email/2 with invalid data returns error changeset" do
      email = email_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_email(email, @invalid_attrs)
      assert email == Accounts.get_email!(email.id)
    end

    test "delete_email/1 deletes the email" do
      email = email_fixture()
      assert {:ok, %Email{}} = Accounts.delete_email(email)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_email!(email.id) end
    end

    test "change_email/1 returns a email changeset" do
      email = email_fixture()
      assert %Ecto.Changeset{} = Accounts.change_email(email)
    end
  end
end
