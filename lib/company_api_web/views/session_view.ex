defmodule CompanyApiWeb.SessionView do
  use CompanyApiWeb, :view

  def render("login.json", %{user: user, token: token, exp: expire})  do
    %{
      data: %{
        user: render_one(user, CompanyApiWeb.UserView, "user.json"),
        token: token,
        expire: expire
      }
    }
  end
end
