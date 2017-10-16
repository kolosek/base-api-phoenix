defmodule CompanyApiWeb.UserControllerTest do
  use CompanyApiWeb.ConnCase
  use Bamboo.Test, shared: :true

  alias CompanyApiWeb.{User, Email}
  alias CompanyApi.Repo

  @valid_data %{name: "Jim", subname: "Doe", email: "doe@gmail.com", job: "CEO"}
  @password "Random pass"
  @short_pass "pass"

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

  describe "tries to create and render" do
    test "user with valid data", %{conn: conn} do
      response =
        post(conn, user_path(conn, :create), user: @valid_data)
        |> json_response(201)

      assert Repo.get_by(User, name: "Jim")
      assert_delivered_email Email.create_mail(response["password"], response["email"])
    end

    test "user with invalid data", %{conn: conn} do
      response =
        post(conn, user_path(conn, :create), user: %{})
        |> json_response(422)

      assert response["errors"] != %{}
    end

    test "when user has no email", %{conn: conn} do
      response =
        post(conn, user_path(conn, :create), user: Map.delete(@valid_data, :email))
        |> json_response(422)

      assert response["errors"] != %{}
      refute Repo.get_by(User, %{name: "Jim"})
    end
 end

  describe "tries to change user password" do
    test "with valid data", %{conn: conn, user: user} do
      response =
        put(conn, user_path(conn, :change_password, user.id), password: @password)
        |> json_response(200)

      assert response == @password
      assert Repo.get_by(User, %{id: user.id}).password == @password
    end

    test "with short password", %{conn: conn, user: user} do
      response =
        put(conn, user_path(conn, :change_password, user.id), password: @short_pass)
        |> json_response(422)

      assert response["errors"] != %{}
      refute Repo.get_by(User, %{id: user.id}).password
    end

    test "with wrong user id", %{conn: conn} do
      response =
        put(conn, user_path(conn, :change_password, 0), password: @password)
        |> json_response(422)

      assert response["errors"] != %{}
      refute Repo.get_by(User, %{id: 0})
    end
  end
end
