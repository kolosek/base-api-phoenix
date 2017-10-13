defmodule CompanyApiWeb.SessionController do
  use CompanyApiWeb, :controller

  alias CompanyApiWeb.User

  def create(conn, %{"creds" => params}) do
    case User.check_registration(Map.new(params, fn {k, v} -> {String.to_atom(k), v} end)) do
      {:ok, user} ->
        new_conn = Guardian.Plug.sign_in(conn, CompanyApi.Guardian, user)
        token = Guardian.Plug.current_token(new_conn)
        claims = Guardian.Plug.current_claims(new_conn)
        expire = Map.get(claims, "exp")

        new_conn
        |> put_resp_header("authorization", "Bearer #{token}")
        |> put_status(:ok)
        |> render("login.json", user: user, token: token, exp: expire)
      {:error, reason} ->
        conn
        |> put_status(401)
        |> render("error.json", message: reason)
    end
  end
end
