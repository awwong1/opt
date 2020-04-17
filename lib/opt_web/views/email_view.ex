defmodule OptWeb.EmailView do
  use OptWeb, :view
  alias OptWeb.EmailView

  def render("index.json", %{emails: emails}) do
    %{data: render_many(emails, EmailView, "email.json")}
  end

  def render("show.json", %{email: email}) do
    %{data: render_one(email, EmailView, "email.json")}
  end

  def render("email.json", %{email: email}) do
    %{id: email.id, email: email.email, verified: email.verified, primary: email.primary}
  end
end
