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

  def render("error.json", %{message: reason}) do
    %{data: reason}
  end
end
