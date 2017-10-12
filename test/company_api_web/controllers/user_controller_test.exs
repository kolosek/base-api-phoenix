defmodule CompanyApiWeb.UserControllerTest do
  use CompanyApiWeb.ConnCase

  alias CompanyApiWeb.User
  alias CompanyApi.Repo

  setup do
    conn =
      build_conn()
      |> put_req_header("accept", "application/json")
    %{conn: conn}
  end

  test "tries to get all users", %{conn: conn} do
    user_one = Repo.insert!(User.reg_changeset(%User{}, %{ name: "John",
                                                          subname: "Doe",
                                                          email: "doe@gmail.com",
                                                          job: "engineer"
                                             }))
    user_two = Repo.insert!(User.reg_changeset(%User{}, %{ name: "Jane",
                                                          subname: "Doe",
                                                          email: "jane@gmail.com",
                                                          job: "architect"
                                             }))

    response =
      get(conn, user_path(conn, :index))
      |> json_response(200)

    expected =
      [
        %{"id" => user_one.id, "name" => "John", "subname" => "Doe", "email" => "doe@gmail.com", "job" => "engineer"},
        %{"id" => user_two.id, "name" => "Jane", "subname" => "Doe", "email" => "jane@gmail.com", "job" => "architect"}
      ]

    assert response == expected
  end
end
