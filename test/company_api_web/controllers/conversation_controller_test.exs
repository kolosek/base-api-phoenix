defmodule ConversationControllerTest do
  use CompanyApiWeb.ConnCase

  alias CompanyApiWeb.User

  @user_one %{name:    "John",
              subname: "Doe",
              email:   "doe@gmail.com",
              job:     "engineer"
             }

  @user_two %{name:    "Jane",
              subname: "Doe",
              email:   "jane@gmail.com",
              job:     "architect"
             }

  setup do
    user_one =
      %User{}
      |> User.reg_changeset(@user_one)
      |> Repo.insert!

    user_two =
      %User{}
      |> User.reg_changeset(@user_two)
      |> Repo.insert!

    conn =
      build_conn()
      |> put_req_header("accept", "application/json")

    {:ok, user_one: user_one, user_two: user_two, conn: conn}
  end

  test "creates conversation", %{user_one: user_one, user_two: user_two, conn: conn} do
    new_conn = Guardian.Plug.sign_in(conn, CompanyApi.Guardian, user_one)
    res =
      post(new_conn, conversation_path(conn, :create), %{conversation: user_two.id})

    assert response(res, 201)
  end

  test "tries to create existing conversation", %{user_one: user_one, user_two: user_two, conn: conn} do

  end
end
