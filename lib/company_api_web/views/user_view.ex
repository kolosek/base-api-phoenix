defmodule CompanyApiWeb.UserView do
  use CompanyApiWeb, :view

  def render("index.json", %{users: users}) do
    render_many(users, CompanyApiWeb.UserView, "user.json")
  end

  def render("create.json", %{user: user}) do
    render_one(user, CompanyApiWeb.UserView, "user.json")
  end

  def render("user.json", %{user: user}) do
    %{id: user.id, name: user.name, subname: user.subname, password: user.password, email: user.email, job: user.job}
  end
end
