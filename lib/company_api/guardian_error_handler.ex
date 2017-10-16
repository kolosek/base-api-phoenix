defmodule CompanyApi.GuardianErrorHandler do

  alias CompanyApiWeb.SessionView

  def unauthenticated(conn, _params) do
    conn
    |> Plug.Conn.put_status(401)

    Phoenix.View.render(SessionView, "error.json", message: "Authentication require")
  end
end
