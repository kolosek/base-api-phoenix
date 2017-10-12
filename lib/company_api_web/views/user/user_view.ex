defmodule CompanyApiWeb.UserView do
  use CompanyApiWeb, :view

  def render(conn, "index.json", %{users: users}) do
    render_many(users, CompanyApiWeb.UserView, "user.json")
  end

  def render("user.json", %{user: user}) do
    %{id: user.id, name: user.name, subname: user.subname, email: user.email, job: user.job}
  end
end
