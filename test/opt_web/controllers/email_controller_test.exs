defmodule OptWeb.EmailControllerTest do
  use OptWeb.ConnCase

  alias Opt.Accounts
  alias Opt.Accounts.Email

  @create_attrs %{
    email: "some email",
    primary: true,
    verified: true
  }
  @update_attrs %{
    email: "some updated email",
    primary: false,
    verified: false
  }
  @invalid_attrs %{email: nil, primary: nil, verified: nil}

  def fixture(:email) do
    {:ok, email} = Accounts.create_email(@create_attrs)
    email
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all emails", %{conn: conn} do
      conn = get(conn, Routes.email_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create email" do
    test "renders email when data is valid", %{conn: conn} do
      conn = post(conn, Routes.email_path(conn, :create), email: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.email_path(conn, :show, id))

      assert %{
               "id" => id,
               "email" => "some email",
               "primary" => true,
               "verified" => true
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.email_path(conn, :create), email: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update email" do
    setup [:create_email]

    test "renders email when data is valid", %{conn: conn, email: %Email{id: id} = email} do
      conn = put(conn, Routes.email_path(conn, :update, email), email: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.email_path(conn, :show, id))

      assert %{
               "id" => id,
               "email" => "some updated email",
               "primary" => false,
               "verified" => false
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, email: email} do
      conn = put(conn, Routes.email_path(conn, :update, email), email: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete email" do
    setup [:create_email]

    test "deletes chosen email", %{conn: conn, email: email} do
      conn = delete(conn, Routes.email_path(conn, :delete, email))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.email_path(conn, :show, email))
      end
    end
  end

  defp create_email(_) do
    email = fixture(:email)
    {:ok, email: email}
  end
end
