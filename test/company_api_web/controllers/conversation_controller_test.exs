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
    conversation =
      %Conversation{}
      |> Conversation.changeset(%{sender_id: user_one.id, recipient_id: user_two.id})
      |> Repo.insert!

    expected = %{
      id: conversation.id,
      sender_id: user_one.id,
      recipient_id: user_two.id,
      status: nil
    }

    response = post(conn, conversation_path(conn, :index))

    assert response == expected
  end
end
