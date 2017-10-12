defmodule CompanyApiWeb.PageController do
  use CompanyApiWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
