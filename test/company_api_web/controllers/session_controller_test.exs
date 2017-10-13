defmodule CompanyApiWeb.SessionControllerTest do
  use CompanyApiWeb.ConnCase

  alias CompanyApi.Repo
  alias CompanyApiWeb.User

  setup do
    user = Repo.insert!(User.reg_changeset(%User{}, %{name: "John",
                                                      subname: "Doe",
                                                      email: "doe@gmail.com",
                                                      job: "engineer"
                       }))
    conn =
      build_conn()
      |> put_req_header("accept", "application/json")

    {:ok, conn: conn, user: user}
  end

  test "login as user", %{conn: conn, user: user} do
    user_credentials = %{email: user.email, password: user.password}
    response =
      post(conn, session_path(conn, :login), user_credentials)
      |> json_response(200)

    expected = %{
      "id"    => user.id,
      "name"  => user.name,
      "email" => user.email,
      "job"   => user.job
    }

    assert response["data"]["user"] == expected
    refute response["data"]["token"] == nil
  end


end
