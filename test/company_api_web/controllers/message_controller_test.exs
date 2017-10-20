defmodule CompanyApiWeb.MessageControllerTest do
  use CompanyApiWeb.ConnCase

  alias CompanyApiWeb.{User, Conversation, Message}

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

    conversation =
      %Conversation{}
      |> Conversation.changeset(%{sender_id: user_one.id,
                                  recipient_id: user_two.id,
                                 })
      |> Repo.insert!

    conn =
      build_conn()
      |> put_req_header("accept", "application/json")

    new_conn = Guardian.Plug.sign_in(conn, CompanyApi.Guardian, user_one)

    {:ok, user: user_one, new_conn: new_conn, conv: conversation}
  end

  test "gets all messages for conversation", %{user: user, new_conn: new_conn, conv: conv} do
    Message.create_message(user.id, conv.id, "First message")
    Message.create_message(user.id, conv.id, "Second message")
    Message.create_message(user.id, conv.id, "Third message")

    res = get(new_conn, message_path(new_conn, :index))

    assert res
  end
end
