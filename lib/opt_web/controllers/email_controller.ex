defmodule OptWeb.EmailController do
  use OptWeb, :controller

  alias Opt.Accounts
  alias Opt.Accounts.Email

  action_fallback OptWeb.FallbackController

  def index(conn, _params) do
    emails = Accounts.list_emails()
    render(conn, "index.json", emails: emails)
  end

  def create(conn, %{"email" => email_params}) do
    with {:ok, %Email{} = email} <- Accounts.create_email(email_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.email_path(conn, :show, email))
      |> render("show.json", email: email)
    end
  end

  def show(conn, %{"id" => id}) do
    email = Accounts.get_email!(id)
    render(conn, "show.json", email: email)
  end

  def update(conn, %{"id" => id, "email" => email_params}) do
    email = Accounts.get_email!(id)

    with {:ok, %Email{} = email} <- Accounts.update_email(email, email_params) do
      render(conn, "show.json", email: email)
    end
  end

  def delete(conn, %{"id" => id}) do
    email = Accounts.get_email!(id)

    with {:ok, %Email{}} <- Accounts.delete_email(email) do
      send_resp(conn, :no_content, "")
    end
  end
end
