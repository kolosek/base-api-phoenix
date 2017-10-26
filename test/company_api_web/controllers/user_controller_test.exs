defmodule CompanyApiWeb.UserControllerTest do
  use CompanyApiWeb.ConnCase
  use Bamboo.Test, shared: :true

  @valid_data %{name:    "Jim",
                subname: "Doe",
                email:   "doe@gmail.com",
                job:     "CEO"
               }

  @password "Random pass"

  @user %{name:    "John",
          subname: "Doe",
          email:   "doe@gmail.com",
          job:     "engineer"
         }

  @user_jane %{name:    "Jane",
               subname: "Doe",
               email:   "jane@gmail.com",
               job:     "architect"
              }
  setup do
    user =
      %User{}
      |> User.reg_changeset(@user)
      |> Repo.insert!

    conn =
      build_conn()
      |> put_req_header("accept", "application/json")

    %{conn: conn, user: user}
  end

  test "tries to get all users", %{conn: conn, user: user} do
    jane =
      %User{}
      |> User.reg_changeset(@user_jane)
      |> Repo.insert!

    response =
      get(conn, user_path(conn, :index))
      |> json_response(200)

    expected =
      [
        %{"id" => user.id, "name" => user.name, "subname" => user.subname,
          "email" => user.email, "job" => user.job, "password" => nil},
        %{"id" => jane.id, "name" => jane.name, "subname" => jane.subname,
          "email" => jane.email, "job" => jane.job, "password" => nil}
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
        put(conn, user_path(conn, :change_password, user.id), password: "pass")
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

  test "uploads user profil image", %{conn: conn, user: user} do
    new_conn = Guardian.Plug.sign_in(conn, CompanyApi.Guardian, user)
    profile_image = %Plug.Upload{path: "test/company_api_web/fixtures/image.jpg",
                                 filename: "image.jpg"
                                }

    res =
      post(new_conn, user_path(new_conn, :upload), image: profile_image)
      |> json_response(200)

    assert res["image"]["file_name"] == profile_image.filename
  end

  test "tries to upload wrong data", %{conn: conn, user: user} do
    new_conn = Guardian.Plug.sign_in(conn, CompanyApi.Guardian, user)

    upload = %Plug.Upload{path: "", filename: ""}
    res =
      post(new_conn, user_path(new_conn, :upload), image: upload)
      |> json_response(422)

    assert res["errors"] != %{}
  end
end
