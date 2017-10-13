defmodule CompanyApiWeb.UserControllerTest do
  use CompanyApiWeb.ConnCase
  use Bamboo.Test, shared: :true

  alias CompanyApiWeb.{User, Email}
  alias CompanyApi.Repo

  @valid_data %{name: "Jim", subname: "Doe", email: "doe@gmail.com", job: "CEO"}

  setup do
    user = Repo.insert!(User.reg_changeset(%User{}, %{ name: "John",
                                                       subname: "Doe",
                                                       email: "doe@gmail.com",
                                                       job: "engineer"
                       }))
    conn =
      build_conn()
      |> put_req_header("accept", "application/json")
    %{conn: conn, user: user}
  end

  test "tries to get all users", %{conn: conn, user: user} do
    user_one = Repo.insert!(User.reg_changeset(%User{}, %{ name: "Jane",
                                                           subname: "Doe",
                                                           email: "jane@gmail.com",
                                                           job: "architect"
                           }))

    response =
      get(conn, user_path(conn, :index))
      |> json_response(200)

    expected =
      [
        %{"id" => user.id, "name" => "John", "subname" => "Doe", "email" => "doe@gmail.com", "job" => "engineer", "password" => nil},
        %{"id" => user_one.id, "name" => "Jane", "subname" => "Doe", "email" => "jane@gmail.com", "job" => "architect", "password" => nil}
      ]

    assert response == expected
  end

  test "creates and renders user", %{conn: conn} do
    response =
      post(conn, user_path(conn, :create), user: @valid_data)
      |> json_response(201)

    assert Repo.get_by(User, name: "Jim")
    :timer.sleep 500
    assert_delivered_email Email.create_mail(response["password"], response["email"])
  end
end
