defmodule ConversationControllerTest do
  use CompanyApiWeb.ConnCase

  alias CompanyApiWeb.{User, Conversation}

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
      post(new_conn, conversation_path(new_conn, :create), %{recipient: user_two.id})

    assert response(res, 201)
  end

  test "tries to create existing conversation", %{user_one: user_one, user_two: user_two, conn: conn} do
    new_conn = Guardian.Plug.sign_in(conn, CompanyApi.Guardian, user_one)
    post(new_conn, conversation_path(new_conn, :create), %{recipient: user_two.id})

    res =
      post(new_conn, conversation_path(new_conn, :create), %{recipient: user_two.id})
      |> json_response(200)

    refute res["id"] == nil
  end

  test "tries to create with invalid data", %{user_one: user_one, conn: conn} do
    new_conn = Guardian.Plug.sign_in(conn, CompanyApi.Guardian, user_one)
    res =
      post(new_conn, conversation_path(new_conn, :create), %{recipient: 0})
      |> json_response(422)

    assert res["error"] != nil
  end

  test "gets active conversations", %{user_one: user_one, user_two: user_two, conn: conn} do
    conversation =
      %Conversation{}
      |> Conversation.changeset(%{sender_id: user_one.id, recipient_id: user_two.id})
      |> Repo.insert!

    new_conn = Guardian.Plug.sign_in(conn, CompanyApi.Guardian, user_one)
    res =
      get(new_conn, conversation_path(new_conn, :index))
      |> json_response(200)

    expected = %{id: conversation.id}

    assert res == expected
  end
end
