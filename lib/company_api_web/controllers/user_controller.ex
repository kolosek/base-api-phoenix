defmodule CompanyApiWeb.UserController do
  use CompanyApiWeb, :controller

  alias CompanyApiWeb.User

  def index(conn, _params) do
    users = Repo.all(User)

    render(conn, "index.json", %{users: users})
  end
end
